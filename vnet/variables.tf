variable "subscription_id" {
  description = "The Subscription ID for the Azure account."
  type        = string
}
variable "tenant_id" {
  description = "The Tenant ID for the Azure account."
  type        = string
}
variable "client_id" {
  description = "the Client ID for the Azure account."
  type        = string
}
variable "client_secret" {
  description = "The Client Secret for the Azure account."
  type        = string
}
variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
}
variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}
variable "resource_group_vnet" {
  description = "The name of the Resource Group for the Virtual Network."
  type        = string
}
variable "resource_group" {
  description = "The name of the Resource Group."
  type        = string
}
