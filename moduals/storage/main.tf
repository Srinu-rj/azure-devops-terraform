# ============================================================
# STORAGE ACCOUNT
# ============================================================
resource "azurerm_storage_account" "storage" {
  name                     = "mystorageaccount0208"   # must be globally unique
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Standard"               # Standard or Premium
  account_replication_type = "LRS"                    # LRS, GRS, ZRS, RAGRS

  # ✅ Enable blob access tier (required for Cool/Hot/Archive)
  access_tier = "Hot"                                 # default account-level tier

  blob_properties {
    # ✅ Enable versioning
    versioning_enabled = true

    # ✅ Enable soft delete for blobs
    delete_retention_policy {
      days = 7
    }

    # ✅ Enable soft delete for containers
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "dev"
    team        = "devops"
  }
}

# ============================================================
# BLOB CONTAINER
# ============================================================
resource "azurerm_storage_container" "container" {
  name                  = "mycontainer"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"   # private, blob, container
}

# ── HOT Blob ─────────────────────────────────────────────
resource "azurerm_storage_blob" "hot_blob" {
  name                   = "hot-data/myfile.json"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${path.module}/files/myfile.json"
  access_tier            = "Hot"       # ✅ frequent access — highest cost, lowest latency
}

# ── COOL Blob ────────────────────────────────────────────
resource "azurerm_storage_blob" "cool_blob" {
  name                   = "cool-data/archive.zip"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${path.module}/files/archive.zip"
  access_tier            = "Cool"      # ✅ infrequent access — lower cost, min 30 days
}

# ── ARCHIVE Blob ─────────────────────────────────────────
resource "azurerm_storage_blob" "archive_blob" {
  name                   = "archive-data/backup.tar.gz"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${path.module}/files/backup.tar.gz"
  access_tier            = "Archive"   # ✅ rare access — cheapest, hours to rehydrate
}

resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.storage.id

  rule {
    name    = "lifecycle-rule"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["logs/", "backups/"]   # apply to specific folders
    }

    actions {
      base_blob {
        # ✅ Move to Cool after 30 days
        tier_to_cool_after_days_since_modification_greater_than = 30

        # ✅ Move to Cold after 60 days (between Cool and Archive)
        tier_to_cold_after_days_since_modification_greater_than = 60

        # ✅ Move to Archive after 90 days
        tier_to_archive_after_days_since_modification_greater_than = 90

        # ✅ Delete after 365 days
        delete_after_days_since_modification_greater_than = 365
      }

      # ✅ Clean up snapshots
      snapshot {
        tier_to_cool_after_days_since_creation_greater_than    = 30
        tier_to_archive_after_days_since_creation_greater_than = 90
        delete_after_days_since_creation_greater_than          = 180
      }

      # ✅ Clean up versions
      version {
        tier_to_cool_after_days_since_creation_greater_than    = 30
        tier_to_archive_after_days_since_creation_greater_than = 90
        delete_after_days_since_creation_greater_than          = 180
      }
    }
  }

  # ── Second rule for VM backups ──────────────────────────
  rule {
    name    = "vm-backup-rule"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["vm-backups/"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 7
        tier_to_archive_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than          = 90
      }
    }
  }
}

# ── HOT Storage Account ───────────────────────────────────
resource "azurerm_storage_account" "hot_storage" {
  name                     = "hotstorage0208"
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"     # ✅ Hot tier

  tags = { tier = "hot", purpose = "active-data" }
}

# ── COOL Storage Account ──────────────────────────────────
resource "azurerm_storage_account" "cool_storage" {
  name                     = "coolstorage0208"
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"    # ✅ Cool tier

  tags = { tier = "cool", purpose = "infrequent-data" }
}

# ── ARCHIVE Container (within Standard account) ───────────
# Note: Archive tier is set at BLOB level, not account level
resource "azurerm_storage_container" "archive_container" {
  name                  = "archive"
  storage_account_name  = azurerm_storage_account.cool_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_account" "full_storage" {
  name                     = "fullstorage0208"
  resource_group_name      = azurerm_resource_group.aks_rg.name
  location                 = azurerm_resource_group.aks_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"         # Geo-redundant
  access_tier              = "Hot"         # default tier

  # ✅ Security
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true

  # ✅ Blob settings
  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true    # track last access for lifecycle

    delete_retention_policy {
      days = 14
    }

    container_delete_retention_policy {
      days = 14
    }

    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST", "PUT"]
      allowed_origins    = ["https://yourdomain.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  # ✅ Network rules
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = [azurerm_subnet.aks_private_subnet.id]
  }

  tags = {
    environment = "dev"
    team        = "devops"
  }
}