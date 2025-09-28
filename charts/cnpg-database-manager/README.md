# cnpg-database-manager

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

Multi-database and multi-tenant management for CloudNativePG clusters with automatic secret generation and isolation

**Homepage:** <https://github.com/encircle360-oss/helm-charts/tree/main/charts/cnpg-database-manager>

## Why This Chart?

The official CloudNativePG `cluster` chart only supports single database per deployment. This chart fills the gap by providing:

- **Multi-Database Management**: Deploy multiple databases in one PostgreSQL cluster
- **Automatic Secret Generation**: Each database gets isolated credentials
- **Secret Replication**: Optional secret distribution to application namespaces
- **Multi-Tenant Ready**: Perfect for consolidating multiple lightweight databases
- **Production Best Practices**: Follows Kubernetes security patterns

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
- One PostgreSQL cluster named `main` with 3 instances
- Three separate databases with isolated credentials
- Automatic secret generation for each database

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

### Backup Configuration

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
        credentials:
          existingSecret: s3-credentials
    databases:
      - name: production-db
        owner: app
```

### Monitoring with Prometheus

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
    databases:
      - name: app-db
        owner: app
```

### Secret Replication to Application Namespaces

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
        secretNamespace: keycloak-ns
      - name: paperless
        owner: paperless
        secretNamespace: paperless-ns
```

This automatically replicates database secrets to the application namespaces.

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
| clusters | object | `{}` |  |

## How It Works

### Database and User Creation

For each database defined in `clusters.<name>.databases[]`:

1. **Database Resource**: A CloudNativePG `Database` resource is created
2. **User/Owner**: A PostgreSQL user is automatically created with the `owner` name
3. **Secret Generation**: A Kubernetes Secret is created with connection details:
   - `username`: The database owner
   - `password`: Auto-generated secure password
   - `dbname`: Database name
   - `host`: Cluster service endpoint
   - `port`: PostgreSQL port (5432)
   - `jdbc-url`: JDBC connection string
   - `uri`: PostgreSQL URI connection string

### Secret Naming

Secrets follow the naming pattern: `<cluster-name>-<database-name>-app`

Example: For cluster `main` and database `keycloak`, the secret is `main-keycloak-app`

### Secret Replication

If `secretNamespace` is specified for a database, the secret is automatically replicated to that namespace using Kubernetes secret reflection or a custom replication mechanism.

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
        secretNamespace: auth
      - name: user-service
        owner: users
        secretNamespace: users
      - name: order-service
        owner: orders
        secretNamespace: orders
      - name: payment-service
        owner: payments
        secretNamespace: payments
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
| Automatic Secrets | ❌ | ✅ |
| Secret Replication | ❌ | ✅ |
| Multi-Cluster | ❌ | ✅ |
| Backup Configuration | ✅ | ✅ |
| Monitoring | ✅ | ✅ |

## Community & Contributing

This chart is maintained by [encircle360](https://github.com/encircle360-oss).

- 🐛 Report bugs via [GitHub Issues](https://github.com/encircle360-oss/helm-charts/issues)
- 💡 Feature requests welcome
- 🤝 Pull requests appreciated

For questions and discussions, please use [GitHub Discussions](https://github.com/encircle360-oss/helm-charts/discussions).

## License

This chart is licensed under the Apache License 2.0. See [LICENSE](https://github.com/encircle360-oss/helm-charts/blob/main/LICENSE) for details.