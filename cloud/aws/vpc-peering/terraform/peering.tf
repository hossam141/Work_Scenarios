# --- Peering Connection: VPC A -> VPC B ---
resource "aws_vpc_peering_connection" "peer_ab" {
  vpc_id      = aws_vpc.vpc_a.id # Requester
  peer_vpc_id = aws_vpc.vpc_b.id # Accepter
  auto_accept = true             # Auto accept since both are in the same account/region

  tags = {
    Name = "AEM-VPCA-TO-VPCB"
  }
}

# Routes for Peering A -> B
resource "aws_route" "route_a_to_b" {
  route_table_id            = aws_route_table.rt_a.id
  destination_cidr_block    = var.vpc_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_ab.id
}

resource "aws_route" "route_b_to_a" {
  route_table_id            = aws_route_table.rt_b.id
  destination_cidr_block    = var.vpc_a_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_ab.id
}


# --- Peering Connection: VPC B -> VPC C ---
resource "aws_vpc_peering_connection" "peer_bc" {
  vpc_id      = aws_vpc.vpc_b.id # Requester
  peer_vpc_id = aws_vpc.vpc_c.id # Accepter
  auto_accept = true

  tags = {
    Name = "AEM-VPCB-TO-VPCC"
  }
}

# Routes for Peering B -> C
resource "aws_route" "route_b_to_c" {
  route_table_id            = aws_route_table.rt_b.id
  destination_cidr_block    = var.vpc_c_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_bc.id
}

resource "aws_route" "route_c_to_b" {
  route_table_id            = aws_route_table.rt_c.id
  destination_cidr_block    = var.vpc_b_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_bc.id
}