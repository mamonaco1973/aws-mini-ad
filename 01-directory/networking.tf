# =============================================================================
# Network baseline for mini-AD: VPC, public VM subnet, private AD subnet,
# Internet access for public workloads, NAT egress for private workloads.
# AZs/CIDRs are examples; adjust to your region/IP plan as needed.
# =============================================================================

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "ad-vpc" {
  cidr_block           = "10.0.0.0/24"   # /24 address space for this environment
  enable_dns_support   = true            # Required for AD/DNS resolution
  enable_dns_hostnames = true            # Enables DNS hostnames for EC2 instances

  tags = { Name = "ad-vpc" }
}

# ---------------------------
# Internet Gateway (egress for public subnet)
# ---------------------------
resource "aws_internet_gateway" "ad-igw" {
  vpc_id = aws_vpc.ad-vpc.id

  tags = { Name = "ad-igw" }
}

# ---------------------------
# Subnets
#   - vm-subnet: public, hosts bastion/utility VMs, provides path to IGW
#   - ad-subnet: private, hosts domain controllers, egress via NAT only
# ---------------------------
resource "aws_subnet" "vm-subnet" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.64/26" # ~62 usable IPs for public-facing VMs
  map_public_ip_on_launch = true           # Assign public IPv4 on instance launch
  availability_zone       = "us-east-2b"

  tags = { Name = "vm-subnet" }
}

resource "aws_subnet" "ad-subnet" {
  vpc_id                  = aws_vpc.ad-vpc.id
  cidr_block              = "10.0.0.0/26"  # ~62 usable IPs for DCs/AD services
  map_public_ip_on_launch = false          # No public IPs for private resources
  availability_zone       = "us-east-2a"

  tags = { Name = "ad-subnet" }
}

# ---------------------------
# Elastic IP for NAT Gateway (required in VPC mode)
# ---------------------------
resource "aws_eip" "nat_eip" {
  tags = { Name = "nat-eip" }
}

# ---------------------------
# NAT Gateway (placed in the public subnet)
# Provides outbound internet for instances in private subnets
# ---------------------------
resource "aws_nat_gateway" "ad_nat" {
  subnet_id     = aws_subnet.vm-subnet.id    # NAT must reside in a public subnet
  allocation_id = aws_eip.nat_eip.id         # Static public IP for stable egress
  tags = { Name = "ad-nat" }
}

# ---------------------------
# Route Tables
#   - public: default route to IGW for internet access
#   - private: default route to NAT for egress without inbound exposure
# ---------------------------
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

# ---------------------------
# Route Table Associations
# ---------------------------
resource "aws_route_table_association" "rt_assoc_vm_public" {
  subnet_id      = aws_subnet.vm-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "rt_assoc_ad_private" {
  subnet_id      = aws_subnet.ad-subnet.id
  route_table_id = aws_route_table.private.id
}
