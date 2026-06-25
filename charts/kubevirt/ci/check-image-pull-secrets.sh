#!/usr/bin/env bash

set -euo pipefail

chart_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rendered="$(mktemp)"
trap 'rm -f "${rendered}"' EXIT

helm template kubevirt "${chart_dir}" \
  --set 'kubevirt.imagePullSecrets[0].name=valarian-registry' \
  > "${rendered}"

if ! yq -e '
  select(.kind == "KubeVirt" and .metadata.name == "kubevirt")
  | .spec.imagePullSecrets[]?
  | select(.name == "valarian-registry")
' "${rendered}" >/dev/null; then
  printf 'missing: KubeVirt.spec.imagePullSecrets valarian-registry\n' >&2
  exit 1
fi
