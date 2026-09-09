# A Lightsail instance: Terraform

[![Terraform Verification](https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/actions/workflows/terraform-verification.yml/badge.svg?branch=main)](https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/actions/workflows/terraform-verification.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository deploys an Amazon Lightsail instance with a static IP, a generated key pair and opened ports, plus a self-provisioned Terraform state backend: the cheapest always-on Linux box AWS sells, managed as code. Flat, numbered `.tf` files, no modules to chase, every provider locked to an exact build.

## What it creates

| Area | Resources |
|---|---|
| Compute | `aws_lightsail_instance`, `aws_lightsail_static_ip`, `aws_lightsail_static_ip_attachment`, `aws_lightsail_key_pair`, `aws_lightsail_instance_public_ports`, `local_file` |
| State backend and encryption | `aws_s3_bucket` ×2, `aws_s3_bucket_versioning` ×2, `aws_s3_bucket_server_side_encryption_configuration` ×2, `aws_s3_bucket_public_access_block` ×2, `aws_s3_bucket_policy`, `aws_s3_bucket_logging`, `aws_dynamodb_table`, `aws_kms_key` ×2, `aws_kms_alias` ×2, `random_id` |

14 variables, 3 outputs. Every variable has a description and a default in `00-variables.tf`.

## Prerequisites

- **Terraform 1.9.2 or newer** (any 1.x; the lockfile pins the providers, not the binary). [Install guide](https://developer.hashicorp.com/terraform/install).
- **AWS CLI** configured with credentials that can create the resources above: `aws sts get-caller-identity` must answer. [Install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

## Getting started

```bash
# 1. Clone
git clone https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform
cd amazon-lightsail-instance-pipeline-terraform

# 2. Replace the placeholders (table below) - your region, your secrets, your domain
$EDITOR 00-variables.tf        # or put overrides into terraform.tfvars (gitignored)

# 3. Plan, then apply
terraform init
terraform plan
terraform apply
```

Values you must change before the first apply:

| Variable | Placeholder | Meaning |
|---|---|---|
| - | - | every default is a real, generic value |

No credentials are needed beyond your AWS CLI session; generated key material (SSH keys) is created by Terraform and lands in state. Treat the state bucket as sensitive, which the KMS-encrypted, versioned, access-blocked bucket this configuration creates already does.

### State backend: bootstrap, then switch

The first `apply` runs with local state and creates the S3 bucket, DynamoDB lock table and KMS key that will hold the state from then on. Once they exist, uncomment the `backend "s3"` block in `01-providers.tf`, fill in the bucket and table names from the outputs, and run `terraform init -migrate-state`. From that point every plan locks against DynamoDB and the state is versioned and encrypted.

## Updating

`./update.sh` moves this checkout to the latest release tag — a combination this repository's CI has formatted, initialised against its lockfile, validated and linted — then runs `terraform init -upgrade` and prints a plan. **It never applies.** Reading the plan and running `terraform apply` is yours. It refuses to cross a major version unattended, refuses to run over local changes, and names any variable that became required since your version before anything has moved. `./update.sh --dry-run` says what would happen; `--no-plan` updates the files and stops.

Provider versions are watched daily: every provider in `.terraform.lock.hcl` is compared against the registry, and both pinned CI images against their tags. A provider that moved inside its major line is bumped through the same CI gate — `fmt`, `init` against the lockfile, `validate`, `tflint` — and released; a major is prepared on a branch for you to read.

## Supply chain trust

- **Providers are locked to exact builds** in `.terraform.lock.hcl` for `linux_amd64`, `linux_arm64`, `darwin_amd64` and `darwin_arm64`, with checksums. CI runs `terraform init -lockfile=readonly`, so a provider cannot move without the lockfile changing in the same commit, and Dependabot proposes provider bumps as pull requests that CI validates.
- **The Terraform and tflint container images CI uses are pinned by digest**, and GitHub Actions are pinned by commit SHA.
- **No credentials in the repository.** `.env`, `*.tfvars` and state files are gitignored.

See [`SECURITY.md`](SECURITY.md) for the disclosure policy.

## Production checklist

- [ ] **Move state to the remote backend** right after the bootstrap apply (see above). Local state on a laptop is how estates get lost.
- [ ] **Review the region and instance sizes** in `00-variables.tf`. Defaults are sized to boot, not to serve your load.
- [ ] **Run `terraform plan` in CI on pull requests.** `.github/workflows/02-terraform-plan-apply.yml.example` and `.gitlab-ci.yml.example` show the shape; wire them to your AWS account with OIDC federation rather than static keys.
- [ ] **Watch for drift.** `00-terraform-drift-detection.yml.example` runs a nightly plan and fails when the estate no longer matches the code.

## Testing

The [Terraform Verification](https://github.com/heyvaldemar/amazon-lightsail-instance-pipeline-terraform/actions/workflows/terraform-verification.yml?query=branch%3Amain) workflow runs on every push, pull request, and weekly: `terraform fmt -check`, `terraform init -lockfile=readonly`, `terraform validate`, `tflint`, and actionlint on the workflow itself.

What CI does not do is `apply`: this repository has no AWS account of its own, so the guarantee is that the configuration is well-formed and its providers are exactly the ones tested. Run the plan/apply pipeline examples against your own account for the rest.

---

## About the maintainer

<div align="center">

**Maintained by [Vladimir Mikhalev](https://github.com/heyvaldemar)** — Docker Captain · IBM Champion · AWS Community Builder

[YouTube](https://www.youtube.com/channel/UCf85kQ0u1sYTTTyKVpxrlyQ?sub_confirmation=1) · [Blog](https://heyvaldemar.com) · [LinkedIn](https://www.linkedin.com/in/heyvaldemar/)

</div>
