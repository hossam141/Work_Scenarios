data "aws_availability_zones" "available" {
  state = "available"
}

# --- VPC A ---
resource "aws_vpc" "vpc_a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "AEM-VPC-A" }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = cidrsubnet(var.vpc_a_cidr, 4, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "AEM-VPCA-SN-Private" }
}

resource "aws_route_table" "rt_a" {
  vpc_id = aws_vpc.vpc_a.id
  tags = { Name = "AEM-VPCA-RT" }
}

resource "aws_route_table_association" "rta_assoc" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt_a.id
}

# --- VPC B ---
resource "aws_vpc" "vpc_b" {
  cidr_block           = var.vpc_b_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "AEM-VPC-B" }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = cidrsubnet(var.vpc_b_cidr, 4, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "AEM-VPCB-SN-Private" }
}

resource "aws_route_table" "rt_b" {
  vpc_id = aws_vpc.vpc_b.id
  tags = { Name = "AEM-VPCB-RT" }
}

resource "aws_route_table_association" "rtb_assoc" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt_b.id
}

# --- VPC C ---
resource "aws_vpc" "vpc_c" {
  cidr_block           = var.vpc_c_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "AEM-VPC-C" }
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.vpc_c.id
  cidr_block        = cidrsubnet(var.vpc_c_cidr, 4, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "AEM-VPCC-SN-Private" }
}

resource "aws_route_table" "rt_c" {
  vpc_id = aws_vpc.vpc_c.id
  tags = { Name = "AEM-VPCC-RT" }
}

resource "aws_route_table_association" "rtc_assoc" {
  subnet_id      = aws_subnet.subnet_c.id
  route_table_id = aws_route_table.rt_c.id
}