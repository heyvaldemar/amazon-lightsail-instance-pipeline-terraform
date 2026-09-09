# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **Terraform 1.10 → 1.16 in CI.** The same binary that formats, validates and lints this configuration; `terraform validate` ran against it before this landed.

## [1.1.1] - 2026-09-09

### Changed

- **`hashicorp/aws` 6.62.0 → 6.63.0.** The constraint and the lockfile moved together, and the lockfile carries all four platforms it covered before. `terraform validate` ran against the new provider before this landed — that is what catches an argument it renamed or removed.

## [1.1.0] - 2026-09-08

### Added

- **`update.sh`: move between release tags, then plan.** It updates to the latest release (a combination this repository's CI has formatted, initialised, validated and linted), refuses to cross a major version unattended, refuses to run over local changes, and names any variable that became required since your version before anything has moved. It never applies: it prints the plan and stops, because applying against live infrastructure is a decision.
- **A daily freshness check on every pin.** Each provider in `.terraform.lock.hcl` is compared against the registry, both pinned CI images against what their tags resolve to now, and the Terraform line against the latest release. A provider that moved is a provider whose new and removed arguments this configuration has not been validated against yet.

## [1.0.0] - 2026-09-02

First semver release. Brings this configuration to the fleet standard.

### Changed

- `required_version` relaxed from an exact `1.9.2` pin (which rejected
  every other Terraform binary) to `>= 1.9.2, < 2.0.0`.
- AWS provider constraint moved to `~> 6.62.0`; personal domain
  defaults replaced with `example.com` placeholders.

### Added

- **`.terraform.lock.hcl`** locking every provider to exact builds and
  checksums for four platforms.
- **Terraform Verification workflow**: `fmt -check`, `init
  -lockfile=readonly`, `validate`, `tflint`, actionlint, on every push,
  pull request, and weekly.
- MIT `LICENSE`, `SECURITY.md`, and a README that says what gets
  created, what must be changed before the first apply, and what CI
  does and does not prove.

[Unreleased]: https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/compare/v1.1.1...HEAD
[1.1.1]: https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/releases/tag/v1.0.0
