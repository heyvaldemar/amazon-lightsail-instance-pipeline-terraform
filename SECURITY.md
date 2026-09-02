# Security Policy

## Supported Versions

| Version                                        | Status             |
|------------------------------------------------|--------------------|
| Current `main`                                 | :white_check_mark: |
| Older commits                                  | :x:                |

## Reporting a Vulnerability

Send reports to **v@valdemar.ai**. Encrypted email is preferred; the PGP public key is published at [heyvaldemar.com/security](https://heyvaldemar.com/security).

You can expect an acknowledgment within **7 days**. This project does not operate a bounty program; researchers who submit valid, responsibly disclosed reports receive public credit in the changelog.

Please do not open public GitHub issues for security reports.

## Supply Chain Trust

This repository is a Terraform configuration, not a software distribution. Provider versions are constrained in `01-providers.tf` and locked to exact builds and checksums in `.terraform.lock.hcl` for four platforms; the Terraform Verification workflow runs `init` with the lockfile as the authority, so a provider cannot move without the lockfile changing in the same commit. GitHub Actions and the Terraform and tflint container images used in CI are pinned by digest.

## Credentials

No credentials live in this repository. Secrets are read from AWS Secrets Manager at plan time via data sources; the ARN defaults are placeholders that must be replaced with your own. Ingress defaults are wide open (`0.0.0.0/0`) to keep the first deploy simple: narrow `allowed_ip_range` and the security group variables before anything real runs behind them.
