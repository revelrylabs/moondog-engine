# Moondog Engine

## Prerequisites

### General limitations

This installer uses a Bash script that has been tested only on Mac. It will likely work on Linux. It will likely work in a Linux VM on Windows.

It has only been tested and documented for the following setup:

* Kubernetes 0.15+ cluster
* Running in AWS
  * But _not_ an Amazon EKS cluster, which does not play very well with OpenID Connect (OIDC).
  * Other providers may work with small adjustments but have not been tested.
  * In particular the `StorageClass`es provided by Moondog Engine are AWS-specific.
* OIDC auth provided by GitHub teams
  * Other providers (Active Directory, Google Apps, etc.) will probably work with minimal effort, but again, they have not yet been tested.
* Amazon S3 for various backups

We plan to support alternatives as quickly as possible and will update these docs accordingly.

### kubectl

If you're reading this, you almost certainly have `kubectl` already, but in case you don't: https://kubernetes.io/docs/tasks/tools/install-kubectl/

### Helm

Install Helm if you do not already have it: https://helm.sh/docs/intro/install/

### Amazon S3

* Create an S3 bucket that Moondog Engine apps will use for storing backups. https://docs.aws.amazon.com/quickstarts/latest/s3backup/step-1-create-bucket.html
* Create an S3 bucket that Moondog Engine apps will use for storing Database backups.
* Create an IAM credentials that can write to each S3 bucket you created above. https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/

### GitHub repo for git-ops

Kubernetes resources will be automatically created and updated when you commit `yaml` files to this repo.

You should have a private repository and credentials to access it. (For GitHub, generate a personal access token: https://github.com/settings/tokens/new)

### GitHub OAuth app

https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/

[TODO: MORE INSTRUCTIONS HERE ABOUT CALLBACK URL AND WHATNOT]

## Clone the repository

```
git clone https://github.com/revelrylabs/moondog-engine.git
cd moondog-engine
```

## The `config` directory

```
config/
  pki/
    ca.crt
    etcd/
      ca.crt
      healthcheck-client.crt
      healthcheck-client.key
  values.yaml
```

* `config/pki` contains certificate and key files
* `config/values.yaml`

## Configuring `config/pki` files

You will need to download some files from your Kubernetes masters and put them in their respective directories in ./config

If you used kubeadm, more information is here: 

https://kubernetes.io/docs/setup/best-practices/certificates/#where-certificates-are-stored


## Configuring `config/values.yaml`

For the most part, you should be able to open and edit the provided starter `config/values.yaml` file, following the instructions and comments contained therein.

For a detailed description of some of the configuration keys and their meanings, see [the full table of configuration parameters](#configuration-parameters).

## Installing

```
./install.sh
```

Read any notes that are printed after successful installation, and follow any additional instructions.

## Post-install

Some of the objects installed require DNS to work in order for them to start up and work correctly. After running the installer script, query your nginx service to discover the DNS address of your AWS Elastic Load Balancer (ELB) and add that as a wildcard for the domain, since this is where all of our web traffic will go. 

Find the service with:

```
❯❯❯ kubectl get svc -n md-nginx-ingress
NAME                               TYPE           CLUSTER-IP      EXTERNAL-IP                               PORT(S)
md-nginx-ingress-controller        LoadBalancer   10.96.228.202   somelongdns.us-east-1.elb.amazonaws.com   80:31638/TCP,443:31495/TCP
```

Then, for example, in your DNS create a CNAME for `*.foo.example.com` to `somelongdns.us-east-1.elb.amazonaws.com`

This will allow traffic to reach the cluster and complete the installation process. At this point, certificates should begin to solve via `cert-manager`. Wait a bit and then check if you can reach 

## Troubleshooting

Hopefully the installer will exit with a helpful error. If not, the line it exits on is going to be your best clue as to where to look to debug further. Ensure helmreleases are deployed correctly by running 

`helm list --all-namespaces` which should show `deployed` for all services. 

If any of the components appear to be missing, you can describe the helmrelease to try to see what went wrong with its installation. Failing that, you can look at the logs of pods in the individual namespaces the installer creates for each helmrelease. 

If all else fails feel free to open an issue and we will try to help you!

## Configuration Parameters


| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `clusterName` |  |  |
| `apiServerUrl` | URL of Kubernetes API service |  |
| `hostedZone` | Base domain for ingresses. For example, if the `hostedZone` is "example.com", Dex will be exposed at `dex.example.com` |  |
| `helmReleaseTimeout` | How long `helm-operator` will wait before giving up on installing a `HelmRelease` |  |
| `github.organization` | Cluster auth via Dex will be restricted to members of this GitHub organization |  |
| `github.teams` | Cluster auth via Dex will be restricted to members of these teams in your GitHub organization |  |
| `github.oauth.clientId` | The OAuth client ID for your GitHub OAuth app |  |
| `github.oauth.clientSecret` | The OAuth client secret for your GitHub OAuth app |  |
| `github.ebsVolumeTypes` | For each of these, one `StorageClass` will be created in the cluster. |  |
| `certManager.create` | Whether or not to install `cert-manager` |  |
| `certManager.replicaCount` | The number of replicas for the `cert-manager` deployment |  |
| `certManager.releaseName` | The Helm release name for `cert-manager` | `"md-cert-manager"` |
| `certManager.namespace` | The namespace to install `cert-manager` into | `"md-cert-manager"` |
| `dex.create` | Whether or not to install `dex` |  |
| `dex.releaseName` | The Helm release name for `dex` | `"md-dex"` |
| `dex.namespace` | The namespace to install `dex` into | `"md-dex"` |
| `dex.oauth.clientId` | The client ID for the primary OIDC client (this needs to match your Kubernetes API's `--oidc-client-id` flag) | `"dex"` |
| `dex.oauth.clientSecret` | An arbitrary strong secret string |  |
| `flux.create` | Whether or not to install `flux` |  |
| `flux.releaseName` | The Helm release name for `flux` | `"md-flux"` |
| `flux.namespace` | The namespace to install `flux` into | `"md-flux"` |
| `flux.envSecretName` | The name of the `Secret` to store environment variables for `flux` |  |
| `flux.git.repo` | The URL of the git repository to be used for `flux` git ops |  |
| `flux.git.auth` | The credentials for authenticating to `flux.git.repo` |  |
| `gangway.create` | Whether or not to install `gangway` |  |
| `gangway.releaseName` | The Helm release name for `gangway` | `"md-gangway"` |
| `gangway.namespace` | The namespace to install `gangway` into | `"md-gangway"` |
| `harbor.create` | Whether or not to install `harbor` |  |
| `harbor.releaseName` | The Helm release name for `harbor` | `"md-harbor"` |
| `harbor.namespace` | The namespace to install `harbor` into | `"md-harbor"` |
| `harbor.persistence` | Allows override for the `harbor` Helm chart's parameter of the same name | (See https://helm.goharbor.io) |
| `harbor.postgres.user` | The name of the user to create and use with the included PostgreSQL instance | `"md_harbor"` |
| `harbor.postgres.password` | The password for the user to create and use with the included PostgreSQL instance |  |
| `kubedb.create` | Whether or not to install `kubedb` and `kubedb-catalog` |  |
| `kubedb.releaseName` | The Helm release name for `kubedb` | `"md-kubedb"` |
| `kubedb.namespace` | The namespace to install `kubedb` and `kubedb-catalog` into | `"md-kubedb"` |
| `kubedb.catalog.releaseName` | The Helm release name for `kubedb-catalog` | `"md-kubedb-catalog"` |
| `nginxIngress.create` | Whether or not to install `nginx-ingress` |  |
| `nginxIngress.releaseName` | The Helm release name for `nginx-ingress` | `"md-nginx-ingress"` |
| `nginxIngress.namespace` | The namespace to install `nginx-ingress` into | `"md-nginx-ingress"` |
| `lokiStack.create` | Whether or not to install `loki-stack` |  |
| `lokiStack.releaseName` | The Helm release name for `loki-stack` | `"md-loki-stack"` |
| `lokiStack.namespace` | The namespace to install `loki-stack` into | `"md-loki-stack"` |
| `lokiStack.dockerHostPath` |  | `/var/lib/docker/containers` |
| `lokiStack.podsHostPath` |  | `/var/log/pods` |
| `oauth2Proxy.create` | Whether or not to install `oauth2-proxy` |  |
| `oauth2Proxy.releaseName` | The Helm release name for `oauth2-proxy` | `"md-oauth2-proxy"` |
| `oauth2Proxy.namespace` | The namespace to install `oauth2-proxy` into | `"md-oauth2-proxy"` |
| `oauth2Proxy.oauth.clientId` |  | `"oauth2-proxy"` |
| `oauth2Proxy.oauth.clientSecret` |  |  |
| `prometheusOperator.create` | Whether or not to install `prometheus-operator` |  |
| `prometheusOperator.releaseName` | The Helm release name for `prometheus-operator` | `"md-prometheus-operator"` |
| `prometheusOperator.namespace` | The namespace to install `prometheus-operator` into | `"md-prometheus-operator"` |
| `prometheusOperator.grafana.oauth.clientId` |  | `"grafana"` |
| `prometheusOperator.grafana.oauth.clientSecret` |  |  |
| `prometheusOperator.grafana.oauth.scopes` |  | `"openid profile email offline_access groups"` |
| `sealedSecrets.create` | Whether or not to install `sealed-secrets` |  |
| `sealedSecrets.releaseName` | The Helm release name for `sealed-secrets` | `"sealed-secrets-controller"` |
| `sealedSecrets.namespace` | The namespace to install `sealed-secrets` into | `"kube-system"` |
| `velero.create` | Whether or not to install `velero` |  |
| `velero.releaseName` | The Helm release name for `velero` | `"md-velero"` |
| `velero.namespace` | The namespace to install `velero` into | `"md-velero"` |
| `etcd.ca.crt` | The Kubernetes masters' CA certificate |  |
| `etcd.healthcheckClient.crt` | The CA certificate for the `etcd` healthcheck client (also comes from Kubernetes masters) |  |
| `etcd.healthcheckClient.key` | The private key for the `etcd` healthcheck client (also comes from Kubernetes masters) |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
|  |  |  |
