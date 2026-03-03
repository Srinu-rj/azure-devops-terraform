locals {
  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "application-gateway"
  }

  # ✅ Name references used inside appgw resource
  frontend_ip_config_name      = "appgw-frontend-ip"
  frontend_port_http_name      = "appgw-port-80"
  frontend_port_https_name     = "appgw-port-443"

  # Backend pool names
  app_backend_pool_name        = "app-backend-pool"
  api_backend_pool_name        = "api-backend-pool"

  # HTTP settings names
  app_http_setting_name        = "app-http-setting"
  api_http_setting_name        = "api-http-setting"

  # Listener names
  http_listener_name           = "http-listener"
  https_app_listener_name      = "https-app-listener"
  https_api_listener_name      = "https-api-listener"

  # Routing rule names
  http_redirect_rule_name      = "http-to-https-redirect"
  app_routing_rule_name        = "app-routing-rule"
  api_routing_rule_name        = "api-routing-rule"

  # Probe names
  app_probe_name               = "app-health-probe"
  api_probe_name               = "api-health-probe"

  # Redirect config name
  http_redirect_config_name    = "http-redirect-config"

  # SSL cert name
  ssl_cert_name                = "appgw-ssl-cert"
}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "appgw_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "appgw_vnet" {
  name                = "appgw-vnet"
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.appgw_rg.name
  virtual_network_name = azurerm_virtual_network.appgw_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend-subnet"
  resource_group_name  = azurerm_resource_group.appgw_rg.name
  virtual_network_name = azurerm_virtual_network.appgw_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-public-ip"
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]   # ✅ zone redundant
  domain_name_label   = "my-app-gateway-0208"
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "appgw_nsg" {
  name                = "appgw-nsg"
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name

  # ✅ Required — AppGW management ports
  security_rule {
    name                       = "Allow-AppGW-Ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  # ✅ Allow HTTP
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # ✅ Allow HTTPS
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # ✅ Allow Azure Load Balancer
  security_rule {
    name                       = "Allow-AzureLoadBalancer"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "appgw_nsg_assoc" {
  subnet_id                 = azurerm_subnet.appgw_subnet.id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
}

resource "azurerm_log_analytics_workspace" "appgw_logs" {
  name                = "appgw-logs-workspace"
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.common_tags
}

resource "azurerm_application_gateway" "web_application_gateway" {
  name                = ""
  location            = azurerm_resource_group.appgw_rg.location
  resource_group_name = azurerm_resource_group.appgw_rg.name
  zones = []
  fips_enabled = false
  enable_http2 = true
  force_firewall_policy_association = true
  firewall_policy_id = ""

  backend_address_pool {
    name = ""
    fqdns = []
    ip_addresses = []
  }
  backend_http_settings {
    cookie_based_affinity = ""
    name                  = ""
    port                  = 0
    protocol              = ""
  }

  sku {
    name = ""
    tier = ""
  }

  global {
    request_buffering_enabled  = false
    response_buffering_enabled = false
  }

  frontend_ip_configuration {
    name = ""
    private_ip_address = ""
    private_ip_address_allocation = ""
    private_link_configuration_name = ""
    subnet_id = ""
  }
  frontend_port {
    name = ""
    port = 80
  }

  http_listener {
    frontend_ip_configuration_name = ""
    frontend_port_name             = ""
    name                           = ""
    protocol                       = ""
  }

  probe {
    interval            = 0
    name                = ""
    path                = ""
    protocol            = ""
    timeout             = 0
    unhealthy_threshold = 0
  }
  http_listener {
    frontend_ip_configuration_name = ""
    frontend_port_name             = ""
    name                           = ""
    protocol                       = ""
  }

  request_routing_rule {
    http_listener_name = ""
    name               = ""
    rule_type          = ""
  }
}

resource "azurerm_monitor_diagnostic_setting" "appgw_diagnostics" {
  name                       = "appgw-diagnostics"
  target_resource_id         = azurerm_application_gateway.web_application_gateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.appgw_logs.id

  enabled_log { category = "ApplicationGatewayAccessLog" }
  enabled_log { category = "ApplicationGatewayPerformanceLog" }
  enabled_log { category = "ApplicationGatewayFirewallLog" }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_action_group" "appgw_alerts" {
  name                = "appgw-action-group"
  resource_group_name = azurerm_resource_group.appgw_rg.name
  short_name          = "appgwrtf"

  email_receiver {
    name                    = "devops-team"
    email_address           = "devops@mycompany.com"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "unhealthy_hosts" {
  name                = "appgw-unhealthy-hosts"
  resource_group_name = azurerm_resource_group.appgw_rg.name
  scopes              = [azurerm_application_gateway.web_application_gateway.id]
  description         = "Alert when backend hosts are unhealthy"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.appgw_alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "failed_requests" {
  name                = "appgw-failed-requests"
  resource_group_name = azurerm_resource_group.appgw_rg.name
  scopes              = [azurerm_application_gateway.web_application_gateway.id]
  description         = "Alert when failed requests exceed threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "FailedRequests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.appgw_alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "waf_blocked" {
  name                = "appgw-waf-blocked"
  resource_group_name = azurerm_resource_group.appgw_rg.name
  scopes              = [azurerm_application_gateway.web_application_gateway.id]
  description         = "Alert when WAF blocks requests"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "BlockedReqCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.appgw_alerts.id
  }
}