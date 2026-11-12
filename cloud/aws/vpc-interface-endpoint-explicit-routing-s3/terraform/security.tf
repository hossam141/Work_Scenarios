# Security Group for Backend Instances
resource "aws_security_group" "backend_sg" {
  name        = "${var.environment}-backend-sg"
  description = "Allow inbound traffic from Frontend and EICE"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from VPC (Assume Frontend is in the same VPC)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow SSH strictly from within the VPC (for EICE)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for VPC Endpoints (S3)
resource "aws_security_group" "endpoint_sg" {
  name        = "${var.environment}-endpoint-sg"
  description = "Allow HTTPS traffic from Backend SG to VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
  }
}