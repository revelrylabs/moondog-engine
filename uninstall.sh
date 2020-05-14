#!/bin/sh

# Ideally we combine this script with the installer so they can share constants
helm_operator_namespace=md-helm-operator
harbor_operator_namespace=md-harbor


# Change harbor postgres termination policy to "WipeOut" then delete it 
kubectl patch postgres.kubedb.com/harbor-pg -n $harbor_operator_namespace --patch '{"spec": {"terminationPolicy": "WipeOut"}}' --type merge
kubectl delete postgres -n $harbor_operator_namespace harbor-pg

# Change inter-file seperator to newline, as the default is is space-tab-newline
IFS=$'\n'

# delete all ingresses which deletes the chain of certificates, certificate requests, etc. This is needed or NS deletion is blocked. 
INGRESSES=$(kubectl get ingresses --all-namespaces | awk '{print $2 " --namespace " $1}' | awk NR\>1)

for i in $INGRESSES
do
  eval $(echo "kubectl delete --wait ingress $i")
done

# store rendered template filenames in a variable. 
# grep rendered templates, trim result to the format `$NAME --namespace $NAMESPACE` using awk. 
HELMRELEASES=$(grep -A 3 HelmRelease tmp/moondog/templates/**/* | awk '/name:/{ NAME=$3; next} /namespace:/{ print NAME " --namespace "  $3  }')

# loop thru and delete the helmreleases
for i in $HELMRELEASES
do
  eval $(echo "kubectl delete helmrelease $i")
done

echo "All helmreleases removed."

# remove CERT-MANAGER CRDs
kubectl delete \
  --wait \
  -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

# store rendered template filenames in a variable.
# grep rendered templates, trim result to the format `$NAME --namespace $NAMESPACE` using awk and uniq
NAMESPACES=$(grep -w -A 2 "kind: Namespace" tmp/moondog/templates/**/* | awk '/name:/{print $3}'| uniq)
for i in $NAMESPACES
do if [ $i != "kube-system" ]
    then eval $(echo kubectl delete namespace $i)
    fi
done

# REMOVE FLUX HELM-OPERATOR STUFF
helm delete -n $helm_operator_namespace $helm_operator_namespace
kubectl delete ns $helm_operator_namespace
helm repo remove fluxcd

echo "Helm-Operator Removed"
echo "Uninstall is complete"
