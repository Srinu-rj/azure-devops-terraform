cdn_application = {

  "dev_env" = {
    #RG
    cdn_rg_name     = "cdn_rg"
    cdn_rg_location = "Central US"

    #vnet
    cdn_v_net      = "cdn_vnet"
    cdn_v_net_cidr = "[10.0.0.0/16]"

    # subnet
    cdn_private_subnet      = "cdn_private_subnet"
    cdn_private_subnet_cidr = "[10.0.1.0/24]"

    #route_table
    cdn_private_route_table_name = "cdn_route_table"
    route_sub_name               = "route1"
    address_prefix               = "10.1.0.0/16"
    hop_type                     = "VnetLocal"

    # security_group
    cdn_security_group_name = "cdn_security_name"

    #network_watcher
    cdn_network_watcher_name = "cdn_network_watcher"

    # storage
    cdn_network_storage_logs_name ="cdn_network_storage_logs"
    account_tier                  = "Standard"
    account_kind                  = "StorageV2"
    account_replication_type      = "LRS"

    # analytics
    cdn_log_analytics_workspace_name = "cdn_log_analytics_workspace"
    cdn_log_analytics_workspace      = "cdn_log_analytics_workspace"

    # network_watcher_flow_log
    network_watcher_flow_log_name = "network_watcher_flow_log_name"

    # public_ip
    cdn_public_ip_name = "cdn_public_ip_name"
    allocation_method  = "Static"
    public_ip_sku      = "Standard"
    ip_zones           = ["1", "2", "3"]
  }

}


