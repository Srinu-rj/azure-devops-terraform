dns_env = {
  dev = {
    name         = "rg-dns-dev"
    location     = "East US"
    domain_name  = "dev.mycompany.com"    # ✅ added
    dns_a_record = "dev"
    ip_address   = ["10.0.1.4"]
  }

  qa = {
    name         = "rg-dns-qa"
    location     = "Central US"
    domain_name  = "qa.mycompany.com"     # ✅ added
    dns_a_record = "qa"
    ip_address   = ["10.0.2.5"]
  }

  prod = {
    name         = "rg-dns-prod"
    location     = "West US"
    domain_name  = "prod.mycompany.com"   # ✅ added
    dns_a_record = "prod"
    ip_address   = ["10.0.3.6"]
  }
}