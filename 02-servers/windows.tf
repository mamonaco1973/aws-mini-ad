# ==============================================================================
# EC2 Instance: Windows AD Test Host
# ------------------------------------------------------------------------------
# Purpose:
#   - Deploys a Windows Server EC2 instance joined to the mini-AD domain.
#
# Scope:
#   - Uses a dynamically resolved Windows Server 2022 AMI.
#   - Launched into a public subnet for initial access and testing.
#   - Bootstrapped via PowerShell user-data for AD integration.
#
# Notes:
#   - Windows instances require more CPU and memory than Linux.
#   - Public IP exposure is intended for lab use only.
# ==============================================================================

resource "aws_instance" "windows_ad_instance" {
  # AMI selection
  ami = data.aws_ami.windows_ami.id

  # Instance sizing
  instance_type = "t2.medium"

  # Networking
  subnet_id                   = data.aws_subnet.vm_subnet_1.id
  associate_public_ip_address = true

  # Security groups
  vpc_security_group_ids = [
    aws_security_group.ad_rdp_sg.id,
    aws_security_group.ad_ssm_sg.id
  ]

  # IAM role for AWS API access (Secrets Manager, SSM, etc.)
  iam_instance_profile = aws_iam_instance_profile.ec2_secrets_profile.name

  # User-data bootstrap (PowerShell)
  user_data = templatefile("./scripts/userdata.ps1", {
    admin_secret = "admin_ad_credentials"
    domain_fqdn  = var.dns_zone
  })

  # Resource tags
  tags = {
    Name = "windows-ad-instance"
  }
}
