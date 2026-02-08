# ==============================================================================
# Provider and Data Sources
# ------------------------------------------------------------------------------
# Purpose:
#   - Configures the AWS provider for this configuration.
#   - Looks up existing infrastructure components by tag for reuse.
#
# Scope:
#   - AWS region selection.
#   - Secrets Manager secret lookup for AD admin credentials.
#   - VPC and subnet discovery using Name tags.
#   - Windows Server 2022 AMI discovery for provisioning Windows hosts.
#
# Notes:
#   - Tag-based discovery assumes the network baseline has already been applied.
#   - Ensure Name tags are unique in the target account/region.
# ==============================================================================

# ==============================================================================
# AWS Provider Configuration
# ==============================================================================

provider "aws" {
  region = "us-east-1"
}

# ==============================================================================
# Secrets Manager: AD Administrator Secret Lookup
# ------------------------------------------------------------------------------
# Purpose:
#   - Locates the existing secret that stores AD administrator credentials.
# ==============================================================================

data "aws_secretsmanager_secret" "admin_secret" {
  name = "admin_ad_credentials"
}

# ==============================================================================
# Subnet Lookups
# ------------------------------------------------------------------------------
# Purpose:
#   - Locates existing public subnets by Name tag for VM placement.
#
# Notes:
#   - Subnets must exist and be tagged consistently with the network baseline.
# ==============================================================================

data "aws_subnet" "vm_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["vm-subnet-1"]
  }
}

data "aws_subnet" "vm_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["vm-subnet-2"]
  }
}

# ==============================================================================
# VPC Lookup
# ------------------------------------------------------------------------------
# Purpose:
#   - Locates the VPC used for mini-AD resources by Name tag.
# ==============================================================================

data "aws_vpc" "ad_vpc" {
  filter {
    name   = "tag:Name"
    values = ["ad-vpc"]
  }
}

# ==============================================================================
# AMI Lookup: Windows Server 2022 (Amazon)
# ------------------------------------------------------------------------------
# Purpose:
#   - Locates the latest Windows Server 2022 base AMI published by Amazon.
#
# Notes:
#   - Using most_recent ensures the build tracks new AMI releases over time.
# ==============================================================================

data "aws_ami" "windows_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}
