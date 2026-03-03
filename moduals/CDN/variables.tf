# ✅ Recommended — tags as map
variable "cdn_application" {
  description = "Deployment Application on CDN "

  type = map(object({
    #RG
    cdn_rg_name     = string
    cdn_rg_location = string

    #tags
    # cdn_tags=map(string)

    #vnet
    cdn_v_net      = string
    cdn_v_net_cidr = list(string)

    # subnet
    cdn_private_subnet      = string
    cdn_private_subnet_cidr = list(string)

    #route_table
    cdn_private_route_table_name = string
    route_sub_name               = string
    address_prefix               = list(string)
    hop_type                     = string

    # security_group
    cdn_security_group_name = string

    #network_watcher
    cdn_network_watcher_name = string

    # storage
    cdn_network_storage_logs_name = string
    account_tier                  = string
    account_kind                  = string
    account_replication_type      = string

    # analytics
    cdn_log_analytics_workspace_name = string
    cdn_log_analytics_workspace      = string

    # network_watcher_flow_log
    network_watcher_flow_log_name = string

    # public_ip
    cdn_public_ip_name = string
    allocation_method  = string
    public_ip_sku      = string
    ip_zones           = list(string)

  }))
}

