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
#   - Subnet Name tags are NOT unique in AWS; always scope subnet lookups to VPC.
# ==============================================================================

# ==============================================================================
# AWS Provider Configuration
# ==============================================================================

provider "aws" {
  region = "us-east-1"
}

# ==============================================================================
# Secrets Manager: AD Administrator Secret Lookup
# ==============================================================================

data "aws_secretsmanager_secret" "admin_secret" {
  name = "admin_ad_credentials"
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
    values = [var.vpc_name]
  }
}

# ==============================================================================
# Subnet Lookups (Scoped to VPC)
# ------------------------------------------------------------------------------
# Purpose:
#   - Locates existing public subnets by Name tag for VM placement.
#
# Notes:
#   - Subnet Name tags are not unique; vpc-id filter prevents collisions.
# ==============================================================================

data "aws_subnet" "vm_subnet_1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ad_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["vm-subnet-1"]
  }
}

data "aws_subnet" "vm_subnet_2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ad_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["vm-subnet-2"]
  }
}

# ==============================================================================
# AMI Lookup: Windows Server 2022 (Amazon)
# ==============================================================================

data "aws_ami" "windows_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}
