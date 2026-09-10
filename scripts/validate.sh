#!/usr/bin/env bash
set -euo pipefail

# Validate the policies against the Tetragon CRD schema with kubeconform.
#
# Note: this replaces the previous `kubectl apply --dry-run=client` check.
# A client-side dry-run does NOT validate against CRD schemas, so it could
# not catch errors like an unsupported matchArgs operator. kubeconform,
# fed the Tetragon CRD schema, does catch them.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/kubeconform-validate.sh"
