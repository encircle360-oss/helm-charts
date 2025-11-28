# yaade

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Yaade is an open-source, self-hosted, collaborative API development environment

**Homepage:** <https://github.com/encircle360-oss/helm-charts/tree/main/charts/yaade>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| encircle360-oss | <oss@encircle360.com> |  |

## Source Code

* <https://github.com/encircle360-oss/helm-charts>
* <https://github.com/EsperoTech/yaade>
* <https://docs.yaade.io>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity |
| autoscaling | object | `{"enabled":false,"maxReplicas":5,"minReplicas":1,"targetCPUUtilizationPercentage":80,"targetMemoryUtilizationPercentage":80}` | Autoscaling configuration (note: requires shared storage for multiple replicas) |
| extraVolumeMounts | list | `[]` | Extra volume mounts |
| extraVolumes | list | `[]` | Extra volumes |
| fileStorage | object | `{"accessMode":"ReadWriteOnce","annotations":{},"enabled":false,"existingClaim":"","path":"","size":"20Gi","storageClass":""}` | File storage configuration Files uploaded in Yaade are stored separately from the database IMPORTANT: Files are NOT included in database backups! |
| fileStorage.accessMode | string | `"ReadWriteOnce"` | Access mode for file storage |
| fileStorage.annotations | object | `{}` | Annotations for file storage PVC |
| fileStorage.enabled | bool | `false` | Enable separate persistent volume for file storage If disabled, files are stored in the main data volume at /app/data/files |
| fileStorage.existingClaim | string | `""` | Existing claim for file storage |
| fileStorage.path | string | `""` | Custom file storage path (sets YAADE_FILE_STORAGE_PATH) Leave empty to use default location |
| fileStorage.size | string | `"20Gi"` | Size of file storage volume |
| fileStorage.storageClass | string | `""` | Storage class for file storage volume |
| fullnameOverride | string | `""` | Override full name |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"esperotech/yaade"` | Image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.hosts | list | `[{"host":"yaade.example.com","paths":[{"path":"/","pathType":"Prefix"}]}]` | Hosts configuration |
| ingress.tls | list | `[]` | TLS configuration |
| initContainers | list | `[]` | Init containers |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Liveness probe configuration |
| nameOverride | string | `""` | Override name |
| nodeSelector | object | `{}` | Node selector |
| persistence | object | `{"accessMode":"ReadWriteOnce","annotations":{},"enabled":true,"existingClaim":"","size":"10Gi","storageClass":""}` | Persistence configuration for Yaade data |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.annotations | object | `{}` | Annotations for PVC |
| persistence.enabled | bool | `true` | Enable persistence for /app/data (H2 database) |
| persistence.existingClaim | string | `""` | Existing claim |
| persistence.size | string | `"10Gi"` | Size |
| persistence.storageClass | string | `""` | Storage class |
| podAnnotations | object | `{}` | Pod annotations |
| podSecurityContext | object | `{"fsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Pod security context |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Readiness probe configuration |
| replicaCount | int | `1` | Number of replicas (note: multiple replicas require shared storage) |
| resources | object | `{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Resource limits and requests |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false}` | Security context |
| service.annotations | object | `{}` | Annotations |
| service.port | int | `9339` | Service port |
| service.targetPort | int | `9339` | Target port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use |
| sidecarContainers | list | `[]` | Sidecar containers |
| startupProbe | object | `{"enabled":true,"failureThreshold":30,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":0,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":3}` | Startup probe configuration |
| tolerations | list | `[]` | Tolerations |
| yaade | object | `{"adminUsername":"admin","basePath":"","extraEnv":[],"fileStoragePath":""}` | Yaade specific configuration |
| yaade.adminUsername | string | `"admin"` | Admin username for initial setup This is required on first startup. Default password is "password" and must be changed after first login. |
| yaade.basePath | string | `""` | Base path for reverse proxy deployments Set this when running Yaade behind a reverse proxy that serves it at a subpath (e.g., /yaade) Example: "/yaade" for https://example.com/yaade |
| yaade.extraEnv | list | `[]` | Additional environment variables Use this for any additional environment variables needed by Yaade |
| yaade.fileStoragePath | string | `""` | File storage path (YAADE_FILE_STORAGE_PATH) Set this to customize where uploaded files are stored Leave empty to use default location (/app/data/files) Can be used with network storage (NFS, s3fs, etc.) |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
