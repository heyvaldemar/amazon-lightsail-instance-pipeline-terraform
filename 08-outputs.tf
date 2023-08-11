output "bucket_1_name" {
  description = "The name of the S3 bucket that is being used to store the Terraform state file"
  value       = aws_s3_bucket.bucket_1.bucket
}

output "log_bucket_1_name" {
  description = "The name of the S3 bucket that is being used to store the Terraform state file"
  value       = aws_s3_bucket.log_bucket_1.bucket
}

output "static_ip_1_details" {
  description = "Details of the static IP created in AWS Lightsail"
  value       = aws_lightsail_static_ip.static_ip_1
}
