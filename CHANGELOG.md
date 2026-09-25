# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning is
[semantic](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-25

### Added

- Integration tests in `tests-integration/` (`apply` mode) asserting the inventory and host
  are really created on a controller and that the named workflow template resolves.
- Unit coverage for `wait_for_completion = false`, custom workflow template name, custom
  organization, inventory description, trigger input contents, `retrigger` merge semantics,
  and the `post_deploy_enabled` output.
- CI now validates every directory under `examples/`.

### Changed

- Test files renamed to the `*_unit_test.tftest.hcl` convention.
- Unit tests grew from 8 to 15.

## [1.0.0] - 2026-09-25

### Added

- AAP inventory and host registration for a single managed host.
- Post-deployment workflow fired on create and on change, via a Terraform action.
- `run_post_deploy` to register a host without running anything.
- `retrigger` map so post-deployment can be re-run without rebuilding the host.
- `wait_for_completion` and a bounded `wait_timeout_seconds`, so a failed
  post-deployment fails the apply rather than passing silently.
- 8 tests running against `mock_provider`, needing no AAP controller.
