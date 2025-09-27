# encircle360 OSS Helm Charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/encircle360-oss)](https://artifacthub.io/packages/search?repo=encircle360-oss)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/encircle360-oss/helm-charts.svg?style=flat)](https://github.com/encircle360-oss/helm-charts/releases)

A collection of Helm charts for various open-source applications, maintained by encircle360 GmbH and the open source community.

**Documentation**: [https://encircle360-oss.github.io/helm-charts/](https://encircle360-oss.github.io/helm-charts/)

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
| [roundcube](./charts/roundcube) | A free and open source webmail solution | 0.2.0 | 1.6.11 |

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

## Support

- Create an [Issue](https://github.com/encircle360-oss/helm-charts/issues) for bug reports and feature requests
- Start a [Discussion](https://github.com/encircle360-oss/helm-charts/discussions) for questions and general support

## License

This repository is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Credits

Inspired by community best practices and other successful Helm chart repositories.
