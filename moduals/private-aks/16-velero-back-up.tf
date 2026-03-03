# ============================================================
# LOCALS
# ============================================================
locals {
  common_tags = {
    environment = "prod"
    managed_by  = "terraform"
    purpose     = "velero-backup"
  }

  aks_node_resource_group = data.azurerm_kubernetes_cluster.aks.node_resource_group
}

# ============================================================
# DATA SOURCES
# ============================================================
data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  resource_group_name = "aks-rg-prod"
}

data "azurerm_resource_group" "aks_rg" {
  name = "aks-rg-prod"
}

# ============================================================
# STEP 1 — Resource Group
# ============================================================
resource "azurerm_resource_group" "velero_rg" {
  name     = "velero-backup-rg"
  location = "East US"
  tags     = local.common_tags
}

# ============================================================
# STEP 2 — Storage Account
# ============================================================
resource "azurerm_storage_account" "velero_storage" {
  name                     = "velerobackups0208"
  resource_group_name      = azurerm_resource_group.velero_rg.name
  location                 = azurerm_resource_group.velero_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 14
    }

    container_delete_retention_policy {
      days = 14
    }
  }

  tags = local.common_tags
}

# ============================================================
# STEP 3 — Storage Container
# ============================================================
resource "azurerm_storage_container" "velero_backups" {
  name                  = "velero-backups"
  storage_account_name  = azurerm_storage_account.velero_storage.name
  container_access_type = "private"
}

# ============================================================
# STEP 4 — Lifecycle Policy
# ============================================================
resource "azurerm_storage_management_policy" "velero_lifecycle" {
  storage_account_id = azurerm_storage_account.velero_storage.id

  rule {
    name    = "delete-old-backups"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["velero-backups/"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 30
      }
    }
  }
}

# ============================================================
# STEP 5 — Managed Identity for Velero
# ============================================================
resource "azurerm_user_assigned_identity" "velero_identity" {
  name                = "velero-identity"
  location            = azurerm_resource_group.velero_rg.location
  resource_group_name = azurerm_resource_group.velero_rg.name
  tags                = local.common_tags
}

# ============================================================
# STEP 6 — Role Assignments
# ============================================================

# Storage access
resource "azurerm_role_assignment" "velero_storage_contributor" {
  principal_id         = azurerm_user_assigned_identity.velero_identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.velero_storage.id
}

# Disk snapshot access
resource "azurerm_role_assignment" "velero_disk_snapshot" {
  principal_id         = azurerm_user_assigned_identity.velero_identity.principal_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.aks_node_resource_group}"
}

# AKS resource group access
resource "azurerm_role_assignment" "velero_aks_rg_contributor" {
  principal_id         = azurerm_user_assigned_identity.velero_identity.principal_id
  role_definition_name = "Contributor"
  scope                = data.azurerm_resource_group.aks_rg.id
}

# ============================================================
# STEP 7 — Federated Identity Credential
# ============================================================
resource "azurerm_federated_identity_credential" "velero_federated" {
  name                = "velero-federated-credential"
  resource_group_name = azurerm_resource_group.velero_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.velero_identity.id
  subject             = "system:serviceaccount:velero:velero"
}

# ============================================================
# STEP 8 — Kubernetes Namespace
# ============================================================
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"

    labels = {
      "app.kubernetes.io/name" = "velero"
      environment              = "prod"
    }
  }
}

# ============================================================
# STEP 9 — Kubernetes Service Account
# ============================================================
resource "kubernetes_service_account" "velero" {
  metadata {
    name      = "velero"
    namespace = kubernetes_namespace.velero.metadata[0].name

    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.velero_identity.client_id
    }

    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

# ============================================================
# STEP 10 — Cloud Credentials Secret
# ============================================================
resource "kubernetes_secret" "velero_credentials" {
  metadata {
    name      = "velero-credentials"
    namespace = kubernetes_namespace.velero.metadata[0].name
  }

  data = {
    "cloud" = <<EOF
AZURE_SUBSCRIPTION_ID=${data.azurerm_client_config.current.subscription_id}
AZURE_TENANT_ID=${data.azurerm_client_config.current.tenant_id}
AZURE_CLIENT_ID=${azurerm_user_assigned_identity.velero_identity.client_id}
AZURE_RESOURCE_GROUP=${local.aks_node_resource_group}
AZURE_CLOUD_NAME=AzurePublicCloud
EOF
  }
}

# ============================================================
# STEP 11 — Install Velero via Helm
# ============================================================
resource "helm_release" "velero" {
  name             = "velero"
  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  namespace        = kubernetes_namespace.velero.metadata[0].name
  version          = "5.2.0"
  create_namespace = false
  cleanup_on_fail  = true
  atomic           = true
  timeout          = 600

  values = [<<EOF
image:
  repository: velero/velero
  tag: v1.12.2
  pullPolicy: IfNotPresent

initContainers:
  - name: velero-plugin-for-azure
    image: velero/velero-plugin-for-microsoft-azure:v1.8.2
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins

credentials:
  useSecret: true
  existingSecret: velero-credentials

configuration:
  provider: azure

  backupStorageLocation:
    - name: default
      provider: azure
      bucket: velero-backups
      config:
        resourceGroup:           velero-backup-rg
        storageAccount:          velerobackups0208
        subscriptionId:          ${data.azurerm_client_config.current.subscription_id}
        storageAccountKeyEnvVar: AZURE_STORAGE_ACCOUNT_ACCESS_KEY

  volumeSnapshotLocation:
    - name: default
      provider: azure
      config:
        resourceGroup:  ${local.aks_node_resource_group}
        subscriptionId: ${data.azurerm_client_config.current.subscription_id}

serviceAccount:
  server:
    create: false
    name: velero

resources:
  requests:
    cpu:    500m
    memory: 512Mi
  limits:
    cpu:    1000m
    memory: 1024Mi

replicas: 2

metrics:
  enabled: true
  scrapeInterval: 30s
  serviceMonitor:
    enabled: true
    additionalLabels:
      release: kube-prometheus-stack

features: EnableCSI

deployNodeAgent: true
nodeAgent:
  resources:
    requests:
      cpu:    200m
      memory: 256Mi
    limits:
      cpu:    500m
      memory: 512Mi

upgradeCRDs:  true
cleanUpCRDs:  false
EOF
  ]

  depends_on = [
    kubernetes_service_account.velero,
    kubernetes_secret.velero_credentials,
    azurerm_storage_container.velero_backups,
    azurerm_role_assignment.velero_storage_contributor,
    azurerm_role_assignment.velero_disk_snapshot,
    azurerm_federated_identity_credential.velero_federated,
  ]
}

# ============================================================
# STEP 12 — Backup Schedules
# ============================================================

# Daily backup — all namespaces at 2AM
resource "kubernetes_manifest" "daily_backup_schedule" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "daily-backup"
      namespace = "velero"
    }
    spec = {
      schedule = "0 2 * * *"
      template = {
        ttl                     = "720h"
        storageLocation         = "default"
        volumeSnapshotLocations = ["default"]
        excludedNamespaces      = ["kube-system", "velero", "cert-manager"]
        includeClusterResources = true
        hooks                   = {}
      }
    }
  }
  depends_on = [helm_release.velero]
}

# Hourly backup — production namespace only
resource "kubernetes_manifest" "hourly_backup_schedule" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "hourly-backup"
      namespace = "velero"
    }
    spec = {
      schedule = "0 * * * *"
      template = {
        ttl                     = "24h"
        storageLocation         = "default"
        volumeSnapshotLocations = ["default"]
        includedNamespaces      = ["production"]
        excludedNamespaces      = ["kube-system", "velero", "cert-manager"]
        includeClusterResources = true
        hooks                   = {}
      }
    }
  }
  depends_on = [helm_release.velero]
}

# ============================================================
# STEP 13 — Initial Full Backup
# ============================================================
resource "kubernetes_manifest" "initial_backup" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Backup"
    metadata = {
      name      = "initial-full-backup"
      namespace = "velero"
    }
    spec = {
      ttl                     = "720h"
      storageLocation         = "default"
      volumeSnapshotLocations = ["default"]
      excludedNamespaces      = ["kube-system", "velero"]
      includeClusterResources = true
    }
  }
  depends_on = [helm_release.velero]
}

# ============================================================
# STEP 14 — Action Group for Alerts
# ============================================================
resource "azurerm_monitor_action_group" "velero_alerts" {
  name                = "velero-alerts"
  resource_group_name = azurerm_resource_group.velero_rg.name
  short_name          = "velerortf"

  email_receiver {
    name                    = "devops-team"
    email_address           = "devops@mycompany.com"
    use_common_alert_schema = true
  }
}

# ============================================================
# STEP 15 — Metric Alert for Failed Backups
# ============================================================
resource "azurerm_monitor_metric_alert" "velero_backup_failed" {
  name                = "velero-backup-failed"
  resource_group_name = azurerm_resource_group.velero_rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id]
  description         = "Alert when Velero backup fails"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "velero_backup_failure_total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.velero_alerts.id
  }
}

# ============================================================
# OUTPUTS
# ============================================================
output "storage_account_name" {
  value = azurerm_storage_account.velero_storage.name
}

output "backup_container_name" {
  value = azurerm_storage_container.velero_backups.name
}

output "velero_identity_client_id" {
  value = azurerm_user_assigned_identity.velero_identity.client_id
}

output "check_velero_status" {
  value = "kubectl get pods -n velero"
}

output "check_backup_locations" {
  value = "velero backup-location get"
}

output "create_manual_backup" {
  value = "velero backup create manual-backup --include-namespaces production"
}

output "restore_backup" {
  value = "velero restore create --from-backup initial-full-backup"
}