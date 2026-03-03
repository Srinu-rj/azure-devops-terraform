#TODO Vnet Ids
data "azurerm_resource_group" "aks_rg" {
  name = "aks-rg"
}
data "azurerm_virtual_network" "aks_vnet" {
  name                = "aks_vnet"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}
data "azurerm_virtual_network" "acr_vnet" {
  name                = "acr_vnet"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}
data "azurerm_virtual_network" "agent_vnet" {
  name                = "agent_vnet"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}
data "azurerm_container_registry" "acr_container" {
  name                = "spring" #ACR NAME
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}
data "azurerm_subnet" "aks_subnet" {
  name                 = "private_aks_subnet"
  resource_group_name  = data.azurerm_resource_group.aks_rg.name
  virtual_network_name = data.azurerm_virtual_network.aks_vnet.name
}
data "azurerm_subnet" "private_aks_subnet" {
  name = "aks_public_subnet"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  virtual_network_name = data.azurerm_virtual_network.aks_vnet.name
}
#TODO PRIVATE DNS
resource "azurerm_private_dns_zone" "private_dns_for_aks" {
  name                = "privatelink.centralindia.azmk8s.io"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "aks_private_dns_network_link"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_for_aks.name
  resource_group_name   = data.azurerm_resource_group.aks_rg.name
  virtual_network_id    = data.azurerm_virtual_network.aks_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "aks_acr" {
  name                  = "aks_acr_private_dns_link"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_for_aks.name
  resource_group_name   = data.azurerm_resource_group.aks_rg.name
  virtual_network_id    = data.azurerm_virtual_network.acr_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "aks_agent" {
  name                  = "aks_agent_private_dns_link"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_for_aks.name
  resource_group_name   = data.azurerm_resource_group.aks_rg.name
  virtual_network_id    = data.azurerm_virtual_network.agent_vnet.id
}

#TODO Identity
resource "azurerm_user_assigned_identity" "aks_user_identity" {
  name                = var.aks_user_identity
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
}

#TODO Identity role assignment
resource "azurerm_role_assignment" "dns_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks_user_identity.id
  role_definition_name = "Private DNS Zone Contributor"
  scope                = azurerm_private_dns_zone.private_dns_for_aks.id
}
resource "azurerm_role_assignment" "private_dns_contributor" {
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_identity.id
  scope                = azurerm_private_dns_zone.private_dns_for_aks.id
}
resource "azurerm_role_assignment" "aks_acr_pull_role" {
  role_definition_name = "AcrPull"
  principal_id         = azurerm_private_dns_zone.private_dns_for_aks.id
  scope                = data.azurerm_container_registry.acr_container.id
}
resource "azurerm_role_assignment" "vnet_subnet_contributor" {
  role_definition_name = "aks_role_assignment"
  principal_id         = azurerm_private_dns_zone.private_dns_for_aks.id
  scope                = data.azurerm_virtual_network.aks_vnet.id
}
resource "azurerm_role_assignment" "role_assignment" {
  scope                = data.azurerm_resource_group.aks_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_user_identity.principal_id
}

#TODO  Grant AKS identity access to Key Vault
# resource "azurerm_role_assignment" "aks_secrets" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_kubernetes_cluster.main.key_vault_secrets_provider[0].secret_identity[0].object_id
# }

locals {
  env= var.env
  eks_name= aks_cluster_name
  eks_version= aks_version
  resource_group_name=var.rg_name
}

resource "azurerm_kubernetes_cluster" "aks_cluster_backend" {
  name                = "${local.env}-${local.eks_name}"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  dns_prefix          = "devaks1"


  kubernetes_version = local.eks_version
  # automatic_channel_upgrade = "stable"
  private_cluster_enabled = false
  node_resource_group     = "${local.resource_group_name}-${local.env}-${local.eks_name}"

  # For production change to "Standard"
  sku_tier                  = "Free"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_policy_enabled      = true


  # default_node_pool {
  #   name           = "default"
  #   node_count     = 2
  #   vm_size        = "Standard_D2as_v5"
  #   vnet_subnet_id = azurerm_subnet.subnet1.id
  # }

  default_node_pool {
    name                  = "default"
    vm_size               = "Standard_D2as_v5"
    orchestrator_version  = local.eks_version
    type                  = "VirtualMachineScaleSets"
    vnet_subnet_id        = data.azurerm_subnet.aks_subnet.id
    enable_node_public_ip = false
    node_count            = 2
    enable_auto_scaling = true
    min_count = 1
    max_count = 3
    os_disk_size_gb = 100
    os_disk_type    = "Managed"
    os_sku          = "Ubuntu"


    node_network_profile {}

    node_labels = {
      role = "general"
    }
  }

  # TODO Calico is a Kubernetes CNI (Container Network Interface) plugin that supports both overlay and non-overlay networking modes.
  #  while overlay refers to a general networking concept used by several CNIs, including Flannel and Weave Net.
  #  Use Calico without overlay (BGP mode) for high-performance, scalable, production clusters.Use Calico overlay only when the underlying network cannot route Pod IPs.
  network_profile {
    network_plugin    = "azure" # ✅
    dns_service_ip    = "10.0.64.10"
    service_cidr      = "10.0.64.0/19"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    # network_mode      = "overlay"
  }

  # TODO Note: Managed Identity is not available for all services in Azure, Its available mainly for PAAS services.
  # TODO ==>  Use system-assigned when you need a unique identity per resource with automatic cleanup.
  # identity {
  #   type = "SystemAssigned"
  # }

  # TODO ==> Use user-assigned when you need shared identities, pre-authorization, or reduced management overhead across multiple resources.
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_user_identity.id]
  }

  #TODO Enabling Azure Key Vault in AKS
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
  #TODO ==> Enable internal or external ingress gateways using ingress_gateway_internal and ingress_gateway_external blocks
  service_mesh_profile {
    mode = "Istio"
    revisions = ["asm-1-25"]
    ingress_gateway_internal {
      enabled = true
    }
    ingress_gateway_external {
      enabled = true
    }
  }

  # TODO  SecurityPatch ==> Applies only security patches. This is the default and recommended for most production workloads. It follows safe deployment practices and honors maintenance windows.
  # TODO  NodeImage ==> Performs full node image reimages. This channel is used when you want to ensure the latest OS image is applied, but it can cause more disruption\
  # TODO  None  ==> Disables automatic OS upgrades (not recommended for production).
  node_os_channel_upgrade = "NodeImage" #SecurityPatch


  tags = {
    Environment = local.env
  }

  depends_on = [
    azurerm_user_assigned_identity.aks_user_identity
  ]

  # TODO ==> Entra ID + Kubernetes RBAC
  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
  }
  local_account_disabled = true


  # kubectl config get-contexts
  provisioner "local-exec" {
    command = "az aks get-credentials --name ${self.name} --resource-group ${data.azurerm_resource_group.aks_rg.name} --admin --overwrite-existing"
  }
}
resource "azurerm_log_analytics_workspace" "main" {
  name                = "logs"
  location            = data.azurerm_resource_group.aks_rg.location
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.env
}