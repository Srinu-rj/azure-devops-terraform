variable "resource_group_name" { default = "appgw-rg-prod" }
variable "location"            { default = "East US" }
variable "environment"         { default = "prod" }
variable "appgw_name"          { default = "my-app-gateway" }

variable "sku_name"     { default = "WAF_v2" }   # Standard_v2 or WAF_v2
variable "sku_tier"     { default = "WAF_v2" }
variable "capacity"     { default = 2 }           # instance count

variable "backends" {
  description = "Backend pools"
  type = list(object({
    name  = string
    fqdns = list(string)
  }))
  default = [
    {
      name  = "app-backend"
      fqdns = ["myapp.azurewebsites.net"]
    },
    {
      name  = "api-backend"
      fqdns = ["myapi.azurewebsites.net"]
    }
  ]
}