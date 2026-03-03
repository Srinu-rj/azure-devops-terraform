variable "environments" {
  description = "List of environments"
  type        = list(string)
  default     = ["dev", "qa", "prod"]
}

variable "regions" {
  description = "List of regions"
  type        = list(string)
  default     = ["East US", "West Europe", "Australia East"]
}

variable "cosmos_postgres_rg_names" {
  description = "Map of resource group names for each environment"
  type        = map(string)
  default     = {
    dev  = "dev-cosmos-postgres-rg"
    qa   = "qa-cosmos-postgres-rg"
    prod = "prod-cosmos-postgres-rg"
  }
}

variable "csm_postgresql_cluster_names" {
  description = "Map of cluster names for each environment"
  type        = map(string)
  default     = {
    dev  = "dev-cosmosdb-postgresql-cluster"
    qa   = "qa-cosmosdb-postgresql-cluster"
    prod = "prod-cosmosdb-postgresql-cluster"
  }
}

variable "csm_pg_coordinator_configuration_names" {
  description = "Map of coordinator configuration names for each environment"
  type        = map(string)
  default     = {
    dev  = "dev-coordinator-config"
    qa   = "qa-coordinator-config"
    prod = "prod-coordinator-config"
  }
}

variable "csm_pg_fire_wall_names" {
  description = "Map of firewall rule names for each environment"
  type        = map(string)
  default     = {
    dev  = "dev-firewall-rule"
    qa   = "qa-firewall-rule"
    prod = "prod-firewall-rule"
  }
}

variable "csm_pg_node_config_names" {
  description = "Map of node configuration names for each environment"
  type        = map(string)
  default     = {
    dev  = "dev-node-config"
    qa   = "qa-node-config"
    prod = "prod-node-config"
  }
}

variable "start_ip_address" {
  description = "Start IP address for firewall rules"
  type        = string
  default     = "10.0.17.64"
}

variable "end_ip_address" {
  description = "End IP address for firewall rules"
  type        = string
  default     = "10.0.17.62"
}
