# SI-3 Active Policy Set

This folder contains the minimal Tetragon policy manifests selected to support the SI-3 malware detection and response requirements.

These rules are intended to provide runtime observability and response for:

- suspicious binary execution and process creation
- privilege escalation and credential changes
- sensitive path/file monitoring

## Active manifests

- `process-exec-elf-begin.yaml`
- `lsm_bprm_check.yaml`
- `security_bprm_check.yaml`
- `privileges-raise.yaml`
- `process.credentials.changes.at.syscalls.yaml`
- `process-creds-changed.yaml`
- `lsm_file_open.yaml`
- `filename_monitoring_filtered.yaml`

## Notes

- The existing example policies in `archived/` have been preserved for reference.
- Image scanning is not part of this runtime policy repository; it belongs in the CI/CD pipeline and external scanning tooling.
- Review and tune these policies before deploying them in production, especially network address selectors and binary matching.
