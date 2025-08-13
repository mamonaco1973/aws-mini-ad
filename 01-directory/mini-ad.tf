# --------------------------------------------------------------------------------------------------
# FETCH THE AMI ID FOR UBUNTU 24.04 FROM AWS PARAMETER STORE
# --------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "ubuntu_24_04" {
  # Pull the latest stable Ubuntu 24.04 AMI ID published by Canonical via AWS Systems Manager
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# --------------------------------------------------------------------------------------------------
# RESOLVE THE FULL AMI OBJECT USING THE ID FROM SSM
# --------------------------------------------------------------------------------------------------
data "aws_ami" "ubuntu_ami" {
  # Just in case there are multiple versions, this ensures the most recent one is picked
  most_recent = true

  # Canonical's AWS account ID contains the official Ubuntu AMIs
  owners = ["099720109477"]

  # Only fetch the AMI that matches the ID we just pulled from SSM
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_24_04.value]
  }
}

# --------------------------------------------------------------------------------------------------
# CREATE AN EC2 INSTANCE RUNNING UBUNTU 24.04
# --------------------------------------------------------------------------------------------------
resource "aws_instance" "mini_ad_dc_instance" {
  # Use the resolved AMI ID for Ubuntu 24.04 (from the data source above)
  ami = data.aws_ami.ubuntu_ami.id

  # Choose a micro instance type – good enough for demo workloads, not prod
  instance_type = "t3.small"

  # Drop this instance in the specified private subnet
  subnet_id = aws_subnet.ad-subnet.id

  # Attach both the general SSM security group and one allowing HTTP access (if needed)
  vpc_security_group_ids = [
    aws_security_group.ad_sg.id
  ]

  # Assign a public IP so it is reachable from the internet
  associate_public_ip_address = false

  # Attach the IAM instance profile that allows this EC2 to talk to SSM
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("./scripts/mini-ad.sh.template", {
    HOSTNAME_DC        = "ad1"
    DNS_ZONE           = var.dns_zone
    REALM              = var.realm
    NETBIOS            = var.netbios
    ADMINISTRATOR_PASS = random_password.admin_password.result
    ADMIN_USER_PASS    = random_password.admin_password.result
  })

  # Tag the instance with a recognizable name for filtering or UI display
  tags = {
    Name = "mini-ad-dc-${lower(var.netbios)}"
  }

  depends_on = [aws_nat_gateway.ad_nat, aws_route_table_association.rt_assoc_ad_private]
}

resource "aws_vpc_dhcp_options" "mini_ad_dns" {
  domain_name         = var.dns_zone
  domain_name_servers = [aws_instance.mini_ad_dc_instance.private_ip]

  tags = {
    Name = "mini-ad-dns"
  }
}

resource "aws_vpc_dhcp_options_association" "mini_ad_dns_assoc" {
  vpc_id          = aws_vpc.ad-vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.mini_ad_dns.id
}

