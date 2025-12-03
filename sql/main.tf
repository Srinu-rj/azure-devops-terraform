locals {
    resource_group = "sql-rg"
    location       = "centralindia"
}

resource "azurerm_resource_group" "sql_rg" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_mssql_server" "example1" {
  name                         = "example-sqlserver"
  resource_group_name          = local.resource_group
  location                     = local.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_database" "example1" {
  name         = "example-db"
  server_id    = azurerm_mssql_server.example1.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = {
    foo = "bar"
  }

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}
