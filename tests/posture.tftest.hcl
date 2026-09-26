# What this configuration promises with its default variables, asserted on
# a plan against mocked providers: no AWS account, no credentials, nothing
# created. Generated from the configuration's own attributes and kept in
# the repository; tests/plant-violations.sh breaks each promise on a copy
# and requires this file to notice.

mock_provider "aws" {
  mock_data "aws_secretsmanager_secret_version" {
    defaults = {
      secret_string = "{}"
    }
  }
  mock_data "aws_eks_cluster" {
    defaults = {
      endpoint              = "https://eks.example.test"
      certificate_authority = [{ data = "dGVzdA==" }]
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "local" {}

mock_provider "random" {}

run "the_defaults_are_the_secure_ones" {
  command = plan

  assert {
    condition     = alltrue([for s in aws_dynamodb_table.dynamodb_terraform_state_lock_1.server_side_encryption : s.enabled == true])
    error_message = "dynamodb_terraform_state_lock_1 is not encrypted with its own key"
  }

  assert {
    condition     = alltrue([for p in aws_dynamodb_table.dynamodb_terraform_state_lock_1.point_in_time_recovery : p.enabled == true])
    error_message = "dynamodb_terraform_state_lock_1 cannot be restored to a point in time"
  }

  assert {
    condition     = aws_kms_key.kms_key_1.enable_key_rotation == true
    error_message = "kms_key_1 does not rotate its key material"
  }

  assert {
    condition     = aws_kms_key.kms_key_2.enable_key_rotation == true
    error_message = "kms_key_2 does not rotate its key material"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.block_public_acls == true && aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.block_public_policy == true && aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.ignore_public_acls == true && aws_s3_bucket_public_access_block.bucket_1_public_access_block_block.restrict_public_buckets == true
    error_message = "bucket_1_public_access_block_block leaves a way to make the bucket public"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.block_public_acls == true && aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.block_public_policy == true && aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.ignore_public_acls == true && aws_s3_bucket_public_access_block.log_bucket_1_public_access_block_block.restrict_public_buckets == true
    error_message = "log_bucket_1_public_access_block_block leaves a way to make the bucket public"
  }

  assert {
    condition     = alltrue([for r in aws_s3_bucket_server_side_encryption_configuration.bucket_1_sse_configuration.rule : alltrue([for x in r.apply_server_side_encryption_by_default : x.sse_algorithm == "aws:kms"])])
    error_message = "bucket_1_sse_configuration does not encrypt with a KMS key"
  }

  assert {
    condition     = alltrue([for r in aws_s3_bucket_server_side_encryption_configuration.log_bucket_1_sse_configuration.rule : alltrue([for x in r.apply_server_side_encryption_by_default : x.sse_algorithm == "aws:kms"])])
    error_message = "log_bucket_1_sse_configuration does not encrypt with a KMS key"
  }

  assert {
    condition     = alltrue([for v in aws_s3_bucket_versioning.bucket_1_versioning.versioning_configuration : v.status == "Enabled"])
    error_message = "bucket_1_versioning does not keep old versions"
  }

  assert {
    condition     = alltrue([for v in aws_s3_bucket_versioning.log_bucket_1_versioning.versioning_configuration : v.status == "Enabled"])
    error_message = "log_bucket_1_versioning does not keep old versions"
  }
}
