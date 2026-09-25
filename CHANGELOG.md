# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning is
[semantic](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-25

### Added

- AAP inventory and host registration for a single managed host.
- Post-deployment workflow fired on create and on change, via a Terraform action.
- `run_post_deploy` to register a host without running anything.
- `retrigger` map so post-deployment can be re-run without rebuilding the host.
- `wait_for_completion` and a bounded `wait_timeout_seconds`, so a failed
  post-deployment fails the apply rather than passing silently.
- 8 tests running against `mock_provider`, needing no AAP controller.
