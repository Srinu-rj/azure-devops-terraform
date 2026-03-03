locals {
  cdn_multi_region = var.cdn_application
}
resource "azurerm_resource_group" "cdn_rg" {
  for_each = local.cdn_multi_region

  name     = each.value.cdn_rg_name
  location = each.value.cdn_rg_location

}

resource "azurerm_virtual_network" "cdn_v_net" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_v_net
  location            = azurerm_resource_group.cdn_rg[each.key].location
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name
  address_space       = each.value.cdn_v_net_cidr


}

resource "azurerm_subnet" "cdn_private_subnet" {
  for_each = local.cdn_multi_region

  name                 = each.value.cdn_private_subnet
  resource_group_name  = azurerm_resource_group.cdn_rg[each.key].name
  virtual_network_name = azurerm_virtual_network.cdn_v_net[each.key].name
  address_prefixes     = each.value.cdn_private_subnet_cidr


}

resource "azurerm_route_table" "cdn_private_route_table" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_private_route_table_name
  location            = azurerm_resource_group.cdn_rg[each.key].location
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name

  route {
    name           = each.value.route_sub_name
    address_prefix = each.value.address_prefix #"10.1.0.0/16"
    next_hop_type  = each.value.hop_type       #"VnetLocal"
  }

}

resource "azurerm_subnet_route_table_association" "cdn_private_sub_route_association" {
  for_each = local.cdn_multi_region

  route_table_id = azurerm_route_table.cdn_private_route_table[each.key].id
  subnet_id      = azurerm_subnet.cdn_private_subnet[each.key].id
}

resource "azurerm_network_security_group" "cdn_network_security" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_security_group_name
  location            = azurerm_resource_group.cdn_rg[each.key].location
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_watcher" "cdn_network_watcher" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_network_watcher_name #"production-nwwatcher"
  location            = azurerm_resource_group.cdn_rg[each.key].location
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name
}

resource "azurerm_storage_account" "cdn_network_watcher_logs_storage" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_network_storage_logs_name
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name
  location            = azurerm_resource_group.cdn_rg[each.key].location

  account_tier               = each.value.account_tier #"Standard"
  account_kind               = each.value.account_kind #"StorageV2"
  account_replication_type   = each.value.account_replication_type
  https_traffic_only_enabled = true


}

resource "azurerm_log_analytics_workspace" "cdn_log_analytics_workspace" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_log_analytics_workspace_name
  location            = azurerm_resource_group.cdn_rg[each.key].location
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name
  sku                 = each.value.cdn_log_analytics_workspace #"PerGB2018"


}

resource "azurerm_network_watcher_flow_log" "network_watcher_flow_log" {
  for_each = local.cdn_multi_region

  name                      = each.value.network_watcher_flow_log_name
  network_watcher_name      = azurerm_network_watcher.cdn_network_watcher[each.key].name
  resource_group_name       = azurerm_resource_group.cdn_rg[each.key].name
  network_security_group_id = azurerm_network_security_group.cdn_network_security[each.key].id
  storage_account_id        = azurerm_storage_account.cdn_network_watcher_logs_storage[each.key].id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.cdn_log_analytics_workspace[each.key].workspace_id
    workspace_region      = azurerm_log_analytics_workspace.cdn_log_analytics_workspace[each.key].location
    workspace_resource_id = azurerm_log_analytics_workspace.cdn_log_analytics_workspace[each.key].id
    interval_in_minutes   = 10
  }

}
resource "azurerm_public_ip" "cdn_public_ip" {
  for_each = local.cdn_multi_region

  name                = each.value.cdn_public_ip_name
  location            = azurerm_resource_group.cdn_rg[each.key].location
  resource_group_name = azurerm_resource_group.cdn_rg[each.key].name
  allocation_method   = each.value.allocation_method #"Static"
  sku                 = each.value.public_ip_sku     #"Standard"
  zones               = each.value.ip_zones          #["1", "2", "3"]

}
