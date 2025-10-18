# CI Test Values

This directory contains values files that are automatically used by `chart-testing` during CI runs.

## Files

### `ci-values.yaml`

Test configuration for automated CI/CD pipelines. This file:

- **Skips KubeVirt CR deployment** (`kubevirt.deploy: false`)
  - The KubeVirt CRD doesn't exist in test clusters (Kind/K3s in CI)
  - The operator deployment is still tested
  - After the operator runs and creates CRDs, production deployments work normally

- **Reduces resource requests** for faster CI runs
  - Single operator replica instead of 2
  - Minimal memory/CPU for test environment

- **Disables optional features** not needed for testing
  - Monitoring (ServiceMonitor, PrometheusRule)

## How It Works

Chart Testing (`ct`) automatically discovers and uses values files in the `ci/` directory:

```bash
# During CI, chart-testing runs:
ct install --charts charts/kubevirt
# → Automatically uses charts/kubevirt/ci/*.yaml files
```

## Local Testing

You can use the same values locally to simulate CI:

```bash
# Test with CI values
helm install kubevirt ./charts/kubevirt \
  -f ./charts/kubevirt/ci/ci-values.yaml \
  --namespace kubevirt --create-namespace

# Or combine with custom values
helm install kubevirt ./charts/kubevirt \
  -f ./charts/kubevirt/ci/ci-values.yaml \
  -f my-values.yaml
```

## Production Deployment

**Do NOT use these values in production!**

For production, use the default values or create your own:

```bash
# Production installation (default values)
helm install kubevirt encircle360-oss/kubevirt \
  --namespace kubevirt --create-namespace

# Production with custom values
helm install kubevirt encircle360-oss/kubevirt \
  -f production-values.yaml \
  --namespace kubevirt --create-namespace
```

## References

- [Chart Testing Documentation](https://github.com/helm/chart-testing)
- [Helm Values Files](https://helm.sh/docs/chart_template_guide/values_files/)
