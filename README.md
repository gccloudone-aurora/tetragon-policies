# Tetragon Policies

A curated repository of Tetragon security observability policies and deployment configuration for Kubernetes.

## Repository structure

- `si-3/`
  - Active SI-3-aligned Tetragon tracing policies selected for a minimal security observability workload.
- `configuration/`
  - Deployment manifest examples for Tetragon, including a Kustomize application, Helm values, and an ArgoCD app example.
- `archived/`
  - Upstream example policies preserved for reference and comparison.

## Deployment

This repository is structured to support deployment with ArgoCD or Kustomize.

### ArgoCD

Use `configuration/argocd-application.yaml` as an example ArgoCD Application manifest.
Point ArgoCD at `configuration/` to install the Tetragon Helm chart, persistence, observability resources, and active policy set.

### Kustomize

The folder `configuration/` contains `kustomization.yaml`, which:

- installs the Tetragon Helm chart
- adds a persistent volume claim for Tetragon logs
- adds a `ServiceMonitor` for Prometheus scraping
- adds a `NetworkPolicy` for scrape access
- adds a `PodDisruptionBudget`
- includes all policy manifests from `si-3/`

### Notes

- `values.yaml` contains the Helm values used by the Tetragon chart.
- `tetragon.yaml` is a runtime configuration sample; it is not directly deployed by the Kustomize app.

## How to contribute

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

This project is covered under Crown Copyright, Government of Canada, and is distributed under the [MIT License](LICENSE).

The Canada wordmark and related graphics associated with this distribution are protected under trademark law and copyright law. No permission is granted to use them outside the parameters of the Government of Canada's corporate identity program. For more information, see [Federal identity requirements](https://www.canada.ca/en/treasury-board-secretariat/topics/government-communications/federal-identity-requirements.html).

## Licence

Ce projet est protégé par le droit d'auteur de la Couronne du gouvernement du Canada et distribué sous la [licence MIT](LICENSE).

Le mot-symbole « Canada » et les éléments graphiques connexes liés à cette distribution sont protégés en vertu des lois portant sur les marques de commerce et le droit d'auteur. Aucune autorisation n'est accordée pour leur utilisation à l'extérieur des paramètres du programme de coordination de l'image de marque du gouvernement du Canada. Pour obtenir davantage de renseignements à ce sujet, veuillez consulter les [Exigences pour l'image de marque](https://www.canada.ca/fr/secretariat-conseil-tresor/sujets/communications-gouvernementales/exigences-image-marque.html).
