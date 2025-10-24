# yaade

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[Yaade](https://github.com/EsperoTech/yaade) is an open-source, self-hosted, collaborative API development environment

**Homepage:** <https://github.com/encircle360-oss/helm-charts/tree/main/charts/yaade>

## Why This Chart?

Yaade is a modern, self-hosted alternative to Postman that prioritizes privacy, collaboration, and simplicity. This Helm chart provides:

- **Easy Kubernetes Deployment**: Deploy Yaade in your cluster with minimal configuration
- **Persistent Storage**: Automatic H2 database persistence for your API collections
- **Flexible Configuration**: Support for reverse proxy deployments and custom settings
- **Production-Ready Patterns**: Following Kubernetes best practices for security and reliability

Use this chart when you want to:
- Self-host your API development environment
- Keep sensitive API credentials on your own infrastructure
- Enable team collaboration on API testing and development
- Integrate API development workflows into your Kubernetes ecosystem

## What is Yaade?

Yaade is a collaborative API development environment that offers:

- 🏠 **Self-Hosted**: Keep your data on your own infrastructure
- 👥 **Multi-User Support**: Collaborate with your team on API development
- 💾 **Data Persistence**: All data persists across restarts
- 📦 **Import/Export**: Single-file import/export for easy backup
- 🔄 **Request Proxying**: Proxy requests through browser or server
- 📡 **REST & WebSocket**: Full support for REST APIs and WebSocket connections
- 📝 **Markdown Documentation**: Document your APIs with Markdown
- 🔧 **Scripting**: JavaScript-based scripting for automation and cron jobs
- 📥 **Collection Import**: Import from OpenAPI and Postman formats
- 🌙 **Dark Mode**: Beautiful dark mode interface

## Prerequisites

- Kubernetes 1.24+
- Helm 3.8+
- PersistentVolume support in the cluster (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-yaade`:

```bash
helm repo add encircle360-oss https://encircle360-oss.github.io/helm-charts/
helm repo update
helm install my-yaade encircle360-oss/yaade
```

## Uninstalling the Chart

To uninstall/delete the `my-yaade` deployment:

```bash
helm uninstall my-yaade
```

## Configuration

### Basic Example

```yaml
yaade:
  adminUsername: "admin"

persistence:
  enabled: true
  size: 10Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: yaade.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: yaade-tls
      hosts:
        - yaade.example.com
```

### Reverse Proxy with Subpath

When running Yaade behind a reverse proxy at a subpath:

```yaml
yaade:
  adminUsername: "admin"
  basePath: "/yaade"

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: example.com
      paths:
        - path: /yaade
          pathType: Prefix
```

### High Availability (Shared Storage Required)

```yaml
replicaCount: 3

persistence:
  enabled: true
  size: 20Gi
  storageClass: "nfs-client"  # Must support ReadWriteMany
  accessMode: ReadWriteMany

resources:
  requests:
    memory: "512Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "500m"

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - yaade
          topologyKey: kubernetes.io/hostname
```

### Custom Environment Variables

```yaml
yaade:
  adminUsername: "admin"
  extraEnv:
    - name: CUSTOM_SETTING
      value: "custom-value"
    - name: SECRET_VALUE
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: api-key
```

### File Storage with Network Mount (NFS/s3fs)

For shared file storage across replicas or external storage:

```yaml
replicaCount: 3

persistence:
  enabled: true
  size: 10Gi
  accessMode: ReadWriteMany
  storageClass: "nfs-client"

fileStorage:
  enabled: true
  size: 50Gi
  accessMode: ReadWriteMany
  storageClass: "nfs-client"

yaade:
  fileStoragePath: "/app/files"
```

This setup allows:
- Multiple Yaade replicas sharing the same data
- Centralized file storage on NFS or similar
- Independent backup strategies for DB vs files

## Important Notes

### Default Credentials

- **Username**: Set via `yaade.adminUsername` (default: "admin")
- **Password**: "password" (⚠️ MUST be changed after first login!)

After logging in for the first time, go to **Settings > Account** to change the default password.

### OAuth2 / OIDC Authentication

Yaade supports external authentication via OAuth2 and OIDC protocols. OAuth providers are configured through the web UI after deployment.

#### Supported Providers

- **Azure AD** - Microsoft Azure Active Directory
- **AWS Cognito** - Amazon Cognito user pools
- **Keycloak** - Open source identity and access management
- **Generic OIDC** - Any OpenID Connect compliant provider
- **Generic OAuth2** - Standard OAuth2 implementations

#### Configuration Steps

1. Deploy Yaade with this Helm chart
2. Login with admin credentials
3. Navigate to **Settings ⚙️ > Users > External**
4. Paste your OAuth configuration JSON
5. Users can now login via OAuth provider

#### Example: Azure AD Configuration

```json
{
  "providers": [{
    "id": "azure-oauth",
    "label": "Azure SSO Login",
    "provider": "azureAD",
    "params": {
      "tenant": "your-tenant-id",
      "clientId": "your-client-id",
      "clientSecret": "your-client-secret",
      "callbackUrl": "https://yaade.example.com/azure-oauth",
      "fields": {
        "username": "/email",
        "groups": "/groups",
        "defaultGroups": ["developers"]
      },
      "scopes": ["openid", "profile", "email"]
    }
  }]
}
```

#### Example: Keycloak Configuration

```json
{
  "providers": [{
    "id": "keycloak-oauth",
    "label": "Keycloak SSO",
    "provider": "keycloak",
    "params": {
      "site": "https://keycloak.example.com/realms/myrealm",
      "clientId": "yaade-client",
      "clientSecret": "your-client-secret",
      "callbackUrl": "https://yaade.example.com/keycloak-oauth",
      "fields": {
        "username": "/preferred_username",
        "groups": "/groups",
        "filter": "^yaade-.*",
        "defaultGroups": ["users"]
      },
      "scopes": ["openid", "profile"]
    }
  }]
}
```

#### Example: Generic OIDC Provider

```json
{
  "providers": [{
    "id": "oidc-provider",
    "label": "Company SSO",
    "provider": "oidc-discovery",
    "params": {
      "site": "https://sso.example.com",
      "clientId": "yaade-app",
      "clientSecret": "your-client-secret",
      "callbackUrl": "https://yaade.example.com/oidc-provider",
      "fields": {
        "username": "/email",
        "groups": "/roles"
      },
      "scopes": ["openid"]
    }
  }]
}
```

#### Important OAuth Notes

- **Callback URL**: Must be unique for each provider and match the `"id"` field (e.g., `https://yaade.example.com/azure-oauth`)
- **Group Mapping**: Map OAuth groups to Yaade teams using the `"groups"` field
- **Default Groups**: Auto-assign groups to all OAuth users with `"defaultGroups"`
- **Filter Groups**: Use regex patterns in `"filter"` to include only specific groups
- **Multiple Providers**: Configure multiple OAuth providers in the same `"providers"` array

**OAuth configuration is stored in the database** (persistent volume) and persists across restarts.

For detailed documentation, see: [Yaade OAuth Documentation](https://github.com/EsperoTech/yaade/blob/main/docs/docs/users-groups.md)

### Browser Extension

For CORS proxy support, install the Yaade browser extension:
- **Chrome**: [Chrome Web Store](https://chrome.google.com/webstore/detail/yaade/jgmpcefommmbldjnljkjkbhkfgddillg)
- **Firefox**: [Firefox Add-ons](https://addons.mozilla.org/en-US/firefox/addon/yaade/)

Configure the extension with your Yaade server URL (e.g., `https://yaade.example.com/`).

### Persistence

Yaade stores data in two locations:

1. **Database** (`/app/data`): H2 file-based database containing collections, requests, users, etc.
2. **Files** (configurable): Uploaded files for API requests (multipart/form-data)

#### Basic Persistence (Default)

By default, both database and files are stored in the same volume:

```yaml
persistence:
  enabled: true
  size: 10Gi  # Includes database + files
```

#### Separate File Storage

For better organization or to use different storage backends (NFS, s3fs), enable separate file storage:

```yaml
persistence:
  enabled: true
  size: 10Gi  # Database only

fileStorage:
  enabled: true
  size: 20Gi  # Dedicated file storage
  storageClass: "nfs-client"  # Optional: different storage class
```

#### Custom File Storage Path

Configure a custom path for file storage (useful for network mounts):

```yaml
yaade:
  fileStoragePath: "/mnt/shared-files"

fileStorage:
  enabled: true
  path: "/mnt/shared-files"
```

#### ⚠️ Important: File Backup Considerations

**Files are NOT included in database backups!** When backing up Yaade:

1. Backup the database volume (`/app/data`)
2. **Separately backup the file storage location**
3. Consider using VolumeSnapshots for both volumes

Example backup strategy:

```yaml
# Backup both volumes independently
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: yaade-db-backup
spec:
  source:
    persistentVolumeClaimName: yaade-data

---
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: yaade-files-backup
spec:
  source:
    persistentVolumeClaimName: yaade-files
```

**Multiple Replicas**: If running multiple replicas, you must use shared storage (ReadWriteMany) for both database and file storage to ensure all pods can access the same data.

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
| livenessProbe | object | `{"enabled":true,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5,"failureThreshold":3,"successThreshold":1}` | Liveness probe configuration |
| nameOverride | string | `""` | Override name |
| nodeSelector | object | `{}` | Node selector |
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.annotations | object | `{}` | Annotations for PVC |
| persistence.enabled | bool | `true` | Enable persistence for /app/data (H2 database and files) |
| persistence.existingClaim | string | `""` | Existing claim |
| persistence.size | string | `"10Gi"` | Size |
| persistence.storageClass | string | `""` | Storage class |
| podAnnotations | object | `{}` | Pod annotations |
| podSecurityContext | object | `{"fsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Pod security context |
| readinessProbe | object | `{"enabled":true,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":5,"failureThreshold":3,"successThreshold":1}` | Readiness probe configuration |
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
| startupProbe | object | `{"enabled":true,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":0,"periodSeconds":5,"timeoutSeconds":3,"failureThreshold":30,"successThreshold":1}` | Startup probe configuration |
| tolerations | list | `[]` | Tolerations |
| yaade | object | `{"adminUsername":"admin","basePath":"","extraEnv":[]}` | Yaade specific configuration |
| yaade.adminUsername | string | `"admin"` | Admin username for initial setup. This is required on first startup. Default password is "password" and must be changed after first login. |
| yaade.basePath | string | `""` | Base path for reverse proxy deployments. Set this when running Yaade behind a reverse proxy that serves it at a subpath (e.g., /yaade). Example: "/yaade" for https://example.com/yaade |
| yaade.extraEnv | list | `[]` | Additional environment variables. Use this for any additional environment variables needed by Yaade |

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=yaade
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Access Yaade Locally

```bash
kubectl port-forward svc/<release-name>-yaade 9339:9339
```

Then access Yaade at http://localhost:9339

### Reset Admin Password

The admin password can only be changed through the web interface. If you lose access, you'll need to:

1. Delete the PVC to reset the database (⚠️ this will delete all data)
2. Reinstall the chart with a new admin username

## Contributing & Maintainership

### We Welcome Contributors! 🎉

We're actively looking for contributors and co-maintainers for this Yaade chart! Whether you want to:
- **Become a co-maintainer** for this chart
- **Submit pull requests** for bug fixes, features, or documentation improvements
- **Help with testing** in different Kubernetes environments
- **Improve documentation** with usage examples and best practices

**Every contribution makes a difference!** Whether you're a Kubernetes expert or just getting started - your perspective is valuable.

### Become a Chart Co-Maintainer

Interested in becoming a co-maintainer for this chart? We'd love to have you!

**What we're looking for:**
- Interest in API development tools and self-hosted solutions
- Kubernetes and Helm experience
- Willingness to review PRs and respond to issues
- Commitment to maintain quality and backwards compatibility

**How to get involved:**
- Start by contributing PRs or helping in issues/discussions
- Reach out to us at **oss@encircle360.com** expressing your interest
- We'll collaborate to onboard you as a co-maintainer

We believe in community-driven development and are happy to share maintainer responsibilities with passionate contributors!

## Support & Professional Services

### Community Support

For issues and questions about this Helm chart:
- **Discord Community**: Join our [Discord Server](https://discord.gg/6WWWrhFVf3) to chat with maintainers and other users
- **Chart Issues**: Create an [Issue](https://github.com/encircle360-oss/helm-charts/issues) for Helm chart bugs and feature requests
- **General Questions**: Start a [Discussion](https://github.com/encircle360-oss/helm-charts/discussions) for questions and general support

For issues with Yaade itself (not chart-related):
- Visit the [Yaade GitHub repository](https://github.com/EsperoTech/yaade)
- Check the [Yaade documentation](https://docs.yaade.io)

### Professional Support

For professional support, consulting, custom development, or enterprise solutions, contact us at **hello@encircle360.com**

## Disclaimer

This Helm chart is provided "AS IS" without warranty of any kind. encircle360 GmbH and the contributors:
- Make no warranties about the completeness, reliability, or accuracy of this chart
- Are not liable for any damages arising from the use of this chart
- Recommend thorough testing in non-production environments before production deployment

For production deployments requiring guaranteed support and SLAs, contact our professional support services at **hello@encircle360.com**

## License

This chart is licensed under the Apache License 2.0. See [LICENSE](https://github.com/encircle360-oss/helm-charts/blob/main/LICENSE) for details.
