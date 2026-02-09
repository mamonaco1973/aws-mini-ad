# ==============================================================================
# Network Baseline: mini-AD
# ------------------------------------------------------------------------------
# Purpose:
#   - Builds a simple lab VPC for the mini-AD quick start.
#
# Scope:
#   - One VPC with:
#       - Two public "vm" subnets for utility/bastion workloads.
#       - One private "ad" subnet for the Samba 4 domain controller.
#   - Internet egress:
#       - Public subnets route to an Internet Gateway (IGW).
#       - Private subnet routes to a NAT Gateway for outbound-only access.
#
# Notes:
#   - CIDRs and AZ IDs are example values. Align these to your IP plan and
#     region/AZ strategy.
#   - NAT Gateway requires an Elastic IP and must be placed in a public subnet.
# ==============================================================================

# ==============================================================================
# VPC
# ==============================================================================

resource "aws_vpc" "ad-vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = var.vpc_name }
}

# ==============================================================================
# Internet Gateway
# - Provides internet egress for public subnets via default route (0.0.0.0/0).
# ==============================================================================

resource "aws_internet_gateway" "ad-igw" {
  vpc_id = aws_vpc.ad-vpc.id

  tags = { Name = "ad-igw" }
}

# ==============================================================================
# Subnets
# ------------------------------------------------------------------------------
# Public Subnets:
#   - vm-subnet-1: Utility/bastion workloads with public IPv4.
#   - vm-subnet-2: Additional utility capacity / HA option.
#
# Private Subnet:
#   - ad-subnet: Domain controller placement with NAT egress only.
# ==============================================================================

resource "aws_subnet" "vm-subnet-1" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.64/26"
  map_public_ip_on_launch = true
  availability_zone_id    = "use1-az6"

  tags = { Name = "vm-subnet-1" }
}

resource "aws_subnet" "vm-subnet-2" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.128/26"
  map_public_ip_on_launch = true
  availability_zone_id    = "use1-az4"

  tags = { Name = "vm-subnet-2" }
}

resource "aws_subnet" "ad-subnet" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = false
  availability_zone_id    = "use1-az4"

  tags = { Name = "ad-subnet" }
}

# ==============================================================================
# NAT Egress
# ------------------------------------------------------------------------------
# Purpose:
#   - Provides outbound internet access for instances in private subnets.
#
# Notes:
#   - The NAT Gateway must be deployed into a public subnet.
#   - The Elastic IP provides a stable public egress address.
# ==============================================================================

resource "aws_eip" "nat_eip" {
  tags = { Name = "nat-eip" }
}

resource "aws_nat_gateway" "ad_nat" {
  subnet_id     = aws_subnet.vm-subnet-1.id
  allocation_id = aws_eip.nat_eip.id

  tags = { Name = "ad-nat" }
}

# ==============================================================================
# Route Tables
# ------------------------------------------------------------------------------
# Public:
#   - Default route to IGW for public subnet internet access.
#
# Private:
#   - Default route to NAT for private subnet outbound-only internet access.
# ==============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ad-vpc.id

  tags = { Name = "public-route-table" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ad-igw.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ad-vpc.id

  tags = { Name = "private-route-table" }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ad_nat.id
}

# ==============================================================================
# Route Table Associations
# ==============================================================================

resource "aws_route_table_association" "rt_assoc_vm_public" {
  subnet_id      = aws_subnet.vm-subnet-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rt_assoc_vm_public_2" {
  subnet_id      = aws_subnet.vm-subnet-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rt_assoc_ad_private" {
  subnet_id      = aws_subnet.ad-subnet.id
  route_table_id = aws_route_table.private.id
}
