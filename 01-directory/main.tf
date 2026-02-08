# ==============================================================================
# AWS Provider Configuration
# ------------------------------------------------------------------------------
# Purpose:
#   - Configures the AWS provider for all resources in this Terraform stack.
#
# Notes:
#   - The region is hard-coded for simplicity in this quick-start project.
#   - Update this value or parameterize it for multi-region deployments.
# ==============================================================================

provider "aws" {
  region = "us-east-1"
}
