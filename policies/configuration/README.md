# Tetragon configuration

This folder contains the runtime configuration examples used for this repository.

- `tetragon.yaml`: cluster-specific Tetragon runtime configuration for a Kubernetes deployment, inspired by a deployment from The Zone at StatCan.
- `tetragon.conf.d/`: individual drop-in snippets for `/etc/tetragon/tetragon.conf.d/`.

The original generic upstream template has been replaced with a configuration that is more appropriate for a security observability deployment. The current files are intended to be a cleaned and cluster-appropriate replacement.
