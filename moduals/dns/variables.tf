variable "dns_env" {
  description = "DNS environments configuration"

  type = map(object({
    name         = string
    location     = string
    domain_name  = string
    dns_a_record = string
    ip_address   = list(string)
  }))
}