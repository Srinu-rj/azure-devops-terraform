terraform init
terraform validate
terraform plan -var-file="values.tfvars"
terraform apply -var-file="values.tfvars"
terraform apply -var-file="values.tfvars" -auto-approve
terraform destroy -var-file="values.tfvars" -auto-approve

terraform apply -target=azurerm_resource_group.dns_rg["dev"] -var-file="values.tfvars" --auto-approve
terraform apply -target=azurerm_resource_group.dns_rg["qa"] -var-file="values.tfvars" --auto-approve
terraform apply -target=azurerm_resource_group.dns_rg["prod"] -var-file="values.tfvars" --auto-approve

terraform apply -target=azurerm_resource_group.dns_rg -var-file="values.tfvars" -auto-approve
terraform apply -target=azurerm_dns_zone.dns_zone -var-file="values.tfvars" -auto-approve
terraform apply -target=azurerm_dns_a_record.example -var-file="values.tfvars" -auto-approve
terraform apply -var-file="values.tfvars" -auto-approve


