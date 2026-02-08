#!/bin/bash
# ==============================================================================
# apply.sh - Mini-AD Infrastructure Deployment
# ------------------------------------------------------------------------------
# Purpose:
#   - Provisions the mini-AD environment in two ordered phases:
#       1. Active Directory (Samba 4) deployment.
#       2. Dependent EC2 server deployments.
#
# Scope:
#   - Validates the local environment before provisioning.
#   - Applies Terraform configurations in dependency order.
#   - Runs post-build validation to confirm successful deployment.
#
# Fast-Fail Behavior:
#   - Script exits immediately on command failure, unset variables,
#     or failed pipelines.
#
# Requirements:
#   - AWS CLI configured with sufficient permissions.
#   - Terraform installed and available in PATH.
#   - check_env.sh and validate.sh present and executable.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
export AWS_DEFAULT_REGION="us-east-1"
DNS_ZONE="mcloud.mikecloud.com"

# ------------------------------------------------------------------------------
# Environment Pre-Check
# ------------------------------------------------------------------------------
echo "NOTE: Running environment validation..."
./check_env.sh

# ------------------------------------------------------------------------------
# Phase 1: Active Directory Deployment
# ------------------------------------------------------------------------------
echo "NOTE: Deploying Active Directory resources..."

cd 01-directory || {
  echo "ERROR: Directory 01-directory not found"
  exit 1
}

terraform init
terraform apply -auto-approve

cd ..

# ------------------------------------------------------------------------------
# Phase 2: EC2 Server Deployment
# ------------------------------------------------------------------------------
echo "NOTE: Deploying dependent EC2 server instances..."

cd 02-servers || {
  echo "ERROR: Directory 02-servers not found"
  exit 1
}

terraform init
terraform apply -auto-approve

cd ..

# ------------------------------------------------------------------------------
# Build Validation
# ------------------------------------------------------------------------------
echo "NOTE: Running post-build validation..."
./validate.sh


