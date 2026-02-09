# ==============================================================================
# Active Directory Naming Inputs
# ------------------------------------------------------------------------------
# Purpose:
#   - Defines core naming inputs used by the mini-AD deployment.
#
# Scope:
#   - dns_zone: Fully qualified AD DNS domain.
#   - realm:    Kerberos realm name derived from the DNS domain.
#   - netbios:  Short domain name for legacy and NetBIOS-aware systems.
#
# Notes:
#   - Keep realm aligned with dns_zone. Kerberos tooling expects uppercase
#     realm names by convention.
# ==============================================================================

# ==============================================================================
# Variable: dns_zone
# ------------------------------------------------------------------------------
# Purpose:
#   - Fully qualified DNS domain name for the Active Directory forest.
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
#   - Short NetBIOS domain name used by legacy Windows and SMB flows.
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
# Variable: vpc_name
# ------------------------------------------------------------------------------
# Purpose:
#   - Name for the VPC to create
# ==============================================================================

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "mini-ad-vpc"
}
