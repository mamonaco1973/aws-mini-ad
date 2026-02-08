#!/bin/bash
# ==============================================================================
# destroy.sh - Mini-AD Infrastructure Teardown
# ------------------------------------------------------------------------------
# Purpose:
#   - Destroys the mini-AD environment in a controlled, two-phase order:
#       1. Application / server EC2 instances.
#       2. Active Directory resources and supporting secrets.
#
# Scope:
#   - Runs Terraform destroy for dependent servers first.
#   - Force-deletes Secrets Manager entries created for AD users.
#   - Tears down the AD Terraform stack last.
#
# Fast-Fail Behavior:
#   - Script exits immediately on command failure, unset variables,
#     or failed pipelines.
#
# WARNING:
#   - Secrets are deleted with NO recovery window.
#   - This action is destructive and irreversible.
#
# Requirements:
#   - AWS CLI installed and authenticated with delete permissions.
#   - Terraform installed and available in PATH.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
export AWS_DEFAULT_REGION="us-east-1"

# ------------------------------------------------------------------------------
# Phase 1: Destroy Server EC2 Instances
# ------------------------------------------------------------------------------
echo "NOTE: Destroying EC2 server instances..."

cd 02-servers || {
  echo "ERROR: Directory 02-servers not found"
  exit 1
}

terraform init
terraform destroy -auto-approve

cd ..

# ------------------------------------------------------------------------------
# Phase 2: Destroy AD Secrets and Directory Resources
# ------------------------------------------------------------------------------
echo "NOTE: Deleting Active Directory Secrets Manager entries..."

aws secretsmanager delete-secret \
  --secret-id "akumar_ad_credentials" \
  --force-delete-without-recovery

aws secretsmanager delete-secret \
  --secret-id "jsmith_ad_credentials" \
  --force-delete-without-recovery

aws secretsmanager delete-secret \
  --secret-id "edavis_ad_credentials" \
  --force-delete-without-recovery

aws secretsmanager delete-secret \
  --secret-id "rpatel_ad_credentials" \
  --force-delete-without-recovery

aws secretsmanager delete-secret \
  --secret-id "admin_ad_credentials" \
  --force-delete-without-recovery

# ------------------------------------------------------------------------------
# Phase 3: Destroy Active Directory Infrastructure
# ------------------------------------------------------------------------------
echo "NOTE: Destroying Active Directory resources..."

cd 01-directory || {
  echo "ERROR: Directory 01-directory not found"
  exit 1
}

terraform init
terraform destroy -auto-approve

cd ..

# ------------------------------------------------------------------------------
# Completion
# ------------------------------------------------------------------------------
echo "NOTE: Infrastructure destruction complete."
