# cnpg-database-manager

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

Multi-database and multi-tenant management for CloudNativePG clusters with automatic secret generation and isolation

**Homepage:** <https://github.com/encircle360-oss/helm-charts/tree/main/charts/cnpg-database-manager>

> **⚠️ UNDER CONSTRUCTION** 
> This chart is currently under active development and has not been battle-tested in production environments. 
> **NOT PRODUCTION READY** - Use at your own risk and thoroughly test in non-production environments first.

## Why This Chart?

The official CloudNativePG `cluster` chart only supports single database per deployment. This chart fills the gap by providing:

- **Multi-Database Management**: Deploy multiple databases in one PostgreSQL cluster
- **Declarative Role Management**: Automatic PostgreSQL user/role creation via CloudNativePG managed roles
- **Database CRD Integration**: Uses CloudNativePG's Database CRD for proper lifecycle management
- **Multi-Tenant Ready**: Perfect for consolidating multiple lightweight databases
- **Flexible Configuration**: Support for any CloudNativePG feature via `additionalClusterSpec`

Use this chart when you want to consolidate multiple applications into one PostgreSQL cluster while maintaining security isolation.

## Prerequisites

- Kubernetes 1.24+
- Helm 3.8+
- CloudNativePG operator installed (v1.25+)

## Installing the Chart

To install the chart with the release name `my-databases`:

```bash
helm repo add encircle360-oss https://encircle360-oss.github.io/helm-charts/
helm repo update
helm install my-databases encircle360-oss/cnpg-database-manager
```

## Uninstalling the Chart

To uninstall/delete the `my-databases` deployment:

```bash
helm uninstall my-databases
```

## Configuration

### Basic Example - Single Cluster with Multiple Databases

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
      storageClass: standard
    databases:
      - name: keycloak
        owner: keycloak
      - name: paperless
        owner: paperless
      - name: n8n
        owner: n8n
```

This creates:
- One PostgreSQL cluster named `main` with 3 instances (HA setup)
- Three Database CRDs (`main-keycloak`, `main-paperless`, `main-n8n`)
- Three managed PostgreSQL roles (`keycloak`, `paperless`, `n8n`)
- Three role password secrets (`main-keycloak-password`, `main-paperless-password`, `main-n8n-password`)

### Multi-Cluster Setup

```yaml
clusters:
  production:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 100Gi
    databases:
      - name: api-prod
        owner: api
      - name: web-prod
        owner: web
 
  staging:
    enabled: true
    instances: 1
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 20Gi
    databases:
      - name: api-staging
        owner: api
      - name: web-staging
        owner: web
```

### Connection Pooling (PgBouncer)

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    databases:
      - name: app-db
        owner: app
    poolers:
      - name: rw
        type: rw  # read-write pooler
        instances: 3
        poolMode: transaction
        parameters:
          max_client_conn: "1000"
          default_pool_size: "25"
        monitoring:
          enablePodMonitor: true
      - name: ro
        type: ro  # read-only pooler
        instances: 5
        poolMode: transaction
```

### Backup Configuration (S3)

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    backup:
      enabled: true
      schedule: "0 0 * * *"
      retentionPolicy: "30d"
      s3:
        bucket: my-postgres-backups
        region: eu-central-1
        path: /cluster-main
        accessKeyId: ""
        secretAccessKey: ""
    databases:
      - name: production-db
        owner: app
```

### Backup Configuration (Azure Blob Storage)

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    backup:
      enabled: true
      schedule: "0 0 * * *"
      retentionPolicy: "30d"
      azure:
        destinationPath: "https://mystorageaccount.blob.core.windows.net/backups/main"
        inheritFromAzureAD: true  # Use Azure AD Workload Identity
    databases:
      - name: production-db
        owner: app
```

### Backup Configuration (Google Cloud Storage)

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    backup:
      enabled: true
      schedule: "0 0 * * *"
      retentionPolicy: "30d"
      gcs:
        bucket: my-postgres-backups
        path: cluster-main
        gkeEnvironment: true  # Use GKE Workload Identity
    databases:
      - name: production-db
        owner: app
```

### Volume Snapshot Backups

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    backup:
      enabled: true
      schedule: "0 1 * * *"
      retentionPolicy: "30d"
      method: volumeSnapshot
      volumeSnapshot:
        className: csi-aws-vsc
        online: true
        onlineConfiguration:
          immediateCheckpoint: true
          waitForArchive: true
    databases:
      - name: production-db
        owner: app
```

### Disaster Recovery and Point-in-Time Recovery (PITR)

```yaml
clusters:
  recovered:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 100Gi
    databases:
      - name: myapp
        owner: appuser
    recovery:
      enabled: true
      source: production-cluster
      recoveryTarget:
        targetTime: "2025-01-03T14:30:00Z"
        exclusive: false
    externalClusters:
      - name: production-cluster
        barmanObjectStore:
          destinationPath: "s3://my-backups/prod-cluster"
          endpointURL: "https://s3.amazonaws.com"
          s3Credentials:
            accessKeyId:
              name: backup-creds
              key: ACCESS_KEY_ID
            secretAccessKey:
              name: backup-creds
              key: ACCESS_SECRET_KEY
          wal:
            maxParallel: 8
```

### Monitoring with Prometheus and PrometheusRule

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    monitoring:
      enabled: true
      podMonitor:
        enabled: true
      prometheusRule:
        enabled: true
        labels:
          team: platform
        # Optional: Custom alert rules (otherwise defaults are used)
        rules:
          - alert: CustomDatabaseSize
            annotations:
              summary: "Database size exceeds threshold"
            expr: |
              cnpg_pg_database_size_bytes > 100000000000
            for: 10m
            labels:
              severity: warning
    databases:
      - name: app-db
        owner: app
```

### Image Catalog for Centralized Image Management

```yaml
imageCatalogs:
  postgresql:
    enabled: true
    kind: ImageCatalog  # or ClusterImageCatalog for cluster-wide
    images:
      - major: 15
        image: ghcr.io/cloudnative-pg/postgresql:15.6
      - major: 16
        image: ghcr.io/cloudnative-pg/postgresql:16.2
      - major: 17
        image: ghcr.io/cloudnative-pg/postgresql:17.2

clusters:
  main:
    enabled: true
    instances: 3
    # Use imageCatalogRef instead of imageName for auto-updates
    imageCatalogRef:
      apiGroup: postgresql.cnpg.io
      kind: ImageCatalog
      name: postgresql
      major: 17
    storage:
      size: 50Gi
    databases:
      - name: app-db
        owner: app
```

### Multiple Databases in One Cluster

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    databases:
      - name: keycloak
        owner: keycloak
      - name: paperless
        owner: paperless
```

### Advanced PostgreSQL Configuration

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 100Gi
      storageClass: fast-ssd
    resources:
      requests:
        memory: "4Gi"
        cpu: "2000m"
      limits:
        memory: "8Gi"
        cpu: "4000m"
    postgresql:
      parameters:
        max_connections: "300"
        shared_buffers: "2GB"
        effective_cache_size: "6GB"
        maintenance_work_mem: "512MB"
        checkpoint_completion_target: "0.9"
        wal_buffers: "16MB"
        default_statistics_target: "100"
        random_page_cost: "1.1"
        effective_io_concurrency: "200"
        work_mem: "6990kB"
        min_wal_size: "1GB"
        max_wal_size: "4GB"
    databases:
      - name: highload-app
        owner: app
```

### Connection Pooling (PgBouncer)

CloudNativePG provides built-in connection pooling via PgBouncer through the Pooler CRD. Connection pooling improves database performance and resource utilization by reusing database connections.

**Basic Pooler Configuration:**

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 50Gi
    databases:
      - name: myapp
        owner: appuser

    # Connection pooling
    poolers:
      - name: rw
        type: rw  # read-write pooler (connects to primary)
        instances: 3
        poolMode: transaction  # session or transaction
        parameters:
          max_client_conn: "1000"
          default_pool_size: "25"
          min_pool_size: "5"
          reserve_pool_size: "5"
        monitoring:
          enablePodMonitor: true
```

**Multi-Pooler Setup (Read-Write + Read-Only):**

```yaml
poolers:
  # Read-write pooler for primary
  - name: rw
    type: rw
    instances: 3
    poolMode: transaction
    parameters:
      max_client_conn: "1000"
      default_pool_size: "25"
    monitoring:
      enablePodMonitor: true
    template:
      spec:
        containers:
        - name: pgbouncer
          resources:
            requests:
              cpu: "500m"
              memory: "512Mi"
            limits:
              cpu: "1"
              memory: "1Gi"

  # Read-only pooler for replicas
  - name: ro
    type: ro
    instances: 5
    poolMode: transaction
    parameters:
      max_client_conn: "2000"
      default_pool_size: "50"
    monitoring:
      enablePodMonitor: true
```

**Pooler Types:**

- **`rw` (read-write)**: Connects to the primary instance for write operations
- **`ro` (read-only)**: Connects to replica instances for read operations (load balancing)
- **`r` (read-any)**: Connects to any instance (primary or replicas)

**Pool Modes:**

- **`session`** (default): Connection held for entire client session. Use when applications need prepared statements, temporary tables, or session variables.
- **`transaction`**: Connection released after each transaction. More efficient pooling, ideal for high-throughput OLTP workloads and stateless applications.

**Connecting to Pooler:**

Applications connect to pooler services instead of the database directly:

```bash
# Read-write pooler service
<cluster-name>-pooler-rw.<namespace>.svc.cluster.local:5432

# Read-only pooler service
<cluster-name>-pooler-ro.<namespace>.svc.cluster.local:5432
```

**Advanced Pooler Configuration with additionalPoolerSpec:**

For Pooler features not explicitly supported by the chart, use `additionalPoolerSpec`:

```yaml
poolers:
  - name: rw
    type: rw
    instances: 3
    poolMode: transaction
    parameters:
      max_client_conn: "1000"

    # Custom service configuration (e.g., LoadBalancer for external access)
    additionalPoolerSpec:
      serviceTemplate:
        metadata:
          annotations:
            service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        spec:
          type: LoadBalancer
```

### Advanced: Using additionalClusterSpec

For CloudNativePG features not explicitly supported by the chart, use `additionalClusterSpec` to pass any valid CloudNativePG Cluster spec fields.

**Why Object-Based Configuration?**

This chart uses an **object-based** approach (YAML dictionary) for `additionalClusterSpec` rather than a string-based approach (multiline string). This design choice provides:

- ✅ **Type Safety**: Schema validation catches configuration errors before deployment
- ✅ **IDE Support**: Autocomplete and validation in modern editors
- ✅ **Structured API**: CloudNativePG has a well-defined API schema (unlike generic Kubernetes resources)
- ✅ **GitOps Friendly**: Proper YAML parsing and diff tools work correctly
- ✅ **Merge Safety**: Helm's YAML processing prevents malformed output

Alternative approaches (like HashiCorp Consul's string-based `additionalSpec`) are designed for less structured APIs where raw YAML flexibility is needed. For CloudNativePG's typed API, the object-based approach is superior.

**Usage:**

```yaml
clusters:
  main:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:18
    storage:
      size: 100Gi
    databases:
      - name: myapp
        owner: myuser

    # Pass any CloudNativePG Cluster spec field
    additionalClusterSpec:
      # Enable superuser access for admin tools
      enableSuperuserAccess: true

      # Configure pod affinity for multi-zone HA
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: cnpg.io/cluster
                    operator: In
                    values: [main]
              topologyKey: topology.kubernetes.io/zone

      # Custom certificates
      certificates:
        serverCASecret: my-ca-secret
        serverTLSSecret: my-tls-secret

      # Replication tuning
      minSyncReplicas: 1
      maxSyncReplicas: 2

      # Separate WAL storage
      walStorage:
        size: 50Gi
        storageClass: fast-nvme
```

**Important Notes:**

- Fields in `additionalClusterSpec` are merged into the Cluster CRD spec using Helm's `toYaml` function
- This allows using any CloudNativePG feature without waiting for chart updates
- The object-based approach provides validation and type safety through the values schema

⚠️ **Avoid Overriding Chart-Managed Fields**

To prevent conflicts, **do not** define these fields in `additionalClusterSpec` (use the chart's dedicated parameters instead):

| Field | Use Instead |
|-------|-------------|
| `instances` | Chart parameter: `clusters.<name>.instances` |
| `imageName` | Chart parameter: `clusters.<name>.imageName` |
| `storage` | Chart parameter: `clusters.<name>.storage` |
| `managed.roles` | Automatically generated from `clusters.<name>.databases` |
| `postgresql.parameters` | Chart parameter: `clusters.<name>.maxConnections`, `sharedBuffers`, etc. |
| `backup` | Chart parameter: `clusters.<name>.backup` |
| `bootstrap.initdb` | Chart parameter: `clusters.<name>.initdb.postInitSQL` |
| `resources` | Chart parameter: `clusters.<name>.resources` |
| `monitoring` | Chart parameter: `clusters.<name>.monitoring` |

**Best Practices:**

1. Use `additionalClusterSpec` for fields **not** exposed by the chart
2. Consult the [CloudNativePG API Reference](https://cloudnative-pg.io/documentation/current/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec) for available fields
3. Test configurations with `helm template` before applying
4. Document why you're using `additionalClusterSpec` in your values file comments

**Common Use Cases:**

- **High Availability**: `affinity`, `topologySpreadConstraints`
- **Security**: `enableSuperuserAccess`, `certificates`
- **Replication**: `minSyncReplicas`, `maxSyncReplicas`
- **Performance**: `walStorage` (separate WAL disk)
- **Networking**: `primaryUpdateStrategy`, `primaryUpdateMethod`

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| encircle360-oss | <oss@encircle360.com> |  |

## Source Code

* <https://github.com/encircle360-oss/helm-charts>
* <https://cloudnative-pg.io/>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusters | object | `{}` (no clusters deployed by default) | PostgreSQL cluster configurations. Each key represents a cluster name. |
| imageCatalogs | object | `{}` (no catalogs deployed by default) | Image catalog configurations. Defines reusable container image references. |

### Configuration Parameters

The chart uses a dynamic configuration structure where each PostgreSQL cluster is defined under the `clusters` key. Below are the detailed configuration options:

#### Cluster Configuration

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `clusters.<name>.enabled` | bool | Yes | - | Enable or disable this cluster |
| `clusters.<name>.instances` | int | Yes | - | Number of PostgreSQL instances (replicas) |
| `clusters.<name>.imageName` | string | Yes | - | PostgreSQL container image with tag |
| `clusters.<name>.storage.size` | string | Yes | - | Size of persistent volume (e.g., `50Gi`) |
| `clusters.<name>.storage.storageClass` | string | No | - | Storage class name |
| `clusters.<name>.resources.requests.memory` | string | No | - | Memory request (e.g., `2Gi`) |
| `clusters.<name>.resources.requests.cpu` | string | No | - | CPU request (e.g., `1000m`) |
| `clusters.<name>.resources.limits.memory` | string | No | - | Memory limit (e.g., `4Gi`) |
| `clusters.<name>.resources.limits.cpu` | string | No | - | CPU limit (e.g., `2000m`) |
| `clusters.<name>.maxConnections` | string | No | `"200"` | Maximum number of connections |
| `clusters.<name>.sharedBuffers` | string | No | `"256MB"` | Shared memory buffers |
| `clusters.<name>.effectiveCacheSize` | string | No | `"1GB"` | Effective cache size |
| `clusters.<name>.maintenanceWorkMem` | string | No | `"64MB"` | Maintenance work memory |
| `clusters.<name>.checkpointCompletionTarget` | string | No | `"0.9"` | Checkpoint completion target |
| `clusters.<name>.walBuffers` | string | No | `"16MB"` | WAL buffers |
| `clusters.<name>.defaultStatisticsTarget` | string | No | `"100"` | Default statistics target |
| `clusters.<name>.randomPageCost` | string | No | `"1.1"` | Random page cost |
| `clusters.<name>.effectiveIoConcurrency` | string | No | `"200"` | Effective I/O concurrency |
| `clusters.<name>.workMem` | string | No | `"4MB"` | Work memory per operation |
| `clusters.<name>.minWalSize` | string | No | `"1GB"` | Minimum WAL size |
| `clusters.<name>.maxWalSize` | string | No | `"4GB"` | Maximum WAL size |
| `clusters.<name>.parameters` | object | No | `{}` | Additional custom PostgreSQL parameters |
| `clusters.<name>.monitoring.enabled` | bool | No | `false` | Enable Prometheus monitoring |
| `clusters.<name>.backup.enabled` | bool | No | `false` | Enable automated backups |
| `clusters.<name>.backup.schedule` | string | No | `"0 0 0 * * *"` | Backup schedule (cron format) |
| `clusters.<name>.backup.retentionPolicy` | string | No | `"30d"` | Backup retention policy |
| `clusters.<name>.backup.s3.bucket` | string | **Yes** (if S3) | - | S3 bucket name for backups |
| `clusters.<name>.backup.s3.endpoint` | string | **Yes** (if S3) | - | S3 endpoint URL |
| `clusters.<name>.backup.s3.region` | string | No | - | S3 region |
| `clusters.<name>.backup.s3.accessKeyId` | string | **Yes** (if S3) | - | S3 access key ID |
| `clusters.<name>.backup.s3.secretAccessKey` | string | **Yes** (if S3) | - | S3 secret access key |
| `clusters.<name>.backup.s3.credentials.existingSecret` | string | No | - | Existing secret (alternative to accessKeyId/secretAccessKey) |
| `clusters.<name>.initdb.postInitSQL` | array | No | `[]` | Custom SQL statements after init |

#### Database Configuration

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `clusters.<name>.databases[].name` | string | Yes | - | Database name (PostgreSQL identifier format) |
| `clusters.<name>.databases[].owner` | string | Yes | - | Database owner/user name (PostgreSQL identifier format) |
| `clusters.<name>.databases[].encoding` | string | No | `"UTF8"` | Database encoding |
| `clusters.<name>.databases[].locale` | string | No | `"C"` | Database locale |
| `clusters.<name>.databases[].existingSecret` | string | No | - | Existing secret for role password (advanced use) |

#### Additional Configuration

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `clusters.<name>.additionalClusterSpec` | object | No | `{}` | Additional CloudNativePG Cluster spec fields (see Advanced section) |

## How It Works

### Database and User Creation

For each database defined in `clusters.<name>.databases[]`, the chart creates:

1. **Managed Roles** (in Cluster CRD `spec.managed.roles`)
   - Each unique `owner` from all databases becomes a managed PostgreSQL role
   - Roles are automatically deduplicated (multiple databases can share the same owner)
   - CloudNativePG manages the role lifecycle and password rotation
   - Role passwords are stored in secrets: `<cluster>-<owner>-password`

2. **Database CRDs** (CloudNativePG `Database` resources)
   - Database name from `name` field
   - Owner references the managed role created in step 1
   - CloudNativePG operator automatically creates the PostgreSQL database
   - Resource name: `<cluster>-<database-name>` (sanitized for RFC 1123)

3. **Role Password Secrets** (Kubernetes Secrets)
   - Type: `kubernetes.io/basic-auth`
   - Name: `<cluster>-<owner>-password`
   - Contains: `username` and `password` fields
   - Created in the same namespace as the Helm chart
   - Used by CloudNativePG's managed roles feature

### Secrets Management

The chart generates **only** the secrets required by CloudNativePG for managed roles:

**Role Password Secrets**: `<cluster-name>-<owner-name>-password`
- Example: For cluster `main` and owner `keycloak`, the secret is `main-keycloak-password`
- Type: `kubernetes.io/basic-auth`
- Created in the same namespace as the Helm chart
- Used by CloudNativePG's `spec.managed.roles.passwordSecret`
- Shared across multiple databases with the same owner

### Application Credentials

**Applications need to create their own secrets** in their respective namespaces with database connection details.

You can retrieve the password from the role secret and create application secrets manually:

```bash
# Get the password from CNPG namespace
PASSWORD=$(kubectl -n cnpg-databases get secret main-keycloak-password \
  -o jsonpath='{.data.password}' | base64 -d)

# Create application secret in app namespace
kubectl -n keycloak create secret generic keycloak-db \
  --from-literal=username=keycloak \
  --from-literal=password="$PASSWORD" \
  --from-literal=host=main-rw.cnpg-databases.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=database=keycloak
```

**For GitOps with SOPS encryption:**

```yaml
# keycloak/secrets.enc.yaml
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-db
  namespace: keycloak
type: Opaque
stringData:
  username: keycloak
  password: ENC[AES256_GCM,data:xxx,iv:yyy,tag:zzz,type:str]  # encrypted with sops
  host: main-rw.cnpg-databases.svc.cluster.local
  port: "5432"
  database: keycloak
  # Optional convenience fields
  jdbc-url: jdbc:postgresql://main-rw.cnpg-databases.svc.cluster.local:5432/keycloak
  uri: postgresql://keycloak:${password}@main-rw.cnpg-databases.svc.cluster.local:5432/keycloak
```

**Future: External Secrets Operator Integration**

For automated secret distribution, consider using [External Secrets Operator](https://external-secrets.io/):

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: keycloak-db
  namespace: keycloak
spec:
  secretStoreRef:
    name: kubernetes-backend
  target:
    name: keycloak-db
  data:
  - secretKey: password
    remoteRef:
      key: main-keycloak-password
      property: password
```

## Use Cases

### Microservices Consolidation

Instead of running separate PostgreSQL instances for each microservice:

```yaml
clusters:
  microservices:
    enabled: true
    instances: 3
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 100Gi
    databases:
      - name: auth-service
        owner: auth
      - name: user-service
        owner: users
      - name: order-service
        owner: orders
      - name: payment-service
        owner: payments
```

### Multi-Tenant SaaS

Isolate tenant databases while sharing infrastructure:

```yaml
clusters:
  saas-prod:
    enabled: true
    instances: 5
    imageName: ghcr.io/cloudnative-pg/postgresql:17.2
    storage:
      size: 500Gi
    databases:
      - name: tenant-acme
        owner: tenant_acme
      - name: tenant-widgets
        owner: tenant_widgets
      - name: tenant-global
        owner: tenant_global
```

### Development/Staging/Production

Manage all environments from one chart:

```yaml
clusters:
  dev:
    enabled: true
    instances: 1
    storage:
      size: 10Gi
    databases:
      - name: app-dev
        owner: dev
 
  staging:
    enabled: true
    instances: 2
    storage:
      size: 50Gi
    databases:
      - name: app-staging
        owner: staging
 
  prod:
    enabled: true
    instances: 3
    storage:
      size: 200Gi
    backup:
      enabled: true
    databases:
      - name: app-prod
        owner: prod
```

## Troubleshooting

### Check Cluster Status

```bash
kubectl get cluster
kubectl describe cluster <cluster-name>
```

### Check Database Creation

```bash
kubectl get database
kubectl describe database <cluster-name>-<database-name>
```

### View Generated Secrets

```bash
kubectl get secret <cluster-name>-<database-name>-app -o yaml
```

### Check Operator Logs

```bash
kubectl logs -n cnpg-system deployment/cnpg-controller-manager
```

## Comparison with Official Charts

| Feature | Official `cluster` Chart | This Chart |
|---------|-------------------------|------------|
| Cluster Management | ✅ | ✅ |
| Multiple Databases | ❌ (one per deployment) | ✅ (many per cluster) |
| Managed Roles (declarative) | ❌ | ✅ |
| Database CRD Integration | ❌ | ✅ |
| Multi-Cluster Support | ❌ | ✅ (multiple clusters in one chart) |
| Flexible Configuration | ❌ | ✅ (`additionalClusterSpec`) |
| Backup Configuration | ✅ | ✅ |
| Monitoring | ✅ | ✅ |

## Support & Professional Services

### Community Support

For issues and questions about this Helm chart:
- Open an issue in [GitHub Issues](https://github.com/encircle360-oss/helm-charts/issues)
- Start a discussion in [GitHub Discussions](https://github.com/encircle360-oss/helm-charts/discussions)

For CloudNativePG specific issues:
- Visit the [CloudNativePG GitHub repository](https://github.com/cloudnative-pg/cloudnative-pg)
- Check the [CloudNativePG documentation](https://cloudnative-pg.io/documentation/)

### Professional Support

For professional support, consulting, custom development, or enterprise solutions, contact **hello@encircle360.com**

## Disclaimer

**⚠️ This chart is under active development and NOT production-ready.**

This Helm chart is provided "AS IS" without warranty of any kind. encircle360 GmbH and the contributors:
- Make no warranties about the completeness, reliability, or accuracy of this chart
- Are not liable for any damages arising from the use of this chart
- **Strongly recommend thorough testing in non-production environments only**
- Do not recommend this chart for production use at this time

Use this chart at your own risk. For production-ready PostgreSQL solutions with SLA requirements, contact our professional support services at **hello@encircle360.com**

## License

This chart is licensed under the Apache License 2.0. See [LICENSE](https://github.com/encircle360-oss/helm-charts/blob/main/LICENSE) for details.