# Init
terraform init

# Plan
terraform plan

# Apply in order
terraform apply -target=azurerm_resource_group.velero_rg                    -auto-approve
terraform apply -target=azurerm_storage_account.velero_storage              -auto-approve
terraform apply -target=azurerm_storage_container.velero_backups            -auto-approve
terraform apply -target=azurerm_user_assigned_identity.velero_identity      -auto-approve
terraform apply -target=azurerm_role_assignment.velero_storage_contributor  -auto-approve
terraform apply -target=azurerm_role_assignment.velero_disk_snapshot        -auto-approve
terraform apply -target=azurerm_federated_identity_credential.velero_federated -auto-approve
terraform apply -target=kubernetes_namespace.velero                         -auto-approve
terraform apply -target=kubernetes_service_account.velero                   -auto-approve
terraform apply -target=kubernetes_secret.velero_credentials                -auto-approve
terraform apply -target=helm_release.velero                                 -auto-approve
terraform apply                                                             -auto-approve