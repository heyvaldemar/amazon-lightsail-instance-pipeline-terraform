# Static IP address creation in AWS Lightsail
resource "aws_lightsail_static_ip" "static_ip_1" {
  name = var.static_ip_1
}

# Static IP address attachment to a Lightsail instance
resource "aws_lightsail_static_ip_attachment" "static_ip_1_attachment" {
  instance_name  = aws_lightsail_instance.instance_1.name
  static_ip_name = var.static_ip_1_attachment
}
