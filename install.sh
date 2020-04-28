#!/bin/sh -e

### Stage 1 - Prerequisites

# constants for helm_operator
helm_operator_version=1.0.0
helm_operator_namespace=md-helm-operator
helm_operator_replica_count=1
helm_versions=v3

# CERT-MANAGER CRDs
kubectl apply \
  --wait \
  -o yaml \
  --validate=false \
  -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

# INSTALL FLUX HELM-OPERATOR

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

### Stage 2 - GENERATE MOONDOG ENGINE METACHART TEMPLATE OUTPUTS

# create tmp directory if it does not exist
mkdir -p tmp 

# template out the chart 
helm template .  -f config/values.yaml --output-dir tmp 

### Stage 3 - DEPLOY STAGE

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

# APPLY RENDERED YAML TEMPLATES
for f in $TEMPLATES
do
  echo "Processing $f template..."
  kubectl apply --wait -f $f 
done

echo "Install is complete!"
