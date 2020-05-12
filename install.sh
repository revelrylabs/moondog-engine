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

# first deploy kubedb because its needed for harbor to install properly
kubectl apply -f tmp/moondog/templates/kubedb.yaml

echo "waiting for kubedb and kubedb-catalog to be available..."

# this wait loops until both kubedb and kubedb-catalog helmreleases are `deployed`
# use jsonpath here as some `--field-selectors` are not aviailable for CRDs
while [ "$(kubectl get helmrelease -n md-kubedb -o=jsonpath='{.items[?(@.status.releaseStatus=="deployed")].metadata.name}')" != "kubedb kubedb-catalog" ]
do
    echo ...
    sleep 5
done

echo "ensuring kubedb CRDs exist..."

# ensure postgres crd exists
until kubectl get crd postgreses.kubedb.com
do
    echo ...
    sleep 5
done

# store rendered template filenames in a variable
TEMPLATES=tmp/moondog/templates/*.yaml

# apply all rendered templates
for f in $TEMPLATES
do
  echo "Processing $f template..."
  kubectl apply --wait -f $f
done

echo "Install is complete!"
