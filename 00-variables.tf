# AWS Infrastructure Variables
variable "region" {
  description = "The AWS region in which the infrastructure will be deployed"
  type        = string
  default     = "ca-central-1"
}

# Instance Variables
variable "instance_availability_zone" {
  description = "The availability zone for the AWS Lightsail instance"
  type        = string
  default     = "ca-central-1a"
}

variable "instance_name" {
  description = "The name of the AWS Lightsail instance"
  type        = string
  default     = "wordpress-1"
}

# You can easily deploy an app: WordPress, LAMP, Node.js, Joomla, Magento, MEAN, Drupal, GitLab CE, Redmine, Nginx, Ghost, Django, PrestaShop, Plesk Hosting Stack, cPanel & WHM for AlmaLinux
# Or you can deploy a clean operating system: Amazon Linux, Ubuntu, Debian, FreeBSD, openSUSE, CentOS
# The blueprint_id parameter determines the operating system or application that will be installed on your instance:
# aws lightsail get-blueprints
variable "instance_blueprintid" {
  description = "The blueprint ID of the AWS Lightsail instance, which determines the software to install"
  type        = string
  default     = "wordpress"
}

# The bundle_id parameter specifies the plan for your Lightsail instance, which includes aspects such as RAM, CPU, storage, and data transfer allowance:
# aws lightsail get-bundles
variable "instance_bundleid" {
  description = "The bundle ID of the AWS Lightsail instance, which determines the hardware of the instance"
  type        = string
  default     = "small_2_0"
}

variable "key_pair_1_name" {
  description = "The name of the key pair to use for the AWS Lightsail instance"
  type        = string
  default     = "key-pair-wordpress-1"
}

variable "instance_addon_type" {
  description = "Type of add-on for the Lightsail instance"
  type        = string
  default     = "AutoSnapshot"
}

variable "instance_snapshot_time" {
  description = "The time of day when the snapshot is taken"
  type        = string
  default     = "06:00"
}

variable "instance_addon_status" {
  description = "Status of the add-on"
  type        = string
  default     = "Enabled"
}

variable "static_ip_1" {
  description = "The name of the static IP to be created in AWS Lightsail"
  type        = string
  default     = "static-ip-wordpress-1"
}

variable "static_ip_1_attachment" {
  description = "The name of the static IP attachment to be created in AWS Lightsail"
  type        = string
  default     = "static-ip-wordpress-1"
}

# KMS Variables
variable "kms_key_1_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

variable "kms_key_2_default_retention_days" {
  description = "The default retention period in days for keys created in the KMS keyring"
  type        = number
  default     = 10
}

# DynamoDB Variables
variable "dynamodb_terraform_state_lock_1_billing_mode" {
  description = "The billing mode for the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "PAY_PER_REQUEST"
}
