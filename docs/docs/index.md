# encircle360 OSS Helm Charts

Welcome to the encircle360 OSS Helm Charts repository! This collection provides production-ready open source Helm charts for deploying various applications on Kubernetes, maintained by encircle360 GmbH.

## Available Charts

| Chart | Description | Version |
|-------|-------------|---------|
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

We welcome contributions! Please see our [Contributing Guide](https://github.com/encircle360-oss/helm-charts/blob/main/CONTRIBUTING.md) for details.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](https://github.com/encircle360-oss/helm-charts/blob/main/LICENSE) file for details.

## Maintainer

These charts are maintained by **encircle360 GmbH**, providing enterprise-grade open source Helm charts for the community.

## Support

If you encounter any problems or have questions, please:

1. Check the [documentation](https://encircle360-oss.github.io/helm-charts/)
2. Search through [existing issues](https://github.com/encircle360-oss/helm-charts/issues)
3. Open a [new issue](https://github.com/encircle360-oss/helm-charts/issues/new) if needed

## Chart Sources

The source code for all charts can be found in the [charts directory](https://github.com/encircle360-oss/helm-charts/tree/main/charts) of our repository.