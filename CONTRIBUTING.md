# Contributing to Encircle360 OSS Helm Charts

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Pull Request Process

1. Update the README.md with details of changes if applicable.
2. Update the chart version following [SemVer](https://semver.org/) versioning scheme.
3. The PR will be merged once you have the sign-off of at least one maintainer.

## Chart Guidelines

### General

- Charts should follow [Helm best practices](https://helm.sh/docs/chart_best_practices/).
- Must pass `helm lint`.
- Must include a `values.yaml` with sensible defaults.
- Must include a comprehensive `README.md` (use `helm-docs` to generate).
- Should support the latest stable Kubernetes version.

### Structure

```
charts/<chart-name>/
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default configuration values
├── README.md           # Chart documentation (auto-generated)
├── templates/           # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── pvc.yaml
│   ├── NOTES.txt
│   └── _helpers.tpl
└── ci/                  # CI test values
    └── test-values.yaml
```

### Naming Conventions

- Chart names should be lowercase and use hyphens (e.g., `my-app`).
- Template names should be descriptive and follow the pattern: `<chart-name>.<component>`.
- Labels should follow [Kubernetes recommendations](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/).

### Documentation

Each chart must have:
- Detailed `README.md` with installation instructions, configuration options, and examples.
- Inline comments in `values.yaml` explaining each option.
- `NOTES.txt` template with post-installation instructions.

### Testing

Before submitting a PR:

```bash
# Lint the chart
helm lint charts/<chart-name>

# Test rendering with default values
helm template charts/<chart-name>

# Test rendering with custom values
helm template charts/<chart-name> -f charts/<chart-name>/ci/test-values.yaml

# Dry-run installation
helm install test-release charts/<chart-name> --debug --dry-run
```

## Any contributions you make will be under the Apache 2.0 Software License

When you submit code changes, your submissions are understood to be under the same [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0) that covers the project.

## Report bugs using GitHub's [issues](https://github.com/encircle360-oss/helm-charts/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/encircle360-oss/helm-charts/issues/new).

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## License

By contributing, you agree that your contributions will be licensed under its Apache 2.0 License.
