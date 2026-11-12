# 1. AWS PrivateLink for S3 (Interface Endpoint)
resource "aws_vpc_endpoint" "s3_interface" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Interface"

  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]

  # Explicit architectural decision based on the requirement
  private_dns_enabled = false 

  tags = {
    Name = "${var.environment}-s3-interface-endpoint"
  }
}

# 2. EC2 Instance Connect Endpoint (For secure agentless SSH)
resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = aws_subnet.private[0].id
  security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "${var.environment}-eice"
  }
}