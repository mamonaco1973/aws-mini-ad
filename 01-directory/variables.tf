# ==============================================================================
# Active Directory Naming Inputs
# ------------------------------------------------------------------------------
# Purpose:
#   - Defines domain naming inputs for the mini-AD deployment.
#
# Scope:
#   - dns_zone: AD DNS zone / domain (FQDN) used by Samba AD DC.
#   - realm:    Kerberos realm (typically dns_zone in uppercase).
#   - netbios:  Short domain name used by legacy / NetBIOS-aware systems.
#   - user_base_dn: LDAP base DN where demo users are created.
#
# Notes:
#   - Keep realm aligned with dns_zone. Kerberos is case-sensitive by
#     convention and expects uppercase realms in most tooling.
# ==============================================================================

# ==============================================================================
# Variable: dns_zone
# ------------------------------------------------------------------------------
# Purpose:
#   - Fully qualified AD DNS zone / domain name for the directory.
# ==============================================================================

variable "dns_zone" {
  description = "AD DNS zone / domain (e.g., mcloud.mikecloud.com)"
  type        = string
  default     = "mcloud.mikecloud.com"
}

# ==============================================================================
# Variable: realm
# ------------------------------------------------------------------------------
# Purpose:
#   - Kerberos realm name. Typically the dns_zone value in uppercase.
# ==============================================================================

variable "realm" {
  description = "Kerberos realm (e.g., MCLOUD.MIKECLOUD.COM)"
  type        = string
  default     = "MCLOUD.MIKECLOUD.COM"
}

# ==============================================================================
# Variable: netbios
# ------------------------------------------------------------------------------
# Purpose:
#   - Short NetBIOS domain name used by legacy Windows / SMB flows.
#
# Notes:
#   - NetBIOS names are commonly <= 15 characters and uppercase.
# ==============================================================================

variable "netbios" {
  description = "NetBIOS short domain name (e.g., MCLOUD)"
  type        = string
  default     = "MCLOUD"
}

# ==============================================================================
# Variable: user_base_dn
# ------------------------------------------------------------------------------
# Purpose:
#   - Base DN for creating demo users in LDAP.
# ==============================================================================

variable "user_base_dn" {
  description = "User base DN (e.g., CN=Users,DC=mcloud,DC=mikecloud,DC=com)"
  type        = string
  default     = "CN=Users,DC=mcloud,DC=mikecloud,DC=com"
}
