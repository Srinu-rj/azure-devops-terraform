data "azurerm_resource_group" "aks_rg" {
  name = "aks_rg"
}
data "azurerm_virtual_network" "aks_vnet" {
  name                = "aks_vnet"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}

resource "random_password" "random_pass" {
  length = 8
  special = true
  upper = true
  numeric = true
}


resource "azurerm_public_ip" "load_balancer_public_ip" {
  name                = "PublicIPForLB"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "azure_load_balancer" {
  name                = "azure_load_balancer"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name = "PublicIPAddress",
    public_ip_address_id = azurerm_public_ip.load_balancer_public_ip.id
  }

  depends_on = [
    azurerm_public_ip.load_balancer_public_ip
  ]
}
resource "azurerm_lb_outbound_rule" "lb_outbound_rule" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.azure_load_balancer.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}

resource "azurerm_lb_rule" "azure_lb_rule" {
  backend_port                   = 1133 #TODO Back-End application port number
  frontend_ip_configuration_name = azurerm_lb.azure_load_balancer.frontend_ip_configuration.name #"PublicIPAddress"
  frontend_port                  = 8080 #TODO Fronted-end application port number
  loadbalancer_id                = azurerm_lb.azure_load_balancer.id
  name                           = "azure_load_balancer_rule"
  protocol                       = "Tcp"
}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {
  loadbalancer_id = azurerm_lb.azure_load_balancer.id
  name            = "BackEndAddressPool"
}
resource "azurerm_lb_backend_address_pool_address" "lb_backend_address_pool_address"" {
  name                                = "address1"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.lb_backend_address_pool.id
  backend_address_ip_configuration_id = azurerm_lb.azure_load_balancer.frontend_ip_configuration[0].id
}

resource "azurerm_lb_nat_pool" "lb_nat_pool" {
  resource_group_name            = data.azurerm_resource_group.aks_rg.name
  loadbalancer_id                = azurerm_lb.azure_load_balancer.id
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  resource_group_name            = data.azurerm_resource_group.aks_rg.name
  loadbalancer_id                = azurerm_lb.azure_load_balancer.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port_start            = 3000
  frontend_port_end              = 3389
  backend_port                   = 3389
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool.id
  frontend_ip_configuration_name = "PublicIPAddress"
}