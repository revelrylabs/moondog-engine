#!/bin/sh -e

### SETUP

# constants for helm-operator
helm_operator_version=1.0.0
helm_operator_namespace=md-helm-operator
helm_operator_replica_count=1
helm_versions=v3

# build the --set-files flag for helm

values_from_files=""
function setfile() {
  if [ -f "$2" ]
  then
    if [ -z "$values_from_files" ]
    then
      values_from_files="$1=$2"
    else
      values_from_files="$values_from_files,$1=$2"
    fi
  fi
}

setfile pki.ca.crt config/pki/ca.crt
setfile pki.etcd.ca.crt config/pki/etcd/ca.crt
setfile pki.etcd.healthcheckClient.crt config/pki/etcd/healthcheck-client.crt
setfile pki.etcd.healthcheckClient.key config/pki/etcd/healthcheck-client.key

if [ -n "$values_from_files" ]
then
  setfile_arg="--set-file $values_from_files"
else
  setfile_arg=""
fi

# helper function for applying a pattern
function applyall() {
  for f in $@
  do
    echo "Applying template $f ..."
    kubectl apply --wait -f $f
  done
}

### GENERATE THE TEMPLATE OUTPUTS

# create tmp directory if it does not exist, and clear out files from previous runs
mkdir -p tmp && rm -rf tmp/*

# template out the chart
helm template . \
  $setfile_arg \
  -f config/values.yaml \
  --output-dir tmp

### INSTALL PREREQUISITES

# Install cert-manager CRDs

kubectl apply \
  --wait \
  -o yaml \
  --validate=false \
  -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

# Install helm-operator

kubectl create namespace $helm_operator_namespace || echo "skip"
helm repo add fluxcd https://charts.fluxcd.io
helm install md-helm-operator fluxcd/helm-operator \
  --wait \
  --namespace $helm_operator_namespace \
  --debug \
  --version $helm_operator_version \
  --set workers=8 \
  --set helm.versions=$helm_versions \
  --set replicaCount=$helm_operator_replica_count \
  || echo "skip"

### APPLY THE TEMPLATE OUTPUTS

# deploy sealed-secrets first so we can seal all our secrets
applyall tmp/moondog/templates/sealed-secrets/*.yaml
while [ "$(kubectl get helmrelease -n kube-system -o=jsonpath='{.items[?(@.status.releaseStatus=="deployed")].metadata.name}')" != "sealed-secrets-controller" ]
do
  echo "Waiting for sealed-secrets controller to be available..."
  sleep 5
done

# seal all our secrets
for f in tmp/moondog/templates/**/*.secret.yaml
do
  echo "Sealing secret $f ..."
  tempfile=/tmp/seal-me-next.yaml
  cat $f \
    | kubeseal -o yaml \
    > $tempfile \
    && cp $tempfile $f \
    && rm $tempfile
done

# deploy kubedb because its needed for harbor to install properly
applyall tmp/moondog/templates/kubedb/*.yaml
# this wait loops until both kubedb and kubedb-catalog helmreleases are `deployed`
# use jsonpath here as some `--field-selectors` are not aviailable for CRDs
while [ "$(kubectl get helmrelease -n md-kubedb -o=jsonpath='{.items[?(@.status.releaseStatus=="deployed")].metadata.name}')" != "kubedb kubedb-catalog" ]
do
    echo "Waiting for kubedb and kubedb-catalog to be available..."
    sleep 5
done
# ensure postgres crd exists
until kubectl get crd postgreses.kubedb.com
do
    echo "Waiting for Postgres CRD to exist..."
    sleep 5
done

# apply all rendered templates
applyall tmp/moondog/templates/**/*.yaml

echo "Install is complete!"
