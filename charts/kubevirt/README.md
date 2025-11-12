# kubevirt

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.6.3](https://img.shields.io/badge/AppVersion-v1.6.3-informational?style=flat-square)

KubeVirt - Virtual Machine Management on Kubernetes - Deploy and manage VMs as native Kubernetes resources

**Homepage:** <https://github.com/encircle360-oss/helm-charts/tree/main/charts/kubevirt>

> **⚠️ UNDER CONSTRUCTION**
> This chart is currently under active development and has not been battle-tested in production environments.
> **NOT PRODUCTION READY** - Use at your own risk and thoroughly test in non-production environments first.
> KubeVirt is a complex system requiring deep Kubernetes and virtualization knowledge. **Only use this chart if you are an experienced Kubernetes operator.**

## Description

KubeVirt is a Kubernetes add-on that enables you to run and manage virtual machines alongside container workloads. This Helm chart provides a deployment of KubeVirt v1.6.3 with comprehensive configuration options.

**Key Features:**
- Full KubeVirt v1.6.3 support with all feature gates
- Operator-based lifecycle management
- Comprehensive RBAC configuration
- Monitoring integration (ServiceMonitor & PrometheusRule)
- High availability configuration
- Extensive configuration options

## Prerequisites

- Kubernetes 1.30+ (vanilla Kubernetes, K3s, K0s, or OpenShift)
- Helm 3.8+
- Nodes with KVM support (hardware virtualization) OR software emulation enabled
- Sufficient cluster resources for VM workloads

> **Platform Compatibility:**
> This chart works on both vanilla Kubernetes (including K3s, K0s) and OpenShift.
> OpenShift-specific RBAC rules are included but will be safely ignored on non-OpenShift clusters.

**Check Node Virtualization Support:**
```bash
# Check if nodes have KVM support
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.devices\.kubevirt\.io/kvm}{"\n"}{end}'

# Verify KVM is available on nodes
kubectl debug node/<node-name> -it --image=ubuntu -- bash
apt update && apt install -y cpu-checker
kvm-ok
```

## Installation

### Quick Start

```bash
# Add the Helm repository
helm repo add encircle360-oss https://encircle360-oss.github.io/helm-charts
helm repo update

# Install KubeVirt
helm install kubevirt encircle360-oss/kubevirt \
  --namespace kubevirt \
  --create-namespace

# Wait for KubeVirt to be ready
kubectl wait kubevirt kubevirt -n kubevirt \
  --for=condition=Available \
  --timeout=10m
```

### Installation with Custom Values

```bash
helm install kubevirt encircle360-oss/kubevirt \
  --namespace kubevirt \
  --create-namespace \
  -f custom-values.yaml
```

### Install with Monitoring

```yaml
# values-monitoring.yaml
monitoring:
  enabled: true
  namespace: monitoring
  serviceAccount: prometheus-k8s
  prometheusRule:
    enabled: true
    labels:
      prometheus: kube-prometheus
```

```bash
helm install kubevirt encircle360-oss/kubevirt \
  -f values-monitoring.yaml \
  --namespace kubevirt \
  --create-namespace
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.enabled` | Enable KubeVirt deployment | `true` |
| `namespace.name` | Namespace for KubeVirt | `kubevirt` |
| `namespace.create` | Create the namespace | `true` |
| `operator.replicas` | Number of operator replicas | `2` |
| `operator.image.tag` | Operator image tag | `v1.6.3` |

### Feature Gates

KubeVirt uses feature gates to control optional functionality. Feature gates are categorized as:
- **Alpha**: Experimental features that must be explicitly enabled
- **Beta**: Features that are stable but may have limitations
- **GA**: Stable features (enabled by default, no gate needed)

#### Alpha Feature Gates (v1.6.3)

```yaml
kubevirt:
  configuration:
    developerConfiguration:
      featureGates:
        # Storage
        - ExpandDisks              # Dynamic disk expansion
        - HotplugVolumes           # Hot-plug/unplug volumes
        - HostDisk                 # Host disk access
        - ImageVolume              # Image volume support (New in v1.6.3)

        # Performance
        - CPUManager               # CPU pinning and NUMA topology
        - AlignCPUs                # Align guest and host CPU topology

        # Hardware
        - HostDevices              # PCI device passthrough
        - GPUsWithDRA              # GPU with Dynamic Resource Allocation (New in v1.6.3)
        - HostDevicesWithDRA       # Host devices with DRA (New in v1.6.3)

        # Security
        - WorkloadEncryptionSEV    # AMD SEV memory encryption
        - KubevirtSeccompProfile   # Custom seccomp profiles
        - SecureExecution          # IBM Secure Execution (New in v1.6.3)

        # Snapshot & Export
        - Snapshot                 # VM snapshot support (Beta since v1.6.3)
        - VMExport                 # VM export functionality (Beta since v1.6.3)

        # Networking
        - VSOCK                    # AF_VSOCK for host-guest communication
        - PasstIPStackMigration    # PASST IP stack migration (New in v1.6.3)

        # Other
        - ExperimentalIgnitionSupport  # Ignition config support
        - HypervStrictCheck        # Strict Hyper-V feature checking
        - Sidecar                  # Sidecar container injection
        - DownwardMetrics          # Expose metrics to VMs
        - Root                     # Run virt-launcher as root
        - DisableMDEVConfiguration # Disable automatic MDEV configuration
        - PersistentReservation    # SCSI persistent reservations
        - MultiArchitecture        # Multi-architecture support
        - NodeRestriction          # Node restriction (Beta since v1.6.3)
        - VirtIOFSConfigVolumesGate    # VirtioFS for config volumes
        - VirtIOFSStorageVolumeGate    # VirtioFS for storage volumes
        - DecentralizedLiveMigration   # Decentralized live migration
        - ObjectGraph              # Object graph feature (New in v1.6.3)
        - DeclarativeHotplugVolumes    # Declarative hotplug volumes
        - VideoConfig              # Video device configuration (New in v1.6.3)
        - PanicDevices             # Panic device support (New in v1.6.3)
```

#### GA Feature Gates (No Configuration Needed)

The following features are **stable and enabled by default** in v1.6.3. You do NOT need to specify these in feature gates:

- `LiveMigration` - Live migration of VMs
- `SRIOVLiveMigration` - Live migration with SR-IOV
- `NonRoot` - Run as non-root user
- `PSA` - Pod Security Admission
- `CPUNodeDiscovery` - CPU node discovery
- `NUMA` - NUMA topology support
- `GPU` - GPU passthrough
- `VMLiveUpdateFeatures` - Live update VM features (GA in v1.6.3)
- `CommonInstancetypesDeploymentGate` - Common instance types (GA in v1.6.3)
- `HotplugNICs` - Hot-plug network interfaces (GA in v1.6.3)
- `BochsDisplayForEFIGuests` - Bochs display for EFI (GA in v1.6.3)
- `AutoResourceLimitsGate` - Automatic resource limits (GA in v1.6.3)
- `NetworkBindingPlugins` - Network binding plugins (GA in v1.6.3)
- `DynamicPodInterfaceNaming` - Dynamic pod interface naming (GA in v1.6.3)
- `VolumesUpdateStrategy` - Volumes update strategy (GA in v1.6.3)
- `VolumeMigration` - Volume migration (GA in v1.6.3)
- `InstancetypeReferencePolicy` - Instance type reference policy (GA in v1.6.3)

### CPU Configuration

```yaml
kubevirt:
  configuration:
    # Default CPU model for VMs
    cpuModel: "host-passthrough"

    # Default CPU request
    cpuRequest: "100m"

    # Mark obsolete CPUs as unusable
    obsoleteCPUModels:
      pentium: true
      pentium2: true
      pentium3: true
      Conroe: true
      Penryn: true
```

### Network Configuration

```yaml
kubevirt:
  configuration:
    network:
      # Default network interface type
      defaultNetworkInterface: "masquerade"

      # Allow bridge on pod network
      permitBridgeInterfaceOnPodNetwork: false

      # Allow SLIRP interface
      permitSlirpInterface: false
```

### Live Migration Configuration

```yaml
kubevirt:
  configuration:
    migration:
      # Disable TLS (not recommended for production)
      disableTLS: false

      # Allow auto-converge for slow migrations
      allowAutoConverge: false

      # Bandwidth limit per migration
      bandwidthPerGiB: "64Mi"

      # Timeouts
      completionTimeoutPerGiB: 800
      progressTimeout: 150

      # Parallelism
      parallelMigrationsPerCluster: 5
      parallelOutboundMigrationsPerNode: 2

      # Post-copy migration (use with caution)
      allowPostCopy: false

      # Dedicated migration network
      network: ""
```

### Storage Configuration

```yaml
kubevirt:
  configuration:
    # Storage class for VM snapshots and state
    vmStateStorageClass: "standard"
```

### Host Device Passthrough

```yaml
kubevirt:
  configuration:
    permittedHostDevices:
      # PCI devices
      pciHostDevices:
        - pciVendorSelector: "10DE:1EB8"  # NVIDIA Tesla T4
          resourceName: "nvidia.com/T4"
        - pciVendorSelector: "8086:1572"  # Intel X710
          resourceName: "intel.com/X710"

      # Mediated devices (vGPU)
      mediatedDevices:
        - mdevNameSelector: "GRID T4-1Q"
          resourceName: "nvidia.com/GRID_T4-1Q"
```

### Node Placement

#### Infrastructure Components (virt-api, virt-controller)

```yaml
kubevirt:
  infra:
    nodePlacement:
      nodeSelector:
        node-role.kubernetes.io/control-plane: ""
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          effect: NoSchedule
```

#### Workload Components (virt-handler, virt-launcher)

```yaml
kubevirt:
  workloads:
    nodePlacement:
      nodeSelector:
        kubevirt.io/vm-workload: "true"
      tolerations:
        - key: kubevirt.io/vm-workload
          effect: NoSchedule
```

### Monitoring Configuration

```yaml
monitoring:
  enabled: true
  namespace: monitoring
  serviceAccount: prometheus-k8s

  serviceMonitorLabels:
    prometheus: kube-prometheus

  scrapeInterval: "30s"

  prometheusRule:
    enabled: true
    labels:
      prometheus: kube-prometheus

    # Add custom alerting rules
    additionalRules:
      - alert: MyCustomAlert
        expr: up == 0
        for: 5m
        labels:
          severity: critical
```

## Usage Examples

### Creating a Virtual Machine

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: ubuntu-vm
spec:
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/vm: ubuntu-vm
    spec:
      domain:
        devices:
          disks:
            - name: containerdisk
              disk:
                bus: virtio
            - name: cloudinitdisk
              disk:
                bus: virtio
        resources:
          requests:
            memory: 2Gi
            cpu: 2
      volumes:
        - name: containerdisk
          containerDisk:
            image: quay.io/containerdisks/ubuntu:22.04
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
              password: ubuntu
              chpasswd: { expire: False }
              ssh_pwauth: True
```

### Using virtctl

```bash
# Install virtctl
kubectl krew install virt

# Start/Stop VMs
kubectl virt start ubuntu-vm
kubectl virt stop ubuntu-vm
kubectl virt restart ubuntu-vm

# Console access
kubectl virt console ubuntu-vm

# VNC access
kubectl virt vnc ubuntu-vm

# SSH into VM (requires SSH service in VM)
kubectl virt ssh ubuntu@ubuntu-vm
```

### VM Snapshots (requires Snapshot feature gate)

```yaml
# Enable snapshot feature
kubevirt:
  configuration:
    developerConfiguration:
      featureGates:
        - Snapshot

# Create snapshot
apiVersion: snapshot.kubevirt.io/v1alpha1
kind: VirtualMachineSnapshot
metadata:
  name: ubuntu-vm-snapshot
spec:
  source:
    apiGroup: kubevirt.io
    kind: VirtualMachine
    name: ubuntu-vm
```

## Upgrading

### Upgrade the Chart

```bash
helm repo update
helm upgrade kubevirt encircle360-oss/kubevirt \
  --namespace kubevirt \
  -f values.yaml
```

### Upgrade Strategy

KubeVirt supports rolling updates of VMs during upgrades:

```yaml
kubevirt:
  workloadUpdateStrategy:
    workloadUpdateMethods:
      - LiveMigrate  # Try live migration first
      - Evict        # Fall back to eviction
    batchEvictionSize: 10
    batchEvictionInterval: "1m"
```

## Frequently Asked Questions (FAQ)

### Does this work on K3s/K0s/vanilla Kubernetes?

**Yes!** This chart is designed to work on:
- Vanilla Kubernetes (upstream)
- K3s (lightweight Kubernetes)
- K0s (zero friction Kubernetes)
- MicroK8s
- OpenShift/OKD

The chart includes OpenShift-specific RBAC rules, but these are **safely ignored** on non-OpenShift clusters.

### Why are there OpenShift resources in the RBAC?

KubeVirt officially supports both vanilla Kubernetes and OpenShift. The OpenShift-specific resources (`security.openshift.io/securitycontextconstraints`, `route.openshift.io/routes`) are:
- **Optional** and only used on OpenShift
- **Ignored** on vanilla Kubernetes/K3s (API groups don't exist)
- **Standard practice** in the official KubeVirt manifests

Your K3s cluster will simply skip these rules - no issues!

### Why do some labels have empty values like `operator.kubevirt.io: ""`?

This is **valid and intentional** in Kubernetes! Empty-string label values are used as:
- **Marker labels**: Indicate that something is tagged without needing a specific value
- **Selector labels**: Can be matched with `matchLabels: { "operator.kubevirt.io": "" }`
- **KubeVirt convention**: How KubeVirt identifies its own resources internally

### Do I need hardware virtualization (KVM)?

**Recommended but not required:**
- **With KVM** (hardware virtualization): Full performance VMs
- **Without KVM** (software emulation): Slower VMs using QEMU emulation

Enable software emulation if nodes lack KVM:
```yaml
kubevirt:
  configuration:
    developerConfiguration:
      useEmulation: true
```

### Can I run this on ARM64 nodes?

Yes, with limitations. Enable the `MultiArchitecture` feature gate:
```yaml
kubevirt:
  configuration:
    developerConfiguration:
      featureGates:
        - MultiArchitecture
```

Note: Not all VM images support ARM64.

## Troubleshooting

### Check Installation Status

```bash
# Check KubeVirt CR
kubectl get kubevirt -n kubevirt

# Check all components
kubectl get pods -n kubevirt

# Check operator logs
kubectl logs -n kubevirt deployment/virt-operator

# Check virt-handler logs
kubectl logs -n kubevirt daemonset/virt-handler
```

### Common Issues

#### 1. Nodes without KVM support

**Error:** VMs fail to start with "KVM not available"

**Solution:** Enable software emulation (not recommended for production):

```yaml
kubevirt:
  configuration:
    developerConfiguration:
      useEmulation: true
```

#### 2. VM fails to start due to CPU model

**Error:** "Requested CPU model is not supported"

**Solution:** Use a more compatible CPU model:

```yaml
kubevirt:
  configuration:
    cpuModel: "host-passthrough"
```

#### 3. Migration failures

**Error:** "Migration failed due to incompatible nodes"

**Solution:** Ensure nodes have compatible CPU features or use live migration policies.

### Debug Commands

```bash
# Describe VM
kubectl describe vm <vm-name>

# Describe VMI (running instance)
kubectl describe vmi <vm-name>

# Check virt-launcher logs
kubectl logs <virt-launcher-pod>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

## Uninstallation

```bash
# Delete all VMs first
kubectl delete vms --all -A

# Uninstall the chart
helm uninstall kubevirt -n kubevirt

# Delete namespace (if desired)
kubectl delete namespace kubevirt
```

**Note:** By default, CRDs are kept on uninstallation to prevent data loss.

## Migration from Raw Manifests

If you're currently using raw KubeVirt manifests:

1. **Export current configuration:**
   ```bash
   kubectl get kubevirt kubevirt -n kubevirt -o yaml > current-config.yaml
   ```

2. **Create values.yaml from current config:**
   Review your current KubeVirt CR and translate settings to Helm values.

3. **Uninstall existing KubeVirt:**
   ```bash
   kubectl delete kubevirt kubevirt -n kubevirt
   kubectl delete deployment virt-operator -n kubevirt
   ```

4. **Install using Helm:**
   ```bash
   helm install kubevirt encircle360-oss/kubevirt \
     -f values.yaml \
     --namespace kubevirt
   ```

## Breaking Changes

### v1.6.3 → v1.6.x

- **VirtualMachineInstanceMigration RBAC**: Namespace admins no longer have default permissions to create/edit/delete migrations. Grant explicitly if needed.

## Resources

- [KubeVirt Documentation](https://kubevirt.io/user-guide/)
- [KubeVirt API Reference](https://kubevirt.io/api-reference/)
- [Feature Gates Documentation](https://kubevirt.io/user-guide/operations/activating_feature_gates/)
- [Chart Repository](https://github.com/encircle360-oss/helm-charts)
- [Issue Tracker](https://github.com/encircle360-oss/helm-charts/issues)

## Contributing & Maintainership

### We Welcome Contributors! 🎉

We're actively seeking contributors and co-maintainers for this KubeVirt chart! Whether you want to:
- **Become a co-maintainer** for this chart
- **Submit pull requests** for bug fixes, features, or documentation improvements
- **Help with testing** virtualization features and VM workloads
- **Improve documentation** with real-world VM deployment examples
- **Share your virtualization and KubeVirt expertise** with the community

**Your expertise is valuable!** Whether you're a virtualization expert, a KubeVirt user, or someone passionate about running VMs on Kubernetes - we'd love your contribution.

### Become a Chart Co-Maintainer

Interested in becoming a co-maintainer for this KubeVirt chart? We'd be excited to collaborate!

**What we're looking for:**
- Experience with virtualization (KVM, QEMU, libvirt) or KubeVirt
- Strong Kubernetes and Helm knowledge
- Understanding of VM networking, storage, and live migration
- Willingness to review PRs and help with issues
- Passion for bringing virtualization to Kubernetes

**How to get involved:**
- Start by contributing PRs or helping in issues/discussions
- Reach out to us at **oss@encircle360.com** expressing your interest
- We'll work together to onboard you as a co-maintainer

We especially welcome virtualization experts who can help users successfully run VMs on Kubernetes!

## Support & Professional Services

### Community Support

For issues and questions about this Helm chart:
- Open an issue in [GitHub Issues](https://github.com/encircle360-oss/helm-charts/issues)
- Start a discussion in [GitHub Discussions](https://github.com/encircle360-oss/helm-charts/discussions)

For KubeVirt specific issues:
- Visit the [KubeVirt GitHub repository](https://github.com/kubevirt/kubevirt)
- Check the [KubeVirt documentation](https://kubevirt.io/user-guide/)
- Join the [KubeVirt Slack channel](https://kubernetes.slack.com/messages/virtualization)

### Professional Support

For professional support, consulting, custom development, or enterprise solutions, contact **hello@encircle360.com**

## Disclaimer

**⚠️ This chart is under active development and NOT production-ready.**

This Helm chart is provided "AS IS" without warranty of any kind. encircle360 GmbH and the contributors:
- Make no warranties about the completeness, reliability, or accuracy of this chart
- Are not liable for any damages arising from the use of this chart
- **Strongly recommend thorough testing in non-production environments only**
- Do not recommend this chart for production use at this time
- **This chart requires expert-level Kubernetes and virtualization knowledge**

Use this chart at your own risk. For production-ready virtualization solutions with SLA requirements, contact our professional support services at **hello@encircle360.com**

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| encircle360-oss | <oss@encircle360.com> |  |

## Source Code

* <https://github.com/encircle360-oss/helm-charts>
* <https://github.com/kubevirt/kubevirt>
* <https://kubevirt.io>

## Requirements

Kubernetes: `>=1.30.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global | object | `{"enabled":true}` | Global configuration |
| global.enabled | bool | `true` | Enable deployment of KubeVirt |
| kubevirt | object | `{"annotations":{},"certificateRotateStrategy":{"selfSigned":{"caOverlapInterval":"168h","caRotateInterval":"168h","certRotateInterval":"168h"}},"configuration":{"cpuModel":"","cpuRequest":"","developerConfiguration":{"featureGates":null,"useEmulation":false},"instancetype":{"referencePolicy":"reference"},"migration":{"allowAutoConverge":false,"allowPostCopy":false,"bandwidthPerGiB":"64Mi","completionTimeoutPerGiB":800,"disableTLS":false,"network":"","nodeDrainTaintKey":"kubevirt.io/drain","parallelMigrationsPerCluster":5,"parallelOutboundMigrationsPerNode":2,"progressTimeout":150,"unsafeMigrationOverride":false},"network":{"binding":{},"defaultNetworkInterface":"masquerade","permitBridgeInterfaceOnPodNetwork":false,"permitSlirpInterface":false},"obsoleteCPUModels":{},"permittedHostDevices":{"mediatedDevices":[],"pciHostDevices":[]},"selinuxLauncherType":"virt_launcher.process","smbios":{},"vmStateStorageClass":""},"deploy":true,"image":{"pullPolicy":"IfNotPresent","registry":"","tag":""},"infra":{"nodePlacement":{"affinity":{},"nodeSelector":{},"tolerations":[]}},"labels":{},"name":"kubevirt","workloadUpdateStrategy":{"batchEvictionInterval":"1m","batchEvictionSize":10,"workloadUpdateMethods":[]},"workloads":{"nodePlacement":{"affinity":{},"nodeSelector":{},"tolerations":[]}}}` | KubeVirt CR configuration |
| kubevirt.annotations | object | `{}` | Custom annotations for KubeVirt CR |
| kubevirt.certificateRotateStrategy | object | `{"selfSigned":{"caOverlapInterval":"168h","caRotateInterval":"168h","certRotateInterval":"168h"}}` | Certificate rotation strategy |
| kubevirt.certificateRotateStrategy.selfSigned.caOverlapInterval | string | `"168h"` | CA overlap interval (duration the old CA is kept) |
| kubevirt.certificateRotateStrategy.selfSigned.caRotateInterval | string | `"168h"` | CA rotation interval |
| kubevirt.certificateRotateStrategy.selfSigned.certRotateInterval | string | `"168h"` | Certificate rotation interval |
| kubevirt.configuration | object | `{"cpuModel":"","cpuRequest":"","developerConfiguration":{"featureGates":null,"useEmulation":false},"instancetype":{"referencePolicy":"reference"},"migration":{"allowAutoConverge":false,"allowPostCopy":false,"bandwidthPerGiB":"64Mi","completionTimeoutPerGiB":800,"disableTLS":false,"network":"","nodeDrainTaintKey":"kubevirt.io/drain","parallelMigrationsPerCluster":5,"parallelOutboundMigrationsPerNode":2,"progressTimeout":150,"unsafeMigrationOverride":false},"network":{"binding":{},"defaultNetworkInterface":"masquerade","permitBridgeInterfaceOnPodNetwork":false,"permitSlirpInterface":false},"obsoleteCPUModels":{},"permittedHostDevices":{"mediatedDevices":[],"pciHostDevices":[]},"selinuxLauncherType":"virt_launcher.process","smbios":{},"vmStateStorageClass":""}` | Main configuration section |
| kubevirt.configuration.cpuModel | string | `""` | Default CPU model for VMs when not specified Example: "host-passthrough", "host-model", "Penryn", "IvyBridge", etc. |
| kubevirt.configuration.cpuRequest | string | `""` | Default CPU request for VMs when not specified Example: "100m" or "1" (1 core) |
| kubevirt.configuration.developerConfiguration | object | `{"featureGates":null,"useEmulation":false}` | Developer configuration |
| kubevirt.configuration.developerConfiguration.featureGates | string | `nil` | Feature gates configuration Feature gates control optional KubeVirt features See: https://kubevirt.io/user-guide/operations/activating_feature_gates/ |
| kubevirt.configuration.developerConfiguration.useEmulation | bool | `false` | Use QEMU software emulation instead of KVM hardware virtualization Useful for testing on non-virtualization-capable nodes |
| kubevirt.configuration.instancetype | object | `{"referencePolicy":"reference"}` | Instancetype configuration |
| kubevirt.configuration.instancetype.referencePolicy | string | `"reference"` | Reference policy for instance types Options: "reference" (default), "expand", "expandAll" - reference: Store only reference to instancetype - expand: Expand instancetype into VM spec once - expandAll: Always expand instancetype |
| kubevirt.configuration.migration | object | `{"allowAutoConverge":false,"allowPostCopy":false,"bandwidthPerGiB":"64Mi","completionTimeoutPerGiB":800,"disableTLS":false,"network":"","nodeDrainTaintKey":"kubevirt.io/drain","parallelMigrationsPerCluster":5,"parallelOutboundMigrationsPerNode":2,"progressTimeout":150,"unsafeMigrationOverride":false}` | Live migration configuration |
| kubevirt.configuration.migration.allowAutoConverge | bool | `false` | Allow auto-converge for slow migrations |
| kubevirt.configuration.migration.allowPostCopy | bool | `false` | Allow post-copy migration (use with caution) |
| kubevirt.configuration.migration.bandwidthPerGiB | string | `"64Mi"` | Network bandwidth limit per migration |
| kubevirt.configuration.migration.completionTimeoutPerGiB | int | `800` | Migration completion timeout per GiB of memory |
| kubevirt.configuration.migration.disableTLS | bool | `false` | Disable TLS for migrations (not recommended for production) |
| kubevirt.configuration.migration.network | string | `""` | Dedicated migration network (optional) Example: "migration-network" |
| kubevirt.configuration.migration.nodeDrainTaintKey | string | `"kubevirt.io/drain"` | Node drain taint key |
| kubevirt.configuration.migration.parallelMigrationsPerCluster | int | `5` | Maximum number of parallel migrations in the cluster |
| kubevirt.configuration.migration.parallelOutboundMigrationsPerNode | int | `2` | Maximum number of parallel outbound migrations per node |
| kubevirt.configuration.migration.progressTimeout | int | `150` | Progress timeout in seconds |
| kubevirt.configuration.migration.unsafeMigrationOverride | bool | `false` | Unsafe migration override (allows migrations in unsafe conditions) |
| kubevirt.configuration.network | object | `{"binding":{},"defaultNetworkInterface":"masquerade","permitBridgeInterfaceOnPodNetwork":false,"permitSlirpInterface":false}` | Network configuration |
| kubevirt.configuration.network.binding | object | `{}` | Network binding plugins configuration |
| kubevirt.configuration.network.defaultNetworkInterface | string | `"masquerade"` | Default network interface type Options: "masquerade", "bridge", "slirp" |
| kubevirt.configuration.network.permitBridgeInterfaceOnPodNetwork | bool | `false` | Permit bridge interface on pod network |
| kubevirt.configuration.network.permitSlirpInterface | bool | `false` | Permit SLIRP interface |
| kubevirt.configuration.obsoleteCPUModels | object | `{}` | Obsolete CPU models that should not be used These CPUs are considered too old and potentially insecure |
| kubevirt.configuration.permittedHostDevices | object | `{"mediatedDevices":[],"pciHostDevices":[]}` | Permitted host devices for passthrough |
| kubevirt.configuration.permittedHostDevices.mediatedDevices | list | `[]` | Mediated devices (vGPU, etc.) |
| kubevirt.configuration.permittedHostDevices.pciHostDevices | list | `[]` | PCI host devices |
| kubevirt.configuration.selinuxLauncherType | string | `"virt_launcher.process"` | SELinux configuration |
| kubevirt.configuration.smbios | object | `{}` | SMBIOS configuration (system information exposed to VMs) |
| kubevirt.configuration.vmStateStorageClass | string | `""` | Storage class for VM state (snapshots, etc.) |
| kubevirt.deploy | bool | `true` | Deploy KubeVirt Custom Resource (disable for CI tests or when CRDs don't exist yet) |
| kubevirt.image | object | `{"pullPolicy":"IfNotPresent","registry":"","tag":""}` | Image configuration for KubeVirt components |
| kubevirt.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubevirt.image.registry | string | `""` | Custom image registry (leave empty to use default quay.io/kubevirt) |
| kubevirt.image.tag | string | `""` | Custom image tag (leave empty to use operator's default) |
| kubevirt.infra | object | `{"nodePlacement":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Infrastructure components placement (virt-api, virt-controller) |
| kubevirt.infra.nodePlacement | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Node placement configuration for infrastructure components |
| kubevirt.infra.nodePlacement.affinity | object | `{}` | Affinity rules |
| kubevirt.infra.nodePlacement.nodeSelector | object | `{}` | Node selector |
| kubevirt.infra.nodePlacement.tolerations | list | `[]` | Tolerations |
| kubevirt.labels | object | `{}` | Custom labels for KubeVirt CR |
| kubevirt.name | string | `"kubevirt"` | Name of the KubeVirt CR |
| kubevirt.workloadUpdateStrategy | object | `{"batchEvictionInterval":"1m","batchEvictionSize":10,"workloadUpdateMethods":[]}` | Workload update strategy |
| kubevirt.workloadUpdateStrategy.batchEvictionInterval | string | `"1m"` | Interval between batch evictions |
| kubevirt.workloadUpdateStrategy.batchEvictionSize | int | `10` | Number of VMs to evict in parallel during updates |
| kubevirt.workloadUpdateStrategy.workloadUpdateMethods | list | `[]` | Workload update methods Options: "LiveMigrate", "Evict" |
| kubevirt.workloads | object | `{"nodePlacement":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Workload components placement (virt-handler, virt-launcher) |
| kubevirt.workloads.nodePlacement | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Node placement configuration for workload components |
| kubevirt.workloads.nodePlacement.affinity | object | `{}` | Affinity rules |
| kubevirt.workloads.nodePlacement.nodeSelector | object | `{}` | Node selector |
| kubevirt.workloads.nodePlacement.tolerations | list | `[]` | Tolerations |
| monitoring | object | `{"enabled":false,"namespace":"monitoring","prometheusRule":{"additionalRules":[],"enabled":false,"labels":{}},"scrapeInterval":"30s","serviceAccount":"prometheus-k8s","serviceMonitorLabels":{},"serviceMonitorNamespace":""}` | Monitoring configuration |
| monitoring.enabled | bool | `false` | Enable monitoring (ServiceMonitor and PrometheusRule) |
| monitoring.namespace | string | `"monitoring"` | Namespace where Prometheus is installed |
| monitoring.prometheusRule | object | `{"additionalRules":[],"enabled":false,"labels":{}}` | PrometheusRule configuration |
| monitoring.prometheusRule.additionalRules | list | `[]` | Custom alerting rules Add your custom Prometheus alerting rules here |
| monitoring.prometheusRule.enabled | bool | `false` | Enable PrometheusRule |
| monitoring.prometheusRule.labels | object | `{}` | Additional labels for PrometheusRule |
| monitoring.scrapeInterval | string | `"30s"` | Scrape interval for metrics |
| monitoring.serviceAccount | string | `"prometheus-k8s"` | ServiceAccount used by Prometheus |
| monitoring.serviceMonitorLabels | object | `{}` | Additional labels for ServiceMonitor |
| monitoring.serviceMonitorNamespace | string | `""` | Namespace for ServiceMonitor resource Leave empty to deploy in the same namespace as KubeVirt |
| namespace | object | `{"name":"kubevirt"}` | Namespace configuration |
| namespace.name | string | `"kubevirt"` | Name of the namespace for KubeVirt installation |
| operator | object | `{"affinity":{},"enabled":true,"image":{"pullPolicy":"IfNotPresent","registry":"quay.io","repository":"kubevirt/virt-operator","tag":"v1.6.3"},"imagePullSecrets":[],"nodeSelector":{},"podAnnotations":{},"priorityClassName":"kubevirt-cluster-critical","replicas":2,"resources":{"limits":{"cpu":"1000m","memory":"450Mi"},"requests":{"cpu":"10m","memory":"450Mi"}},"tolerations":[]}` | KubeVirt Operator configuration |
| operator.affinity | object | `{}` | Affinity rules for operator pods Default: pod anti-affinity for better distribution across nodes Set to {} to use template defaults or override with custom affinity |
| operator.enabled | bool | `true` | Enable operator deployment |
| operator.image | object | `{"pullPolicy":"IfNotPresent","registry":"quay.io","repository":"kubevirt/virt-operator","tag":"v1.6.3"}` | Operator container image configuration |
| operator.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| operator.image.registry | string | `"quay.io"` | Image registry |
| operator.image.repository | string | `"kubevirt/virt-operator"` | Image repository |
| operator.image.tag | string | `"v1.6.3"` | Image tag (defaults to chart appVersion) |
| operator.imagePullSecrets | list | `[]` | Image pull secrets for private registries |
| operator.nodeSelector | object | `{}` | Node selector for operator pods (default: kubernetes.io/os: linux) Set to {} to use template defaults or override with custom selectors |
| operator.podAnnotations | object | `{}` | Pod annotations (e.g., for OpenShift: openshift.io/required-scc: restricted-v2) |
| operator.priorityClassName | string | `"kubevirt-cluster-critical"` | Priority class for operator pods |
| operator.replicas | int | `2` | Number of operator replicas |
| operator.resources | object | `{"limits":{"cpu":"1000m","memory":"450Mi"},"requests":{"cpu":"10m","memory":"450Mi"}}` | Resource limits and requests for operator |
| operator.tolerations | list | `[]` | Tolerations for operator pods (default: CriticalAddonsOnly) Set to [] to use template defaults or override with custom tolerations |
| priorityClass | object | `{"create":true,"description":"This priority class should be used for core kubevirt components only.","globalDefault":false,"name":"kubevirt-cluster-critical","value":1000000000}` | Priority class configuration |
| priorityClass.create | bool | `true` | Create priority class |
| priorityClass.description | string | `"This priority class should be used for core kubevirt components only."` | Description |
| priorityClass.globalDefault | bool | `false` | Global default (not recommended for KubeVirt) |
| priorityClass.name | string | `"kubevirt-cluster-critical"` | Priority class name |
| priorityClass.value | int | `1000000000` | Priority value (higher = more important) |
| rbac | object | `{"create":true}` | RBAC configuration |
| rbac.create | bool | `true` | Create RBAC resources |
