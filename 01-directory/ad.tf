# ==============================================================================
# Mini Active Directory (mini-ad) - Module Invocation
# ------------------------------------------------------------------------------
# Purpose:
#   - Invokes the reusable "mini-ad" module to deploy a lightweight Samba 4 AD
#     domain controller on Ubuntu.
#
# Scope:
#   - Supplies domain identity (NETBIOS, realm, DNS zone) and networking inputs
#     (VPC + subnet placement).
#   - Passes an AD admin password and a rendered JSON payload used to create
#     demo users during bootstrap.
#
# Notes:
#   - The instance bootstrap may require outbound internet access for package
#     installation. Ensure NAT + route associations exist before provisioning.
# ==============================================================================

module "mini_ad" {
  # GitHub repo source for the reusable module.
  source = "github.com/mamonaco1973/module-aws-mini-ad"

  # Domain identity inputs.
  netbios = var.netbios
  realm   = var.realm
  dns_zone = var.dns_zone

  # Directory structure inputs.
  user_base_dn = var.user_base_dn
  users_json   = local.users_json

  # Authentication inputs.
  ad_admin_password = random_password.admin_password.result

  # Networking placement inputs.
  vpc_id    = aws_vpc.ad-vpc.id
  subnet_id = aws_subnet.ad-subnet.id

  # Ensure NAT + route association exist before instance bootstrap.
  depends_on = [
    aws_nat_gateway.ad_nat,
    aws_route_table_association.rt_assoc_ad_private
  ]
}

# ==============================================================================
# Local Variable: users_json
# ------------------------------------------------------------------------------
# Purpose:
#   - Renders ./scripts/users.json.template into a single JSON blob.
#
# Scope:
#   - Injects domain naming inputs and per-user random passwords.
#   - The module consumes this blob during bootstrap to create demo accounts.
#
# Notes:
#   - Keep the template stable and let Terraform populate runtime values.
# ==============================================================================

locals {
  users_json = templatefile("./scripts/users.json.template", {
    USER_BASE_DN = var.user_base_dn
    DNS_ZONE     = var.dns_zone
    REALM        = var.realm
    NETBIOS      = var.netbios

    jsmith_password = random_password.jsmith_password.result
    edavis_password = random_password.edavis_password.result
    rpatel_password = random_password.rpatel_password.result
    akumar_password = random_password.akumar_password.result
  })
}
