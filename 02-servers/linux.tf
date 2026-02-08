# ==============================================================================
# Ubuntu 24.04 AMI Resolution (Canonical)
# ------------------------------------------------------------------------------
# Purpose:
#   - Fetches the current stable Ubuntu 24.04 LTS AMI ID from AWS SSM.
#
# Notes:
#   - The SSM path is maintained by Canonical and always points to the latest
#     stable amd64 HVM AMI using gp3-backed EBS.
# ==============================================================================

data "aws_ssm_parameter" "ubuntu_24_04" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# ==============================================================================
# Canonical Ubuntu AMI Lookup
# ------------------------------------------------------------------------------
# Purpose:
#   - Resolves the full AMI object using the ID returned from SSM.
#
# Scope:
#   - Restricts ownership to Canonical to avoid spoofed or third-party images.
#   - Filters explicitly by image-id for deterministic resolution.
#
# Notes:
#   - most_recent is retained as a defensive guard when multiple matches exist.
# ==============================================================================

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_24_04.value]
  }
}

# ==============================================================================
# EC2 Instance: Linux AD Utility / Join Host
# ------------------------------------------------------------------------------
# Purpose:
#   - Deploys a Linux EC2 instance used for AD integration and testing.
#
# Scope:
#   - Launched into a public subnet for initial access and troubleshooting.
#   - Bootstrapped via user-data for AD-related configuration.
#
# Notes:
#   - IAM role access is preferred over static credentials.
# ==============================================================================

resource "aws_instance" "linux_ad_instance" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t2.micro"

  # Networking
  subnet_id                   = data.aws_subnet.vm_subnet_1.id
  associate_public_ip_address = true

  # Security groups
  vpc_security_group_ids = [
    aws_security_group.ad_ssh_sg.id,
    aws_security_group.ad_ssm_sg.id
  ]

  # IAM role for AWS API access (Secrets Manager, SSM, etc.)
  iam_instance_profile = aws_iam_instance_profile.ec2_secrets_profile.name

  # User data bootstrap
  user_data = templatefile("./scripts/userdata.sh", {
    admin_secret = "admin_ad_credentials"
    domain_fqdn  = "mcloud.mikecloud.com"
  })

  # Resource tags
  tags = {
    Name = "linux-ad-instance"
  }
}
