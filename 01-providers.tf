terraform {

  /*#
The "backend" block in the "01-providers.tf" must remain commented until the bucket and the DynamoDB table are created.

After all your resources will be created, you will need to replace empty values
for "region" and "bucket" in the "backend" block of the "00-providers.tf" since variables are not allowed in this block.

For "region" you need to specify the region where the S3 bucket and DynamoDB table are located.
You need to use the same value that you have in the "00-variables.tf" for the "region" variable.

For "bucket" you will get its values in the output after the first run of "terraform apply -auto-approve".

After your values are set, you can then uncomment the "backend" block and run again "terraform init" and then "terraform apply -auto-approve".

In this way, the "terraform.tfstate" file will be stored in an S3 bucket and DynamoDB will be used for state locking and consistency checking.
*/

  /*#
  backend "s3" {
    region         = ""
    bucket         = ""
    key            = "state/terraform.tfstate"
    kms_key_id     = "alias/terraform-bucket-key-wordpress-1"
    dynamodb_table = "dynamodb-terraform-state-lock-wordpress-1"
    encrypt        = true
  }
*/

  # Terraform version (replace with yours)
  required_version = "1.9.2"

  # Terraform providers
  required_providers {
    aws = {
      source = "hashicorp/aws"

      # Provider versions
      version = "~> 5.83.1"
    }

    local = {
      source = "hashicorp/local"

      # Provider versions
      version = "~> 2.5.1"
    }

    random = {
      source = "hashicorp/random"

      # Provider versions
      version = "~> 3.6.0"
    }
  }
}

# Providers region
provider "aws" {
  region = var.region
}
