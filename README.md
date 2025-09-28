# encircle360 OSS Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/encircle360-oss)](https://artifacthub.io/packages/search?repo=encircle360-oss)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Release Charts](https://github.com/encircle360-oss/helm-charts/actions/workflows/release.yaml/badge.svg)](https://github.com/encircle360-oss/helm-charts/actions/workflows/release.yaml)
[![Deploy Documentation](https://github.com/encircle360-oss/helm-charts/actions/workflows/pages.yaml/badge.svg)](https://github.com/encircle360-oss/helm-charts/actions/workflows/pages.yaml)

A collection of Helm charts for various open-source applications, maintained and sponsored by [encircle360 GmbH](https://encircle360.com) together with the open source community, partners and friends.

**Documentation**: [https://encircle360-oss.github.io/helm-charts/docs/](https://encircle360-oss.github.io/helm-charts/docs/)

## Usage

### Add Helm Repository

```bash
helm repo add encircle360-oss https://encircle360-oss.github.io/helm-charts/
helm repo update
```

### Search for Charts

```bash
helm search repo encircle360-oss
```

### Install a Chart

```bash
helm install my-release encircle360-oss/<chart-name>
```

## Available Charts

| Chart | Description | Chart Version | App Version |
|-------|-------------|---------------|--------------|
| [cnpg-database-manager](./charts/cnpg-database-manager) | Multi-database and multi-tenant management for CloudNativePG | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/encircle360-oss/helm-charts/main/charts/cnpg-database-manager/Chart.yaml&query=$.version&label=chart&color=blue) | ![AppVersion](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/encircle360-oss/helm-charts/main/charts/cnpg-database-manager/Chart.yaml&query=$.appVersion&label=app&color=informational) |
| [roundcube](./charts/roundcube) | A free and open source webmail solution | ![Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/encircle360-oss/helm-charts/main/charts/roundcube/Chart.yaml&query=$.version&label=chart&color=blue) | ![AppVersion](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/encircle360-oss/helm-charts/main/charts/roundcube/Chart.yaml&query=$.appVersion&label=app&color=informational) |

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) >= 3.14.0
- [Kubernetes](https://kubernetes.io/) >= 1.27
- [ct (Chart Testing)](https://github.com/helm/chart-testing) for linting and testing
- [helm-docs](https://github.com/norwoodj/helm-docs) for generating chart documentation

### Testing Charts Locally

```bash
# Lint chart
helm lint charts/<chart-name>

# Test chart installation
helm install test-release charts/<chart-name> --debug --dry-run
```

### Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## Support & Professional Services

### Community Support

- **Chart Issues**: Create an [Issue](https://github.com/encircle360-oss/helm-charts/issues) for Helm chart bugs and feature requests
- **General Questions**: Start a [Discussion](https://github.com/encircle360-oss/helm-charts/discussions) for questions and general support
- **Application Bugs**: For bugs within the applications themselves (not chart-related), please report them to the respective upstream project:
  - CloudNativePG: [cloudnative-pg/cloudnative-pg](https://github.com/cloudnative-pg/cloudnative-pg/issues)
  - Roundcube: [roundcube/roundcubemail](https://github.com/roundcube/roundcubemail/issues)

### Professional Support

For professional support, consulting, custom development, or enterprise solutions, contact us at **hello@encircle360.com**

## Disclaimer

These Helm charts are provided "AS IS" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, or non-infringement.

While we strive to maintain high-quality charts and test them thoroughly, you acknowledge that:
- You use these charts at your own risk
- We recommend thorough testing in non-production environments before production deployment
- Charts may contain bugs or security vulnerabilities
- We are not liable for any damages or losses resulting from the use of these charts

For production deployments requiring guaranteed support and SLAs, please contact us about our professional services at **hello@encircle360.com**.

## License

This repository is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Maintainers

This project is maintained and sponsored by **[encircle360 GmbH](https://encircle360.com)**, providing enterprise-grade Kubernetes and cloud-native solutions.

## Credits

Thanks to all contributors, partners, and the open source community for making this project possible.
