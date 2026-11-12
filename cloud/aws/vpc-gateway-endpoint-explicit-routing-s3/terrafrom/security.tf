# Security Group for Backend Instances
resource "aws_security_group" "backend_sg" {
  name        = "${var.environment}-backend-sg"
  description = "Security group for backend instances"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from Frontend
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  # Allow SSH from EICE within VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all outbound (Route Table will restrict S3 traffic to internal network)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
