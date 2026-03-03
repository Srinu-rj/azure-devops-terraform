locals {
  environment_region_pairs = [
    for env in var.environments : [
      for region in var.regions : {
        environment = env
        region      = region
      }
    ]
  ]
}

resource "azurerm_resource_group" "cosmos_postgres" {
  for_each = tomap({
    for pair in local.environment_region_pairs : "${pair.environment}-${pair.region}" => pair
  })

  location = each.value.region
  name     = "${var.cosmos_postgres_rg_names[each.value.environment]}-${each.value.region}"
}

resource "azurerm_cosmosdb_postgresql_cluster" "cosmosdb_postgresql_cluster" {
  for_each = azurerm_resource_group.cosmos_postgres

  location            = each.value.location
  name                = var.csm_postgresql_cluster_names[each.value.environment]
  node_count          = 2
  resource_group_name = each.value.name
  administrator_login_password    = "H@Sh1CoR3!"
  coordinator_storage_quota_in_mb = 131072
  coordinator_vcore_count         = 2
  node_storage_quota_in_mb        = 131072
  node_vcores                     = 2
}

resource "azurerm_cosmosdb_postgresql_coordinator_configuration" "csm_pg_coordinator_configuration" {
  for_each = azurerm_cosmosdb_postgresql_cluster.cosmosdb_postgresql_cluster

  cluster_id = each.value.id
  name       = var.csm_pg_coordinator_configuration_names[each.value.environment]
  value      = "on"
}

resource "azurerm_cosmosdb_postgresql_firewall_rule" "csm_pg_firewall" {
  for_each = azurerm_cosmosdb_postgresql_cluster.cosmosdb_postgresql_cluster

  cluster_id       = each.value.id
  end_ip_address   = var.end_ip_address
  name             = var.csm_pg_fire_wall_names[each.key].
  start_ip_address = var.start_ip_address
}

resource "azurerm_cosmosdb_postgresql_node_configuration" "csm_pg_node_config" {
  for_each = azurerm_cosmosdb_postgresql_cluster.cosmosdb_postgresql_cluster

  cluster_id = each.value.id
  name       = var.csm_pg_node_config_names[each.value.environment]
  value      = "on"
}
