#!/bin/sh

# USAGE
#
# wildcard.sh my-cluster.example.com
#
# create a wildcard CNAME entry on *.my-cluster.example.com pointing to your nginx load balancer

# REQUIREMENTS
# AWS CLI installed and configured to the account managing the cluster's DNS
# Hosted Zone already created for the cluster's domain in Route53
# Kubectl installed and configured to talk to the correct cluster's context
# Nginx ingress controller enabled in your Moondog Engine installation with default name

CLUSTER_DOMAIN=$1
if [ -z "$CLUSTER_DOMAIN" ]
then
  echo "Please provide a cluster domain argument"
  echo "For example, run 'wildcard my-cluster.example.com' to create a wildcard entry for *.my-cluster.example.com"
  exit 1
fi

HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --output text --query 'HostedZones[*].[Id,Name]' | grep $CLUSTER_DOMAIN | cut -f1)
if [ -z "$HOSTED_ZONE_ID" ]
then
  echo "Could not find a hosted zone for $CLUSTER_DOMAIN"
  exit 1
fi

function get_target_host() {
  TARGET=$(kubectl -n md-nginx-ingress get service md-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
}

echo "Waiting for nginx to be ready..."
get_target_host
until [ -n "$TARGET" ]
do
  sleep 10
  get_target_host
done
echo "Found nginx LoadBalancer"

WILDCARD=*.$CLUSTER_DOMAIN
BODY="{\"Changes\": [{\"Action\": \"UPSERT\", \"ResourceRecordSet\": {\"Name\": \"$WILDCARD\", \"Type\": \"CNAME\", \"TTL\": 300, \"ResourceRecords\": [{\"Value\": \"$TARGET\"}]}}]}"

echo "Configuring CNAME entry for $WILDCARD -> $TARGET"
aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch "$BODY"
