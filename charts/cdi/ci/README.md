# CI Test Values

This directory contains values files that are automatically used by `chart-testing` during CI runs.

## Files

### `ci-values.yaml`

Test configuration for automated CI/CD pipelines. This file:

- **Skips CDI CR deployment** (`cdi.deploy: false`)
  - The CDI CRD doesn't exist in test clusters (Kind/K3s in CI)
  - The operator deployment is still tested
  - After the operator runs and creates CRDs, production deployments work normally

- **Reduces resource requests** for faster CI runs
  - Single operator replica
  - Minimal memory/CPU for test environment

## How It Works

Chart Testing (`ct`) automatically discovers and uses values files in the `ci/` directory:

```bash
# During CI, chart-testing runs:
ct install --charts charts/cdi
# -> Automatically uses charts/cdi/ci/*.yaml files
```

## Local Testing

You can use the same values locally to simulate CI:

```bash
# Test with CI values
helm install cdi ./charts/cdi \
  -f ./charts/cdi/ci/ci-values.yaml \
  --namespace cdi --create-namespace

# Or combine with custom values
helm install cdi ./charts/cdi \
  -f ./charts/cdi/ci/ci-values.yaml \
  -f my-values.yaml
```

## Production Deployment

**Do NOT use these values in production!**

For production, the first install requires two steps (CRD must be registered before CR can be deployed):

```bash
# Step 1: Install operator + CRD only
helm install cdi encircle360-oss/cdi \
  --namespace cdi --create-namespace \
  --set cdi.deploy=false

# Step 2: Enable CDI CR (subsequent upgrades work with a single command)
helm upgrade cdi encircle360-oss/cdi \
  --namespace cdi \
  -f production-values.yaml
```

## References

- [Chart Testing Documentation](https://github.com/helm/chart-testing)
- [Helm Values Files](https://helm.sh/docs/chart_template_guide/values_files/)
