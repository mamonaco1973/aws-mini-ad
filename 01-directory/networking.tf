# ================================================================================================
# Network baseline for mini-AD
# - One VPC with a public "vm" subnet (bastion/utility) and a private "ad" subnet (DCs)
# - Internet egress for public subnet via IGW; private subnet egress via NAT
# - AZs/CIDRs are examples—align to your region and IP plan
# ================================================================================================

# -----------------------------------
# VPC
# -----------------------------------
resource "aws_vpc" "ad-vpc" {
  cidr_block           = "10.0.0.0/24" # /24 for this lab environment
  enable_dns_support   = true          # Needed for resolver/DNS in VPC
  enable_dns_hostnames = true          # Enables DNS hostnames on EC2 instances

  tags = { Name = "ad-vpc" }
}

# -----------------------------------
# Internet Gateway (egress for public subnet)
# -----------------------------------
resource "aws_internet_gateway" "ad-igw" {
  vpc_id = aws_vpc.ad-vpc.id
  tags   = { Name = "ad-igw" }
}

# -----------------------------------
# Subnets
# - vm-subnet (public): bastion/utility VMs, direct path to IGW
# - ad-subnet (private): DCs/AD services, egress via NAT only
# -----------------------------------
resource "aws_subnet" "vm-subnet" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.64/26" # ~62 usable IPs
  map_public_ip_on_launch = true           # Auto-assign public IPv4
  availability_zone       = "us-east-2b"

  tags = { Name = "vm-subnet" }
}

resource "aws_subnet" "ad-subnet" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.0/26" # ~62 usable IPs
  map_public_ip_on_launch = false         # Private-only
  availability_zone       = "us-east-2a"

  tags = { Name = "ad-subnet" }
}

# -----------------------------------
# Elastic IP for NAT (static public IP for consistent egress)
# -----------------------------------
resource "aws_eip" "nat_eip" {
  tags = { Name = "nat-eip" }
}

# -----------------------------------
# NAT Gateway (must live in a public subnet)
# Provides outbound internet for instances in private subnets
# -----------------------------------
resource "aws_nat_gateway" "ad_nat" {
  subnet_id     = aws_subnet.vm-subnet.id # Public subnet placement
  allocation_id = aws_eip.nat_eip.id      # EIP attachment
  tags          = { Name = "ad-nat" }
}

# -----------------------------------
# Route Tables
# - public: default route to IGW (internet access)
# - private: default route to NAT (outbound egress without inbound exposure)
# -----------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ad-vpc.id
  tags   = { Name = "public-route-table" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ad-igw.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ad-vpc.id
  tags   = { Name = "private-route-table" }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ad_nat.id
}

# -----------------------------------
# Route Table Associations
# -----------------------------------
resource "aws_route_table_association" "rt_assoc_vm_public" {
  subnet_id      = aws_subnet.vm-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rt_assoc_ad_private" {
  subnet_id      = aws_subnet.ad-subnet.id
  route_table_id = aws_route_table.private.id
}
