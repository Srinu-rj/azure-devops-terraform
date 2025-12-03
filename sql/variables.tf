variable "srinu-devops" {
  default     = "srinu-devops-azure-rg"
  type        = string
  description = "The name of the resource group"
}
variable "location" {
  default     = "centralindia"
  type        = string
  description = "The Azure region where the resources will be created"
}
variable "subscription_id" {
  default   = "5c13e26b-0015-4f32-aace-8ea1b3236fd8"
  type      = string
  sensitive = true
}
variable "tenant_id" {
  default   = "ca345dcb-a4f0-4ade-85e4-391bb1fc16cd"
  type      = string
  sensitive = true
}
variable "client_id" {
  default     = "c097cdb1-5858-453c-a548-b1e5b6c8c941"
  type        = string
  sensitive   = true
  description = "client id of the service principal"
}
variable "client_secret" {
  default   = "tGA8Q~01emg_KgKhXK-sAFHVTbsbN3hmHLtF3af~"
  type      = string
  sensitive = true
}
variable "storage_account_name" {
  default     = "srinudevopsvivedhika"
  type        = string
  description = "The name of the storage account. Must be between 3 and 24 characters in length and"
}

# export TF_VAR_subscription_id="5c13e26b-0015-4f32-aace-8ea1b3236fd8"
# export TF_VAR_tenant_id="ca345dcb-a4f0-4ade-85e4-391bb1fc16cd"
# export TF_VAR_client_id="c097cdb1-5858-453c-a548-b1e5b6c8c941"
# export TF_VAR_client_secret="tGA8Q~01emg_KgKhXK-sAFHVTbsbN3hmHLtF3af~"
