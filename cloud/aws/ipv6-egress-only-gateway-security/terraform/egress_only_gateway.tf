# 1. Egress-Only Internet Gateway (EIGW) for IPv6
resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "aem-vpc1-egw"
  }
}

# 2. Route all IPv6 traffic (::/0) through the EIGW for the Private Subnet
resource "aws_route" "ipv6_egress_route" {
  route_table_id              = aws_route_table.private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw.id
}
