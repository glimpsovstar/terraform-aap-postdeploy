# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning is
[semantic](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-09-25

### Added

- `extra_vars`, passed through to the workflow, with `_hosts = "all"` merged in by default.
  `4-validation.yml` declares `hosts: "{{ _hosts | default(omit) }}"` and without it matches
  no hosts at all — reporting success while testing nothing, which is how a broken
  application produced a green workflow.
- `extra_vars` output, and tests covering the default and caller overrides (17 unit tests).

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
