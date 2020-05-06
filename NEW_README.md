## clusterName

## apiServerUrl

## hostedZone

## helmReleaseTimeout

## ca

| name | type | description |
| `----` | ---- | ----------- |
| `crt` | string |  |
| `key` | string |  |

## etcd

| name | type | description |
| `----` | ---- | ----------- |
| `ca.crt` | string |  |
| `healthcheckClient.crt` | string |  |
| `healthcheckClient.key` | string |  |

## userPermissions

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `roleDefinitions` | map (optional) |  |

## auth

TODO

## aws

| name | type | description |
| `----` | ---- | ----------- |
| `region` | string |  |
| `ebsVolumeTypes` | list |  |

## certManager

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `replicaCount` | integer |  |
| `email` | string |  |

## dex

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `port` | integer (optional; default `32000`) |  |
| `oauth.clientId` |  |  |
| `oauth.clientSecret` |  |  |

## flux

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `git.repo` |  |  |
| `git.branch` |  |  |
| `auth.key` |  |  |

## gangway

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |

## harbor

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `postgres.user` |  |  |
| `postgres.password` |  |  |
| `persistence.imageChartStorage` |  |  |

## kubedb

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `catalog.releaseName` | string (optional) | The release name for the kubedb-catalog HelmRelease |

## nginxIngress

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |

## lokiStack

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `dockerHostPath` | string (optional; default `"/var/lib/docker/containers"`) |  |
| `podsHostPath` | string (optional; default `"/var/log/pods"`) |  |

## oauth2Proxy

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `oauth.clientId` |  |  |
| `oauth.clientSecret` |  |  |

## prometheusOperator

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
| `grafana.adminPassword` |  |  |
| `grafana.oauth.clientId` |  |  |
| `grafana.oauth.clientSecret` |  |  |
| `grafana.oauth.scopes` | string (optional; default `"openid profile email offline_access groups"`) |  |

## sealedSecrets

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |

## velero

| name | type | description |
| `----` | ---- | ----------- |
| `create` | boolean (optional; default `true`) | Whether to create this HelmRelease |
| `namespace` | string (optional) | The namespace for the HelmRelease |
| `releaseName` | string (optional) | The release name for the HelmRelease |
