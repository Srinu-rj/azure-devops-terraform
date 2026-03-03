output "appgw_name" {
  value = azurerm_application_gateway.appgw.name
}

output "appgw_id" {
  value = azurerm_application_gateway.appgw.id
}

output "public_ip_address" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "public_fqdn" {
  value = azurerm_public_ip.appgw_pip.fqdn
}

output "backend_pool_app" {
  value = local.app_backend_pool_name
}

output "backend_pool_api" {
  value = local.api_backend_pool_name
}

output "appgw_urls" {
  value = {
    http_url  = "http://${azurerm_public_ip.appgw_pip.fqdn}"
    https_url = "https://${azurerm_public_ip.appgw_pip.fqdn}"
    app_url   = "https://myapp.mycompany.com"
    api_url   = "https://api.mycompany.com"
  }
}
