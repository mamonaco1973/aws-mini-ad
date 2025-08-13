variable "dns_zone" {
  description = "AD DNS zone / domain (e.g., mcloud.mikecloud.com)"
  default      = "mcloud.mikecloud.com"
  type        = string
}

variable "realm" {
  description = "Kerberos realm (usually DNS zone in UPPERCASE, e.g., MCLOUD.MIKECLOUD.COM)"
  default     = "MCLOUD.MIKECLOUD.COM"
  type        = string
}

variable "netbios" {
  description = "NetBIOS short domain name (e.g., MCLOUD)"
  default     = "MCLOUD"
  type        = string
}
