# Creating a Key Vault

# Get current identity
data "azurerm_client_config" "current" {}

# Resource group
resource "azurerm_resource_group" "main" {
  name     = "rg-myapp-production"
  location = "East US"
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-myapp-prod"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true

  # Enable RBAC authorization (recommended over access policies)
  enable_rbac_authorization = true

  # Network restrictions
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ips
  }
}

# Grant the current user admin access via RBAC
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Storing Secrets
# Store a database password
resource "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  value        = random_password.database.result
  key_vault_id = azurerm_key_vault.main.id

  content_type = "password"

  # Set an expiration date
  expiration_date = "2027-02-23T00:00:00Z"

  tags = {
    environment = "production"
    service     = "database"
  }

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Store an API key
resource "azurerm_key_vault_secret" "api_key" {
  name         = "external-api-key"
  value        = var.external_api_key
  key_vault_id = azurerm_key_vault.main.id

  content_type = "api-key"

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Store a JSON secret with multiple fields
resource "azurerm_key_vault_secret" "db_connection" {
  name         = "database-connection"
  key_vault_id = azurerm_key_vault.main.id

  value = jsonencode({
    server   = azurerm_postgresql_server.main.fqdn
    database = "myapp"
    username = "admin"
    password = random_password.database.result
    port     = 5432
    ssl      = true
  })

  content_type = "application/json"

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Generate the random password
resource "random_password" "database" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

# ========================================
# TODO RBAC (Recommended)
# ========================================
resource "azurerm_role_assignment" "secrets_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"    # Read secrets
  principal_id         = var.app_principal_id
}

resource "azurerm_role_assignment" "secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"  # Read and write secrets
  principal_id         = var.admin_principal_id
}

resource "azurerm_role_assignment" "crypto_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto User"      # Use keys for crypto operations
  principal_id         = var.crypto_principal_id
}
# ========================================
# TODO Certificate Management
# ========================================
resource "azurerm_key_vault_certificate" "app" {
  name         = "app-tls-cert"
  key_vault_id = azurerm_key_vault.main.id

  certificate {
    contents = filebase64("certs/app.pfx")
    password = var.cert_password
  }

  depends_on = [azurerm_role_assignment.kv_admin]
}

# Generate a self-signed certificate (useful for development)
resource "azurerm_key_vault_certificate" "dev" {
  name         = "dev-tls-cert"
  key_vault_id = azurerm_key_vault.main.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      subject            = "CN=dev.example.com"
      validity_in_months = 12

      subject_alternative_names {
        dns_names = ["dev.example.com", "*.dev.example.com"]
      }

      key_usage = [
        "digitalSignature",
        "keyEncipherment"
      ]
    }
  }

  depends_on = [azurerm_role_assignment.kv_admin]
}


# ========================================
# TODO Using Managed Identities
# ========================================
# Create a user-assigned managed identity
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-myapp-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Grant the identity access to read Key Vault secrets
resource "azurerm_role_assignment" "app_secrets_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# Assign the identity to an App Service
resource "azurerm_linux_web_app" "main" {
  name                = "app-myapp-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  site_config {}

  # Reference Key Vault secrets in app settings
  app_settings = {
    "DATABASE_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_password.versionless_id})"
    "API_KEY"           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.api_key.versionless_id})"
  }
}

