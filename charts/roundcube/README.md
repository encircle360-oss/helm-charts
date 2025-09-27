# roundcube

![Version: 0.3.1](https://img.shields.io/badge/Version-0.3.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.11](https://img.shields.io/badge/AppVersion-1.6.11-informational?style=flat-square)

A free and open source webmail solution with a desktop-like user interface

**Homepage:** <https://github.com/encircle360-oss/helm-charts/tree/main/charts/roundcube>

## Introduction

This chart bootstraps a [Roundcube](https://roundcube.net/) deployment on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

Roundcube is a browser-based multilingual IMAP client with an application-like user interface. It provides full functionality expected from an email client, including MIME support, address book, folder management, message searching and spell checking.

## Prerequisites

- Kubernetes 1.27+
- Helm 3.14.0+
- PV provisioner support in the underlying infrastructure (if using SQLite)
- Access to an IMAP/SMTP mail server

## Installing the Chart

To install the chart with the release name `my-roundcube`:

```bash
helm repo add encircle360-oss https://encircle360-oss.github.io/helm-charts/
helm repo update
helm install my-roundcube encircle360-oss/roundcube
```

## Uninstalling the Chart

To uninstall/delete the `my-roundcube` deployment:

```bash
helm uninstall my-roundcube
```

## Configuration

### Basic Configuration

The following table lists the most important configurable parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `roundcube.defaultHost` | Default IMAP server address | `ssl://mail.example.com` |
| `roundcube.defaultPort` | Default IMAP server port | `993` |
| `roundcube.smtpServer` | SMTP server address | `tls://mail.example.com` |
| `roundcube.smtpPort` | SMTP server port | `587` |

### Database Configuration

This chart supports three database backends:

#### SQLite (Default)

```yaml
database:
  type: sqlite
persistence:
  enabled: true
  size: 5Gi
```

#### MySQL/MariaDB

```yaml
database:
  type: mysql
  external:
    host: mysql.example.com
    port: 3306
    name: roundcube
    user: roundcube
    password: secretpassword
```

#### PostgreSQL

```yaml
database:
  type: pgsql
  external:
    host: postgresql.example.com
    port: 5432
    name: roundcube
    user: roundcube
    password: secretpassword
```

### Ingress Configuration

To expose Roundcube via Ingress:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: webmail.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: roundcube-tls
      hosts:
        - webmail.example.com
```

### Session Storage with Redis

For better performance in multi-replica deployments:

```yaml
redis:
  enabled: true
  host: redis-master.default.svc.cluster.local
  port: 6379
  password: redispassword
```

### Installing Additional Plugins via Composer

Roundcube supports installing additional plugins via composer. You can specify plugins using the `composerPlugins` list:

```yaml
roundcube:
  plugins:
    - archive
    - zipdownload
  composerPlugins:
    - johndoh/contextmenu
    - sblaisot/automatic_addressbook
    - texxasrulez/persistent_login
```

This will:
- Install the specified plugins via composer during container startup
- Automatically make them available in Roundcube
- Work with any plugin available on Packagist

Popular composer plugins include:
- `johndoh/contextmenu` - Context menu for message list
- `sblaisot/automatic_addressbook` - Automatically add recipients to address book
- `texxasrulez/persistent_login` - Stay logged in across sessions
- `weird-birds/thunderbird_labels` - Thunderbird-style labels

### Custom Configuration

You can provide custom Roundcube configuration:

```yaml
roundcube:
  customConfig: |
    <?php
    $config['spell_engine'] = 'aspell';
    $config['enable_spellcheck'] = true;
    // Additional custom configuration
```

### Plugin-Specific Configuration

Many Roundcube plugins require their own `config.inc.php` file in the plugin directory. You can provide plugin-specific configurations using the `pluginConfigs` map:

```yaml
roundcube:
  plugins:
    - identity_from_directory
    - persistent_login
  pluginConfigs:
    identity_from_directory: |
      <?php
      $config['identity_from_directory_ldap_host'] = ['ldap://localhost:389'];
      $config['identity_from_directory_ldap_base_dn'] = 'dc=example,dc=com';
      $config['identity_from_directory_ldap_bind_dn'] = 'cn=admin,dc=example,dc=com';
      $config['identity_from_directory_ldap_bind_pass'] = 'secret';
    persistent_login: |
      <?php
      $config['login_lifetime'] = 30;
      $config['login_secure_cookie'] = true;
      $config['login_token_expiration'] = 3600;
```

This will:
- Create a ConfigMap with all plugin configurations
- Mount each config to `/var/www/html/plugins/<plugin-name>/config.inc.php`
- Support multiple plugin configs simultaneously
- Work alongside the main Roundcube configuration

### Multi-Domain Support

Roundcube can serve multiple domains with completely different configurations:

```yaml
roundcube:
  multiDomain:
    enabled: true
    domains:
      - name: "mail.example.com"
        config: |
          $config['default_host'] = 'ssl://imap.example.com:993';
          $config['smtp_server'] = 'tls://smtp.example.com:587';
          $config['managesieve_host'] = 'imap.example.com';
          $config['managesieve_port'] = 4190;
          $config['plugins'] = array('managesieve', 'password', 'archive');
      - name: "mail.company.org"
        config: |
          $config['default_host'] = 'ssl://mail.company.org:993';
          $config['smtp_server'] = 'ssl://mail.company.org:465';
          $config['smtp_conn_options'] = array(
            'ssl' => array('verify_peer' => false)
          );
          $config['password_algorithm'] = 'sha256-crypt';
          $config['password_db_dsn'] = 'mysql://user:pass@localhost/users';
          $config['plugins'] = array('password', 'vacation', 'forward');

ingress:
  enabled: true
  hosts:
    - host: mail.example.com
      paths:
        - path: /
    - host: mail.company.org
      paths:
        - path: /
```

With this configuration:
- Each domain can have **completely different** settings
- Full control over IMAP, SMTP, ManageSieve, OAuth, plugins, etc.
- Users accessing different domains get their specific configuration
- Fallback to default settings if domain is not configured

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| encircle360-oss | <oss@encircle360.com> |  |

## Source Code

* <https://github.com/roundcube/roundcubemail>
* <https://github.com/encircle360-oss/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `10` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| database.external.existingSecret | string | `""` |  |
| database.external.existingSecretPasswordKey | string | `"password"` |  |
| database.external.existingSecretUserKey | string | `"username"` |  |
| database.external.host | string | `""` |  |
| database.external.name | string | `"roundcube"` |  |
| database.external.password | string | `""` |  |
| database.external.port | int | `3306` |  |
| database.external.user | string | `"roundcube"` |  |
| database.type | string | `"sqlite"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"roundcube/roundcubemail"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"webmail.example.com"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| initContainers | list | `[]` |  |
| livenessProbe.enabled | bool | `true` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| memcached.enabled | bool | `false` |  |
| memcached.host | string | `""` |  |
| memcached.port | int | `11211` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `""` |  |
| persistence.logsPath | string | `"/var/roundcube/logs"` |  |
| persistence.size | string | `"5Gi"` |  |
| persistence.sqlitePath | string | `"/var/roundcube/db"` |  |
| persistence.storageClass | string | `""` |  |
| persistence.tempPath | string | `"/tmp/roundcube"` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `33` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `33` |  |
| readinessProbe.enabled | bool | `true` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| redis.enabled | bool | `false` |  |
| redis.existingSecret | string | `""` |  |
| redis.existingSecretPasswordKey | string | `"password"` |  |
| redis.host | string | `""` |  |
| redis.password | string | `""` |  |
| redis.port | int | `6379` |  |
| replicaCount | int | `1` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"256Mi"` |  |
| roundcube.composerPlugins | list | `[]` |  |
| roundcube.customConfig | string | `""` |  |
| roundcube.defaultHost | string | `"ssl://mail.example.com"` |  |
| roundcube.defaultPort | int | `993` |  |
| roundcube.desKey | string | `""` |  |
| roundcube.extraEnvVars | list | `[]` |  |
| roundcube.extraVolumeMounts | list | `[]` |  |
| roundcube.extraVolumes | list | `[]` |  |
| roundcube.multiDomain.domains | list | `[]` |  |
| roundcube.multiDomain.enabled | bool | `false` |  |
| roundcube.pluginConfigs | object | `{}` |  |
| roundcube.plugins[0] | string | `"archive"` |  |
| roundcube.plugins[1] | string | `"zipdownload"` |  |
| roundcube.plugins[2] | string | `"managesieve"` |  |
| roundcube.productName | string | `"Roundcube Webmail"` |  |
| roundcube.skin | string | `"elastic"` |  |
| roundcube.smtpPass | string | `"%p"` |  |
| roundcube.smtpPort | int | `587` |  |
| roundcube.smtpServer | string | `"tls://mail.example.com"` |  |
| roundcube.smtpUser | string | `"%u"` |  |
| roundcube.supportUrl | string | `""` |  |
| roundcube.uploadMaxFilesize | string | `"25M"` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` |  |
| service.annotations | object | `{}` |  |
| service.port | int | `80` |  |
| service.targetPort | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| sidecarContainers | list | `[]` |  |
| startupProbe.enabled | bool | `false` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `0` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.successThreshold | int | `1` |  |
| startupProbe.timeoutSeconds | int | `5` |  |
| tolerations | list | `[]` |  |

## Examples

### Minimal Configuration with SQLite

```yaml
roundcube:
  defaultHost: "ssl://imap.gmail.com"
  defaultPort: 993
  smtpServer: "tls://smtp.gmail.com"
  smtpPort: 587

database:
  type: sqlite

persistence:
  enabled: true
```

### Production Configuration with External Database

```yaml
replicaCount: 3

roundcube:
  defaultHost: "ssl://mail.company.com"
  smtpServer: "tls://mail.company.com"

database:
  type: mysql
  external:
    host: mysql.company.local
    name: roundcube_prod
    user: roundcube
    existingSecret: roundcube-db-secret

redis:
  enabled: true
  host: redis.company.local

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: webmail.company.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: webmail-tls
      hosts:
        - webmail.company.com

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```

## Troubleshooting

### Logs

View Roundcube logs:

```bash
kubectl logs -l app.kubernetes.io/name=roundcube
```

### Database Connection Issues

If you're experiencing database connection issues:

1. Verify database credentials
2. Check network connectivity to database host
3. Ensure database exists and user has proper permissions

### Session Issues

If users are getting logged out frequently:

1. Enable Redis for session storage
2. Ensure all replicas can access the same session store
3. Check session timeout settings

## Support & Professional Services

### Community Support

For issues and questions about this Helm chart:
- Open an issue in [GitHub Issues](https://github.com/encircle360-oss/helm-charts/issues)
- Start a discussion in [GitHub Discussions](https://github.com/encircle360-oss/helm-charts/discussions)

For Roundcube specific issues:
- Visit the [Roundcube GitHub repository](https://github.com/roundcube/roundcubemail)
- Check the [Roundcube documentation](https://github.com/roundcube/roundcubemail/wiki)

### Professional Support

For professional support, consulting, custom development, or enterprise solutions, contact **hello@encircle360.com**

## Disclaimer

This Helm chart is provided "AS IS" without warranty of any kind. encircle360 GmbH and the contributors:
- Make no warranties about the completeness, reliability, or accuracy of this chart
- Are not liable for any damages arising from the use of this chart
- Recommend thorough testing in non-production environments before production use

Use this chart at your own risk. For production deployments with SLA requirements, consider our professional support services.

## License

This chart is licensed under the Apache License 2.0. See [LICENSE](https://github.com/encircle360-oss/helm-charts/blob/main/LICENSE) for details.