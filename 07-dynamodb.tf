# DynamoDB table creation
resource "aws_dynamodb_table" "dynamodb_terraform_state_lock_1" {
  name         = "dynamodb-terraform-state-lock-wordpress-1"
  billing_mode = var.dynamodb_terraform_state_lock_1_billing_mode
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.kms_key_2.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "dynamodb-terraform-state-lock-wordpress-1"
  }

  depends_on = [aws_kms_key.kms_key_2]
}
