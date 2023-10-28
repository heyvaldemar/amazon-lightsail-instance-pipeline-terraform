# Creating an AWS Lightsail instance
resource "aws_lightsail_instance" "instance_1" {
  name              = var.instance_name
  availability_zone = var.instance_availability_zone
  key_pair_name     = var.key_pair_1_name
  blueprint_id      = var.instance_blueprintid
  bundle_id         = var.instance_bundleid

  # An add-on block, which enables automatic snapshots of the instance at 06:00 every day
  add_on {
    type          = var.instance_addon_type
    snapshot_time = var.instance_snapshot_time
    status        = var.instance_addon_status
  }

  tags = {
    Environment = "production"
  }
}

# Public ports definition on the AWS Lightsail instance
resource "aws_lightsail_instance_public_ports" "public_ports" {
  instance_name = aws_lightsail_instance.instance_1.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
}
