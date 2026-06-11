# Tetragon configuration

This folder contains the runtime deployment artifacts for Tetragon in this repository.

## Files

- `kustomization.yaml`: Kustomize application that deploys the Tetragon Helm chart, persistent storage, Prometheus scrape support, and active SI-3 policies. Includes parameterization for all supporting resources.
- `values.yaml`: Helm chart values for the Tetragon agent/operator, export persistence, and infrastructure configuration (namespaces, storage, metrics settings).
- `tetragon.yaml`: runtime Tetragon configuration sample for direct config mounting or chart-value translation.
- `argocd-application.yaml`: example ArgoCD Application manifest for deploying this folder.
- `netpol.yaml`, `pvc.yaml`, `servicemonitor.yaml`, `poddisruptionbudget.yaml`: Supporting Kubernetes resources, parameterized via Kustomize vars.

## Parameterization

All infrastructure values (namespaces, storage size/class, metrics ports, etc.) are configured in two places:

1. **values.yaml** `infrastructure` section: Document and describe your settings
2. **kustomization.yaml** `configMapGenerator`: Actual deployed values (overrides values.yaml for immediate use)

To customize deployment, edit the `literals` section in `kustomization.yaml` under `configMapGenerator`. Changes propagate to all supporting resources.

**Example customizations:**
```yaml
configMapGenerator:
  - name: tetragon-config
    literals:
      - tetragonNamespace=security-system      # Change deployment namespace
      - storageClassName=standard-rwo          # Use different storage class
      - prometheusNamespace=monitoring         # Point to different Prometheus
      - pdbMinAvailable=2                      # Increase pod resilience
```

Active SI-3 policy definitions are sourced from `../si-3` and are included in the Kustomize application.

The current files are intended to be a cleaned and cluster-appropriate replacement for generic upstream runtime templates.
