# encircle360 OSS Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/encircle360-oss)](https://artifacthub.io/packages/search?repo=encircle360-oss)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Release Charts](https://github.com/encircle360-oss/helm-charts/actions/workflows/release.yaml/badge.svg)](https://github.com/encircle360-oss/helm-charts/actions/workflows/release.yaml)
[![Deploy Documentation](https://github.com/encircle360-oss/helm-charts/actions/workflows/pages.yaml/badge.svg)](https://github.com/encircle360-oss/helm-charts/actions/workflows/pages.yaml)

Welcome to the encircle360 OSS Helm Charts repository! This collection provides production-ready open source Helm charts for deploying various applications on Kubernetes, maintained and sponsored by [encircle360 GmbH](https://encircle360.com) together with the open source community, partners and friends.

**Documentation**: [https://encircle360-oss.github.io/helm-charts/docs/](https://encircle360-oss.github.io/helm-charts/docs/)

## Available Charts

| Chart | Description | Version |
|-------|-------------|---------|
| [CNPG Database Manager](charts/cnpg-database-manager.md) | Multi-database and multi-tenant management for CloudNativePG clusters | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/encircle360-oss/helm-charts/main/charts/cnpg-database-manager/Chart.yaml&query=$.version&label=version) |
| [Roundcube](charts/roundcube.md) | A free and open source webmail solution with a desktop-like user interface | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/encircle360-oss/helm-charts/main/charts/roundcube/Chart.yaml&query=$.version&label=version) |

## Installation

### Add the Repository

```bash
helm repo add encircle360 https://encircle360-oss.github.io/helm-charts
helm repo update
```

### Install a Chart

```bash
# Install Roundcube
helm install my-roundcube encircle360/roundcube

# Install CNPG Database Manager
helm install my-databases encircle360/cnpg-database-manager
```

## Configuration

Each chart comes with a `values.yaml` file that contains the default configuration. You can override these values by:

1. Using a custom values file:
```bash
helm install my-release encircle360/chart-name -f my-values.yaml
```

2. Using `--set` flags:
```bash
helm install my-release encircle360/chart-name --set key=value
```

## Requirements

- Kubernetes 1.19+
- Helm 3.8.0+

## Contributing

We welcome contributions from the community! Please see our [Contributing Guide](https://github.com/encircle360-oss/helm-charts/blob/main/CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](https://github.com/encircle360-oss/helm-charts/blob/main/LICENSE) file for details.

## Maintainers & Sponsors

This project is maintained and sponsored by **[encircle360 GmbH](https://encircle360.com)**, providing enterprise-grade Kubernetes and cloud-native solutions. We work together with our community, partners, and friends to deliver high-quality Helm charts.

## Support & Professional Services

### Community Support

- **Chart Issues**: For Helm chart bugs and feature requests, [create an issue](https://github.com/encircle360-oss/helm-charts/issues)
- **General Questions**: For questions and discussions, use [GitHub Discussions](https://github.com/encircle360-oss/helm-charts/discussions)
- **Application Bugs**: For bugs within the applications themselves (not chart-related), please report them to the respective upstream project

### Professional Support

For professional support, consulting, custom development, or enterprise solutions, contact us at **hello@encircle360.com**

## Disclaimer

These Helm charts are provided "AS IS" without warranty of any kind. While we strive to maintain high-quality charts and test them thoroughly:

- You use these charts at your own risk
- We recommend thorough testing in non-production environments first
- Charts may contain bugs or security vulnerabilities
- We are not liable for any damages or losses resulting from the use of these charts

For production deployments requiring guaranteed support and SLAs, please contact us about our professional services.

## Chart Sources

The source code for all charts can be found in the [charts directory](https://github.com/encircle360-oss/helm-charts/tree/main/charts) of our repository.