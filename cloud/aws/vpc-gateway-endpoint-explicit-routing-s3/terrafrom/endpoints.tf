# 1. AWS VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Explicitly associate the endpoint with the private route table
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "aem-s3-gw-endpoint"
  }
}

# 2. EC2 Instance Connect Endpoint (For secure agentless SSH)
resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = aws_subnet.private.id
  security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "aem-eice"
  }
}
