# ==============================================================================
# Active Directory Administrator Credentials
# ------------------------------------------------------------------------------
# Purpose:
#   - Generates a strong random password for the AD Administrator account.
#   - Stores administrator credentials securely in AWS Secrets Manager.
#
# Notes:
#   - Credentials are consumed during domain controller bootstrap.
#   - Secret deletion is allowed to simplify teardown of test environments.
# ==============================================================================

resource "random_password" "admin_password" {
  length           = 24
  special          = true
  override_special = "_-."
}

resource "aws_secretsmanager_secret" "admin_secret" {
  name        = "admin_ad_credentials"
  description = "Active Directory administrator credentials"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "admin_secret_version" {
  secret_id = aws_secretsmanager_secret.admin_secret.id

  secret_string = jsonencode({
    username = "${var.netbios}\\Admin"
    password = random_password.admin_password.result
  })
}

# ==============================================================================
# Active Directory Test User: John Smith
# ------------------------------------------------------------------------------
# Purpose:
#   - Creates a demo AD user account with randomized credentials.
#   - Stores credentials securely in AWS Secrets Manager.
# ==============================================================================

resource "random_password" "jsmith_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

resource "aws_secretsmanager_secret" "jsmith_secret" {
  name        = "jsmith_ad_credentials"
  description = "John Smith AD credentials"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "jsmith_secret_version" {
  secret_id = aws_secretsmanager_secret.jsmith_secret.id

  secret_string = jsonencode({
    username = "${var.netbios}\\jsmith"
    password = random_password.jsmith_password.result
  })
}

# ==============================================================================
# Active Directory Test User: Emily Davis
# ==============================================================================

resource "random_password" "edavis_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

resource "aws_secretsmanager_secret" "edavis_secret" {
  name        = "edavis_ad_credentials"
  description = "Emily Davis AD credentials"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "edavis_secret_version" {
  secret_id = aws_secretsmanager_secret.edavis_secret.id

  secret_string = jsonencode({
    username = "${var.netbios}\\edavis"
    password = random_password.edavis_password.result
  })
}

# ==============================================================================
# Active Directory Test User: Raj Patel
# ==============================================================================

resource "random_password" "rpatel_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

resource "aws_secretsmanager_secret" "rpatel_secret" {
  name        = "rpatel_ad_credentials"
  description = "Raj Patel AD credentials"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "rpatel_secret_version" {
  secret_id = aws_secretsmanager_secret.rpatel_secret.id

  secret_string = jsonencode({
    username = "${var.netbios}\\rpatel"
    password = random_password.rpatel_password.result
  })
}

# ==============================================================================
# Active Directory Test User: Amit Kumar
# ==============================================================================

resource "random_password" "akumar_password" {
  length           = 24
  special          = true
  override_special = "!@#$%"
}

resource "aws_secretsmanager_secret" "akumar_secret" {
  name        = "akumar_ad_credentials"
  description = "Amit Kumar AD credentials"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_secretsmanager_secret_version" "akumar_secret_version" {
  secret_id = aws_secretsmanager_secret.akumar_secret.id

  secret_string = jsonencode({
    username = "${var.netbios}\\akumar"
    password = random_password.akumar_password.result
  })
}
