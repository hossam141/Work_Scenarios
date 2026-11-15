# Security Group for VPC A
resource "aws_security_group" "sg_a" {
  name        = "sg_vpca"
  description = "Allow ICMP and SSH"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_b_cidr] # Allow from B
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_a_cidr] # Internal SSH (EICE)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for VPC B
resource "aws_security_group" "sg_b" {
  name        = "sg_vpcb"
  description = "Allow ICMP and SSH"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_a_cidr, var.vpc_c_cidr] # Allow from A and C
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_b_cidr] # Internal SSH (EICE)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for VPC C
resource "aws_security_group" "sg_c" {
  name        = "sg_vpcc"
  description = "Allow ICMP and SSH"
  vpc_id      = aws_vpc.vpc_c.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_b_cidr] # Allow from B
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_c_cidr] # Internal SSH (EICE)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}