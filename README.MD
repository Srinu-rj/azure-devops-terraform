# Apply only the VM
terraform apply -target=azurerm_linux_virtual_machine.self_hosted_agent

# Apply only the VNet
terraform apply -target=azurerm_virtual_network.aks_vnet

# Apply only the NSG
terraform apply -target=azurerm_network_security_group.app_nsg

# Apply only SSH key
terraform apply -target=tls_private_key.ssh_key

# Apply only the script runner
terraform apply -target=null_resource.devops_self_hosted_agent

# Apply multiple specific resources
terraform apply \
-target=azurerm_resource_group.aks_rg \
-target=azurerm_virtual_network.aks_vnet \
-target=azurerm_subnet.aks_private_subnet


# Step 1 — Resource Group first (everything depends on it)
terraform apply -target=azurerm_resource_group.aks_rg -auto-approve

# Step 2 — Networking
terraform apply -target=azurerm_virtual_network.aks_vnet -auto-approve
terraform apply -target=azurerm_subnet.acr_private_subnet -auto-approve
terraform apply -target=azurerm_subnet.aks_private_subnet -auto-approve

# Step 3 — Security
terraform apply -target=azurerm_network_security_group.app_nsg -auto-approve
terraform apply -target=azurerm_public_ip.pub_ip -auto-approve

# Step 4 — SSH Keys
terraform apply -target=tls_private_key.ssh_key -auto-approve
terraform apply -target=azurerm_ssh_public_key.custom_ss_key_pem -auto-approve

# Step 5 — Network Interface
terraform apply -target=azurerm_network_interface.ind -auto-approve
terraform apply -target=azurerm_network_interface_security_group_association.network_interface_security_group_association -auto-approve

# Step 6 — Virtual Machine
terraform apply -target=azurerm_linux_virtual_machine.self_hosted_agent -auto-approve

# Step 7 — Run Script on VM
terraform apply -target=null_resource.devops_self_hosted_agent -auto-approve

[//]: # (Destroy Specific Resources)
# Destroy only the VM
terraform destroy -target=azurerm_linux_virtual_machine.self_hosted_agent -auto-approve

# Destroy only the script runner (re-triggers script on next apply)
terraform destroy -target=null_resource.devops_self_hosted_agent -auto-approve

# Destroy everything
terraform destroy -auto-approve

# Useful Day-to-Day Commands
# See current state of all resources
terraform show

# List all resources in state
terraform state list

# See details of one resource
terraform state show azurerm_linux_virtual_machine.self_hosted_agent

# Remove resource from state (without destroying it)
terraform state rm null_resource.devops_self_hosted_agent

# Re-run script only (destroy + apply null_resource)
terraform destroy -target=null_resource.devops_self_hosted_agent -auto-approve
terraform apply  -target=null_resource.devops_self_hosted_agent -auto-approve

# Format all tf files
terraform fmt

# Validate all tf files
terraform validate

# See output values
terraform output
terraform output -raw ssh_command
terraform output -raw private_key

# TODO ==> Multiple Environments (workspaces)
==============================================

# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# Apply to specific workspace
terraform workspace select prod
terraform apply -var-file="values.tfvars" --auto-approve

# List workspaces
terraform workspace list