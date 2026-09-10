#!/usr/bin/env bash
#
# Validate the TracingPolicy manifests in this repo against the Tetragon CRD
# schema using kubeconform. This catches schema-level errors (such as an
# unsupported matchArgs operator) that `kubectl kustomize` and a client-side
# dry-run do NOT catch, because those never consult the CRD schema.
#
# Pinned versions (single source of truth for both local and CI):
set -euo pipefail

TETRAGON_VERSION="${TETRAGON_VERSION:-v1.7.1}"

# Directory of this script, and repo root (its parent).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT

CRD_BASE="https://raw.githubusercontent.com/cilium/tetragon/${TETRAGON_VERSION}/pkg/k8s/apis/cilium.io/client/crds/v1alpha1"
CRD_FILES=(
  "cilium.io_tracingpolicies.yaml"
  "cilium.io_tracingpoliciesnamespaced.yaml"
  "cilium.io_podinfo.yaml"
)

echo "==> Checking prerequisites"
for tool in kubectl kubeconform python3; do
  if ! command -v "${tool}" >/dev/null 2>&1; then
    echo "error: '${tool}' not found on PATH." >&2
    case "${tool}" in
      kubeconform)
        echo "  Install it with: brew install kubeconform" >&2
        ;;
      kubectl)
        echo "  Install it with: brew install kubernetes-cli" >&2
        ;;
      python3)
        echo "  Install Python 3 (needed for CRD -> JSON schema conversion)." >&2
        ;;
    esac
    exit 1
  fi
done

echo "==> Building manifests with kustomize"
kubectl kustomize "${REPO_ROOT}" > "${WORK_DIR}/out.yaml"

echo "==> Downloading Tetragon ${TETRAGON_VERSION} CRDs"
mkdir -p "${WORK_DIR}/crds"
for crd in "${CRD_FILES[@]}"; do
  curl -fsSL "${CRD_BASE}/${crd}" -o "${WORK_DIR}/crds/${crd}"
done

echo "==> Converting CRDs to JSON schemas"
mkdir -p "${WORK_DIR}/schemas"
python3 "${SCRIPT_DIR}/openapi2jsonschema.py" \
  -o "${WORK_DIR}/schemas" \
  "${WORK_DIR}/crds/"*.yaml

echo "==> Running kubeconform"
# We validate each Kind against its own converted CRD schema.
#
# Why not a single templated -schema-location? kubeconform's Go-templated
# schema-location (e.g. '{{ .ResourceKind }}-{{ .Group }}-...json') does not
# reliably resolve local CRD schemas in the versions we target, so instead we
# pass one literal schema file per Kind and use -skip to restrict each pass to
# that Kind. This is robust and keeps kind-accurate matching.
#
# -strict rejects unknown/duplicate fields. We do NOT pass
# -ignore-missing-schemas: if a Kind has no matching CRD schema, that is a HARD
# failure so a typo'd or unexpected Kind can never silently pass validation.

# Distinct Kinds present in the built manifests.
mapfile -t KINDS < <(grep -E '^kind:' "${WORK_DIR}/out.yaml" | awk '{print $2}' | sort -u)

if [[ ${#KINDS[@]} -eq 0 ]]; then
  echo "error: no Kubernetes resources found in kustomize output" >&2
  exit 1
fi

# CRD API group/version these schemas were generated for.
CRD_GROUP_VERSION="cilium.io/v1alpha1"
CRD_VERSION="${CRD_GROUP_VERSION##*/}"
CRD_GROUP="${CRD_GROUP_VERSION%/*}"

overall_rc=0
for kind in "${KINDS[@]}"; do
  schema="${WORK_DIR}/schemas/${kind}-${CRD_GROUP}-${CRD_VERSION}.json"
  if [[ ! -f "${schema}" ]]; then
    echo "error: no schema found for Kind '${kind}' (expected ${schema##*/})" >&2
    echo "       the manifests contain a Kind not covered by the Tetragon CRDs." >&2
    overall_rc=1
    continue
  fi

  # Build a -skip list of every OTHER Kind, so this pass validates only ${kind}.
  skip=""
  for other in "${KINDS[@]}"; do
    [[ "${other}" == "${kind}" ]] && continue
    skip="${skip:+${skip},}${CRD_GROUP_VERSION}/${other}"
  done

  echo "--> Validating Kind '${kind}'"
  if [[ -n "${skip}" ]]; then
    kubeconform -strict -summary -skip "${skip}" \
      -schema-location "${schema}" "${WORK_DIR}/out.yaml" || overall_rc=1
  else
    kubeconform -strict -summary \
      -schema-location "${schema}" "${WORK_DIR}/out.yaml" || overall_rc=1
  fi
done

if [[ ${overall_rc} -ne 0 ]]; then
  echo "==> Validation FAILED" >&2
  exit 1
fi

echo "==> Validation passed"
