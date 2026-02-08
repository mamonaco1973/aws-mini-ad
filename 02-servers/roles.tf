# ==============================================================================
# IAM Role and Instance Profile: EC2 Secrets Access
# ------------------------------------------------------------------------------
# Purpose:
#   - Defines an IAM role assumed by EC2 instances.
#   - Grants read-only access to required AWS Secrets Manager secrets.
#   - Enables Systems Manager (SSM) access for remote management.
#
# Scope:
#   - IAM role with EC2 trust policy.
#   - Custom IAM policy for Secrets Manager access.
#   - Policy attachments for SSM and Secrets Manager.
#   - IAM instance profile for EC2 association.
#
# Notes:
#   - IAM roles are preferred over static credentials.
#   - Secret access is scoped to specific ARNs where possible.
# ==============================================================================

# ==============================================================================
# IAM Role: EC2 Secrets Access
# ------------------------------------------------------------------------------
# Purpose:
#   - Allows EC2 instances to assume an IAM role for AWS API access.
# ==============================================================================

resource "aws_iam_role" "ec2_secrets_role" {
  name = "EC2SecretsAccessRole-${var.netbios}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ==============================================================================
# IAM Policy: Secrets Manager Read Access
# ------------------------------------------------------------------------------
# Purpose:
#   - Grants EC2 instances permission to read AD credentials from
#     AWS Secrets Manager.
# ==============================================================================

resource "aws_iam_policy" "secrets_policy" {
  name        = "SecretsManagerReadAccess"
  description = "Read access to required Secrets Manager secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          data.aws_secretsmanager_secret.admin_secret.arn
        ]
      }
    ]
  })
}

# ==============================================================================
# IAM Policy Attachments
# ------------------------------------------------------------------------------
# Purpose:
#   - Attaches AWS-managed and custom policies to the EC2 role.
#
# Notes:
#   - AmazonSSMManagedInstanceCore enables SSM Session Manager access.
# ==============================================================================

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ec2_secrets_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

# ==============================================================================
# IAM Instance Profile
# ------------------------------------------------------------------------------
# Purpose:
#   - Exposes the EC2 Secrets role to EC2 instances at launch time.
# ==============================================================================

resource "aws_iam_instance_profile" "ec2_secrets_profile" {
  name = "EC2SecretsInstanceProfile-${var.netbios}"
  role = aws_iam_role.ec2_secrets_role.name
}
