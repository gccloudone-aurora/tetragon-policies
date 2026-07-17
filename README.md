# Tetragon Policies

Tetragon is an Aurora platform security component that provides kernel-level runtime visibility into Kubernetes nodes and workloads.  

Tetragon TracingPolicies generate telemetry that may be:  

- Forwarded to the Log Analytics workspace for Sentinel analytics
- Exposed as metrics for Prometheus
- Stored or queried through Loki
- Visualized through Grafana
- Routed through Alertmanager
- Delivered by email or Microsoft Teams

## Repository structure

- Policy manifests are stored under `policies/`.
  - Active Tetragon tracing policies have been selected for a minimal security observability workload.
- `kustomization.yaml` is the current entry point for building this repository.

## Domain

Tetragon organizes its security observability capabilities into key domains: 

- Monitoring
- Credential Lifecycle
- Privilege Escalation
- File Access and Integrity

Each domain focuses on specific kernel-level events and provides targeted analytics and alerts to detect and respond to security threats in Kubernetes environments.  

### Monitoring

| Policy                      | Kernel Hooks / Events         |
|-----------------------------|-------------------------------|
| process-exec-elf-begin.yaml | security_bprm_creds_from_file |
| lsm_bprm_check.yaml         | bprm_check_security           |
| security_bprm_check.yaml    | security_bprm_check           |

Coverage:

- Container process execution tracking
- Interpreter and shell execution visibility
- Binary load validation events
- Scoped binary execution monitoring

Analytics and alerts:

- Execution outside expected binaries
- Unexpected interpreter usage
- Anomalous workload execution patterns

### Credential Lifecycle

| Policy                                       | Kernel Hooks                               |
|----------------------------------------------|--------------------------------------------|
| process-creds-changed.yaml                   | commit_creds, override_creds, revert_creds |
| process.credentials.changes.at.syscalls.yaml | setuid/setgid family syscalls              |

Coverage:

- Credential installation and transition events
- Temporary privilege overrides
- UID / GID transitions during execution

Analytics and alerts:

- Anomalous credential transitions
- Suspicious privilege context switching

### Privilege Escalation

| Policy                | Kernel Hooks                                               |
|-----------------------|------------------------------------------------------------|
| privileges-raise.yaml | capset, setuid/setgid/setresuid/setresgid, user namespaces |

Coverage:

- Capability escalation
- UID/GID elevation to root
- User namespace privilege acquisition

Analytics and alerts:

- Privilege escalation attempts
- Container privilege boundary bypass patterns

### File Access and Integrity

| Policy                            | Kernel Hooks                    |
|-----------------------------------|---------------------------------|
| filename_monitoring_filtered.yaml | file_permission, mmap, truncate |
| lsm_file_open.yaml                | file_open                       |

Coverage:

- Sensitive file access, including `/etc/passwd` and `/etc/shadow`
- File modification and truncation attempts
- Controlled binary-based sensitive file reads

Analytics and alerts:

- Sensitive file access attempts
- Credential database access attempts
