# ==============================================================================
# Security Groups: Remote Access (Lab Defaults)
# ------------------------------------------------------------------------------
# Purpose:
#   - Defines security groups for common management access:
#       - RDP for Windows instances.
#       - SSH for Linux instances.
#       - HTTPS egress for Systems Manager (SSM) usage patterns.
#
# WARNING:
#   - Ingress rules below allow access from 0.0.0.0/0 (the public internet).
#   - This is unsafe for production. Restrict inbound CIDRs to trusted IPs.
#
# Notes:
#   - SSM does not require inbound 443 from the internet for Session Manager.
#     The SSM agent initiates outbound connections. Keep inbound closed unless
#     you have a specific reason to open it.
# ==============================================================================

# ==============================================================================
# Security Group: RDP (TCP/3389)
# ==============================================================================

resource "aws_security_group" "ad_rdp_sg" {
  name        = "ad-rdp-security-group"
  description = "Allow RDP access (lab default)"
  vpc_id      = data.aws_vpc.ad_vpc.id

  ingress {
    description = "RDP from anywhere (unsafe lab default)"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================
# Security Group: SSH (TCP/22)
# ==============================================================================

resource "aws_security_group" "ad_ssh_sg" {
  name        = "ad-ssh-security-group"
  description = "Allow SSH access (lab default)"
  vpc_id      = data.aws_vpc.ad_vpc.id

  ingress {
    description = "SSH from anywhere (unsafe lab default)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================
# Security Group: SSM / HTTPS (TCP/443)
# ------------------------------------------------------------------------------
# Notes:
#   - Session Manager requires outbound 443 from instances, not inbound 443.
#   - This inbound rule is not recommended and is kept only as a lab placeholder.
# ==============================================================================

resource "aws_security_group" "ad_ssm_sg" {
  name        = "ad-ssm-security-group"
  description = "Allow HTTPS/443 ingress (lab placeholder)"
  vpc_id      = data.aws_vpc.ad_vpc.id

  ingress {
    description = "HTTPS from anywhere (not recommended)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
