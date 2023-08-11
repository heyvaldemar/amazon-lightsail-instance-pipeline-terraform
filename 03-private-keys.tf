# Creating a key pair for AWS Lightsail instances
resource "aws_lightsail_key_pair" "private_key_1" {
  name = var.key_pair_1_name
}

# Saving the private key to a local file
resource "local_file" "private_key_1_export" {
  filename = "${path.root}/${var.key_pair_1_name}.pem"
  content  = aws_lightsail_key_pair.private_key_1.private_key

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}
