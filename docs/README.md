# Configuring values.yaml

Below you will find detailed descriptions and usage instructions for each section of the `values.yaml` configuration file.

## clusterName

A short identifier for your cluster. Use something with all lowercase and no spaces.

## apiServerUrl

The public URL of your Kubernetes cluster's API server. Typically something like `https://api.k8.example.com:6443`.

## domainSuffix

A string that configures the domain suffix for all of the ingresses created by Moondog Engine. For example, if you set it to `moondog.example.com`, you will end up with your various apps hosted at domains like:

* `dex.moondog.example.com`
* `gangway.moondog.example.com`
* `grafana.moondog.example.com`
* `harbor.moondog.example.com`
* etc.

## helmReleaseTimeout

For typical Moondog Engine usage, you should not need to change the default.

`helmReleaseTimeout` is an integer number of seconds that a HelmRelease will wait to install before declaring failure. Defaults to `1600`.

## pki

PKI certificates and keys. Typically you will provide these to the Moondog Engine installer by putting files into the `config/pki` directory.

| name | type | description |
| `----` | ---- | ----------- |
| `pki.ca.crt` | string | The cluster CA certificate |
| `pki.etcd.ca.crt` | string | The etcd CA certificate |
| `pki.etcd.healthcheckClient.crt` | string | The etcd healthcheck-client certificate |
| `pki.etcd.healthcheckClient.key` | string | The etcd healthcheck-client private key |

## userPermissions

Configuration for the [`user-permissions`](https://github.com/revelrylabs/helm-charts/tree/master/charts/user-permissions) chart, which deals with mapping Users and Groups to associated sets of permissions on the cluster and in namespaces.

Moondog Engine provides the following default `roleDefinitions`:

* `md-read-write-all` - Cluster-level read and write access to all namespaces.
* `md-read-all-except-secrets` - Cluster-level read access to all resources, except for Secrets, in all namespaces.

While the `user-permissions` chart provides a `bindings` config option to bind subjects to roles, we do not use it here. Moondog Engine uses its own [`auth` configuration](#auth) to define, in one place, options for authentication and what roles will be granted to authenticated users.

| name | type | description |
| `----` | ---- | ----------- |
| `userPermissions.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `userPermissions.namespace` | string (optional) | The namespace for the HelmRelease |
| `userPermissions.releaseName` | string (optional) | The release name for the HelmRelease |
| `userPermissions.roleDefinitions` | map (optional) | See chart docs. |

## auth

At present, Moondog Engine is only known to work with GitHub OAuth. Here is an example configuration:

```yaml
auth:
  - type: github
    id: github:example-org
    name: Example Org GitHub
    oauth:
      clientId: "Your GitHub OAuth client ID"
      clientSecret: "Your GitHub OAuth client secret"
    orgs:
      - name: example-org
        teams:
          - name: administrators
            permissions:
              - namespace: '*'
                roles:
                  - md-read-write-all
          - name: engineers
            permissions:
              - namespace: '*'
                roles:
                  - md-read-all-except-secrets
```

* `id` is an arbitrary unique identifier for the Dex connector.
* `name` dictates how the authentication method will be labeled in the Dex UI.
* The `oauth` section should be populated with the client ID and secret from [creating a GitHub OAuth app](https://developer.github.com/apps/building-oauth-apps/creating-an-oauth-app/).
* The `orgs` section in this example says:
  * Only members of the `example-org` org may authenticate.
  * Members of its `administrators` team will be granted `md-read-write-all` on all namespaces.
  * Members of its `engineers` team will be granted `md-read-all-except-secrets` on all namespaces.
* The granted `roles` will have the permissions defined by Moondog Engine's [`userPermissions` configuration](#userPermissions)

## aws

For typical usage of Moondog Engine on AWS, you should not need to customize the `ebsVolumeTypes`. This configuration will create a `StorageClass` for each of the different volume types in the AWS `region`.

| name | type | description |
| ---- | ---- | ----------- |
| `aws.region` | string (optional; default `"us-east-1"`) |  |
| `aws.ebsVolumeTypes` | list (optional) |  |

## certManager

Configures the [`cert-manager`](https://hub.helm.sh/charts/jetstack/cert-manager) chart to automatically provision TLS certificates from [LetsEncrypt](https://letsencrypt.org/).

| name | type | description |
| ---- | ---- | ----------- |
| `certManager.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `certManager.namespace` | string (optional) | The namespace for the HelmRelease |
| `certManager.releaseName` | string (optional) | The release name for the HelmRelease |
| `certManager.replicaCount` | integer (optional; default `1`) | The number of replicas for the deployment |
| `certManager.email` | string | The support email address reported to LetsEncrypt |
| `certManager.defaultClusterIssuer` | string (optional; default `"letsencrypt"`) | Can be switched to `"letsencrypt-staging"` for testing to use LetsEncrypt's [staging environment](https://letsencrypt.org/docs/staging-environment/) |

## dex

Configures the [`dex`](https://hub.helm.sh/charts/stable/dex) chart. For typical Moondog Engine usage, the only things you will need to provide are:

* `oauth.clientId`, an arbitrary string that needs to match your Kubernetes API service's `--oidc-client-id` flag.
* `oauth.clientSecret`, an arbitrary random string which needs to match your Kubernetes API service's `--oidc-client-secret` flag.

Moondog Engine's [`auth` configuration](#auth) will configure your Dex `connectors`, and other apps included in Moondog Engine will configure their own `staticClients` in Dex.

| name | type | description |
| ---- | ---- | ----------- |
| `dex.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `dex.namespace` | string (optional) | The namespace for the HelmRelease |
| `dex.releaseName` | string (optional) | The release name for the HelmRelease |
| `dex.port` | integer (optional; default `32000`) |  |
| `dex.oauth.clientId` |  |  |
| `dex.oauth.clientSecret` |  |  |

## flux

Configures the [`flux`](https://github.com/fluxcd/flux/tree/master/chart/flux) chart for enabling GitOps. This will allow you to manage cluster resources simply by committing YAML files to a git repository.

| name | type | description |
| ---- | ---- | ----------- |
| `flux.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `flux.namespace` | string (optional) | The namespace for the HelmRelease |
| `flux.releaseName` | string (optional) | The release name for the HelmRelease |
| `flux.git.repo` |  |  |
| `flux.git.branch` |  |  |
| `flux.auth.key` |  |  |

## gangway

Configures the [`gangway`]() chart to allow users to authenticate via Dex to get a downloadable configuration that will give them the same identity and access to the `kubectl` CLI.

| name | type | description |
| ---- | ---- | ----------- |
| `gangway.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `gangway.namespace` | string (optional) | The namespace for the HelmRelease |
| `gangway.releaseName` | string (optional) | The release name for the HelmRelease |
| `gangway.sessionKey` | string (optional, default random) | A 32-character secret session key. |

## harbor

Configures the [`harbor`](https://github.com/goharbor/harbor-helm) chart.

| name | type | description |
| ---- | ---- | ----------- |
| `harbor.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `harbor.namespace` | string (optional) | The namespace for the HelmRelease |
| `harbor.releaseName` | string (optional) | The release name for the HelmRelease |
| `harbor.adminPassword` | string (optional; default random) | The initial password for Harbor's `admin` user. |
| `harbor.secretKey` | string (optional, default random) | A 16-character secret key for encryption. |
| `harbor.postgres.password` | string | Password for the `postgres` user in the Harbor database. |
| `harbor.persistence.imageChartStorage` |  |  |
| `harbor.dbBackups.enabled` | boolean (optional; default `true`) | Whether to enable DB backups. `true` requires the other backup options also. |
| `harbor.dbBackups.bucketName` | string (optional) | Name of an S3 bucket to use for database backups. |
| `harbor.dbBackups.credentials.accessKeyId` | string (optional) | Id of the AWS Access Key to access the S3 bucket for backups. |
| `harbor.dbBackups.credentials.secretAccessKey` | string (optional) | AWS Secret Access Key to access the S3 bucket for backups. |

## kubedb

Configures the [`kubedb`](https://github.com/kubedb/installer/tree/v0.13.0-rc.0/chart/kubedb) and [`kubedb-catalog`](https://github.com/kubedb/installer/tree/v0.13.0-rc.0/chart/kubedb-catalog) charts to provide in-cluster database provisioning. This is used by some of the apps included with Moondog Engine, in addition to being useful for your own apps.

| name | type | description |
| ---- | ---- | ----------- |
| `kubedb.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `kubedb.namespace` | string (optional) | The namespace for the HelmRelease |
| `kubedb.releaseName` | string (optional) | The release name for the HelmRelease |
| `kubedb.catalog.releaseName` | string (optional) | The release name for the kubedb-catalog HelmRelease |

## nginxIngress

Configures the [`nginx-ingress`](https://github.com/helm/charts/tree/master/stable/nginx-ingress) chart to set up Nginx as an IngressController that, under the hood, uses an AWS LoadBalancer.

For typical Moondog Engine usage, you should not need to change any of the default configuration.

| name | type | description |
| ---- | ---- | ----------- |
| `nginxIngress.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `nginxIngress.namespace` | string (optional) | The namespace for the HelmRelease |
| `nginxIngress.releaseName` | string (optional) | The release name for the HelmRelease |

## lokiStack

Configures the [`loki-stack`](https://github.com/grafana/loki/tree/master/production/helm) chart to collect pod logs, which Moondog Engine will make searchable via Grafana.

| name | type | description |
| ---- | ---- | ----------- |
| `lokiStack.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `lokiStack.namespace` | string (optional) | The namespace for the HelmRelease |
| `lokiStack.releaseName` | string (optional) | The release name for the HelmRelease |

## oauth2Proxy

Configures the [`oauth2-proxy`](https://hub.helm.sh/charts/stable/oauth2-proxy) chart to authenticate users via Dex for enabled ingresses. Some web apps may not come with OAuth authentication any authentication at all. Putting this proxy in front of them requires users to first authenticate through Dex. In Moondog Engine, this is used by Prometheus Alertmanager. You may also find it useful for other apps you want to install.

For typical Moondog Engine usage, you should only need to set `oauth.clientSecret` to an arbitrary random string.

| name | type | description |
| ---- | ---- | ----------- |
| `oauth2Proxy.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `oauth2Proxy.namespace` | string (optional) | The namespace for the HelmRelease |
| `oauth2Proxy.releaseName` | string (optional) | The release name for the HelmRelease |
| `oauth2Proxy.oauth.clientId` | string | The client id identifying the proxy to Dex. |
| `oauth2Proxy.oauth.clientSecret` | string | The client secret to authenticate when connecting to Dex. |
| `oauth2Proxy.oauth.cookieSecret` | string (optional, default random) | A 32-character secret key for generating cookies. |

## prometheusOperator

Configures the [`prometheus-operator`](https://github.com/helm/charts/tree/master/stable/prometheus-operator) chart to set up metrics collection, log collection, searching and graphing in Grafana, and alerts in Alertmanager.

For typical Moondog Engine usage, you should only need to set `grafana.oauth.clientSecret` to an arbitrary random string.

| name | type | description |
| ---- | ---- | ----------- |
| `prometheusOperator.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `prometheusOperator.namespace` | string (optional) | The namespace for the HelmRelease |
| `prometheusOperator.releaseName` | string (optional) | The release name for the HelmRelease |
| `prometheusOperator.grafana.adminPassword` |  |  |
| `prometheusOperator.grafana.oauth.clientId` |  |  |
| `prometheusOperator.grafana.oauth.clientSecret` |  |  |
| `prometheusOperator.grafana.oauth.scopes` | string (optional; default `"openid profile email offline_access groups"`) |  |

## sealedSecrets

Configures the [`sealed-secrets`](https://github.com/helm/charts/tree/master/stable/sealed-secrets) chart, which will allow you to create SealedSecret resources which, unlike Secrets, are encrypted and safe to check into git.

For typical Moondog Engine usage, you should not need to change any of the default configuration.

| name | type | description |
| ---- | ---- | ----------- |
| `sealedSecrets.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `sealedSecrets.namespace` | string (optional) | The namespace for the HelmRelease |
| `sealedSecrets.releaseName` | string (optional) | The release name for the HelmRelease |

## velero

Configures the [`velero`](https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero) chart to back up the cluster's resources and volumes to Amazon S3.

| name | type | description |
| ---- | ---- | ----------- |
| `velero.create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `velero.namespace` | string (optional) | The namespace for the HelmRelease |
| `velero.releaseName` | string (optional) | The release name for the HelmRelease |
| `velero.region` | string | The AWS region of the S3 bucket |
| `velero.bucketName` | string | The S3 bucket name |
| `velero.awsCredentials` | string |  |
