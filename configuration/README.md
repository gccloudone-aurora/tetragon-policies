# Tetragon configuration

This folder contains the runtime deployment artifacts for Tetragon in this repository.

- `kustomization.yaml`: Kustomize application that deploys the Tetragon Helm chart, persistent storage, Prometheus scrape support, and active SI-3 policies.
- `values.yaml`: Helm chart values for the Tetragon agent/operator and export persistence.
- `tetragon.yaml`: runtime Tetragon configuration sample for direct config mounting or chart-value translation.
- `argocd-application.yaml`: example ArgoCD Application manifest for deploying this folder.

Active SI-3 policy definitions are sourced from `../si-3` and are included in the Kustomize application.

The current files are intended to be a cleaned and cluster-appropriate replacement for generic upstream runtime templates.
