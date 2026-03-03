variable "aks_rg_name" { type = string }
variable "location" { type = string }

variable "aks_vnet_name" { type = string }
variable "aks_vnet_cidr" { type = list(string) }

variable "aks_public_subnet_name" { type = string }
variable "aks_private_subnet_name" { type = string }

variable "aks_public_subnet_cidr" { type = list(string) }
variable "aks_private_subnet_cidr" { type = list(string) }

variable "azp_token" {
  description = "Azure DevOps PAT Token"
  type        = string
  sensitive   = true
}
variable "azp_url" {
  type    = string
  default = "https://dev.azure.com/sreenivasad0208"
}
variable "azp_pool" {
  type    = string
  default = "self-hosted"
}
variable "azp_agent_name" {
  type    = string
  default = "self-hosted-pipeline"
}