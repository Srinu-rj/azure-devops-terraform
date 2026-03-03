resource "azurerm_resource_group" "aks_rg" {
  name     = var.aks_rg_name
  location = var.location
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks_vnet_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = var.aks_vnet_cidr
}

resource "azurerm_subnet" "acr_private_subnet" {
  name                 = var.aks_public_subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.aks_public_subnet_cidr
}

resource "azurerm_subnet" "aks_private_subnet" {
  name                 = var.aks_private_subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.aks_private_subnet_cidr
}

# TODO ==> Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link.
#  Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet.
#  The service could be an Azure service such as Azure Storage, SQL, etc. or your own Private Link Service.
resource "azurerm_public_ip" "pub_ip" {
  name                = "public_ip"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "nsg-app"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ============================================
# TODO SSH KEY GENERATION
# ============================================
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key_file" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "D:/azure_keys/private_key.pem"
  file_permission = "0600"   # ✅ fixes permission denied error on SSH
}
resource "local_file" "public_key_file" {
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = "D:/azure_keys/public_key.pub"
  file_permission = "0644"
}
resource "azurerm_ssh_public_key" "custom_ss_key_pem" {
  name                = "custom_ss_key_pem"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  public_key          = tls_private_key.ssh_key.public_key_openssh
}
# ============================================
# TODO NETWORK INTERFACE
# ============================================

resource "azurerm_network_interface" "ind" {
  name                = "aks_interface"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aks_private_subnet.id
    public_ip_address_id          = azurerm_public_ip.pub_ip.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}
resource "azurerm_network_interface_security_group_association" "network_interface_security_group_association" {
  network_interface_id      = azurerm_network_interface.ind.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# resource "azurerm_storage_account" "azure_vm_snap" {
#   name                     = "storageaccountname"
#   resource_group_name      = azurerm_resource_group.aks_rg.name
#   location                 = azurerm_resource_group.aks_rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
# }
# Define the disk
# resource "azurerm_managed_disk" "data_disk" {
#   name                 = "data-disk"
#   location             = azurerm_resource_group.aks_rg.location
#   resource_group_name  = azurerm_resource_group.aks_rg.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 50
# }
# # Attach to VM
# resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
#   managed_disk_id    = azurerm_managed_disk.data_disk.id
#   virtual_machine_id = azurerm_linux_virtual_machine.self_hosted_agent.id
#   lun                = 0
#   caching            = "ReadWrite"
# }

# ============================================
# TODO LINUX VIRTUAL MACHINE
# ============================================
resource "azurerm_linux_virtual_machine" "self_hosted_agent" {
  name                            = "azureselfhostedagent"
  resource_group_name             = azurerm_resource_group.aks_rg.name
  location                        = azurerm_resource_group.aks_rg.location
  size                            = "Standard_D4s_v3"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  # settings = jsonencode({
  #   script = base64encode(file("${path.module}/self-hosted-agent.sh"))
  # })
  #
  # boot_diagnostics {
  #   storage_account_uri = null  # uses Azure-managed storage
  # }

  admin_ssh_key {
    username   = "adminuser"
    public_key = azurerm_ssh_public_key.custom_ss_key_pem.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  network_interface_ids = [azurerm_network_interface.ind.id]
}

# resource "azurerm_dev_test_global_vm_shutdown_schedule" "global_vm_shutdown_schedule" {
#   virtual_machine_id   = azurerm_linux_virtual_machine.self_hosted_agent.id
#   location             = azurerm_resource_group.aks_rg.location
#   enabled              = true
#   daily_recurrence_time = "1700"
#   timezone             = "Pacific Standard Time"
#
#   notification_settings {
#     enabled          = true
#     time_in_minutes  = 60
#     webhook_url      = "https://example.com/webhook"
#   }
# }
#
# resource "azurerm_virtual_machine_extension" "virtual_machine_extension" {
#   name                 = "custom-script"
#   virtual_machine_id   = azurerm_linux_virtual_machine.self_hosted_agent.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.1"
#
#   settings = jsonencode({
#     script = base64encode(file("${path.module}/your_script.sh"))
#   })
# }

# ============================================
#TODO  SCRIPT EXECUTION ON VM
# ============================================
resource "null_resource" "devops_self_hosted_agent" {

  triggers = {
    script_hash = filemd5("${path.module}/self-hosted-agent-02.sh")
    vm_id       = azurerm_linux_virtual_machine.self_hosted_agent.id
  }

  depends_on = [
    azurerm_linux_virtual_machine.self_hosted_agent,
    azurerm_network_interface_security_group_association.network_interface_security_group_association
  ]

  # Step 1 — wait for VM SSH to be ready
  provisioner "remote-exec" {
    inline = ["echo 'VM is ready'"]

    connection {
      type        = "ssh"
      user        = azurerm_linux_virtual_machine.self_hosted_agent.admin_username
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = azurerm_public_ip.pub_ip.ip_address
      timeout     = "5m"
    }
  }

  # Step 2 — upload script
  provisioner "file" {
    source      = "${path.module}/self-hosted-agent-02.sh"
    destination = "/tmp/self-hosted-agent-02.sh"    # ✅ filename must match

    connection {
      type        = "ssh"
      user        = azurerm_linux_virtual_machine.self_hosted_agent.admin_username
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = azurerm_public_ip.pub_ip.ip_address
      timeout     = "5m"
    }
  }

  # Step 3 — execute with token passed
  provisioner "remote-exec" {
    inline = [
      # ✅ Fix 1 — update first, then install dos2unix
      "sudo apt-get update -y",
      "sudo apt-get install -y dos2unix",

      # ✅ Fix 2 — correct filename
      "dos2unix /tmp/self-hosted-agent-02.sh",
      "chmod +x /tmp/self-hosted-agent-02.sh",

      # ✅ Fix 3 — pass AZP_TOKEN and all vars to script
      "export AZP_TOKEN='${var.azp_token}' && export AZP_URL='${var.azp_url}' && export AZP_POOL='${var.azp_pool}' && export AZP_AGENT_NAME='${var.azp_agent_name}' && sudo -E bash /tmp/self-hosted-agent-02.sh 2>&1 | tee /tmp/install.log"
    ]

    connection {
      type        = "ssh"
      user        = azurerm_linux_virtual_machine.self_hosted_agent.admin_username
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = azurerm_public_ip.pub_ip.ip_address
      timeout     = "30m"    # ✅ increased — dotnet + angular take time
    }
  }
}

# Define the disk
# resource "azurerm_managed_disk" "data_disk" {
#   name                 = "data-disk"
#   location             = azurerm_resource_group.aks_rg.location
#   resource_group_name  = azurerm_resource_group.aks_rg.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 50
# }
#
# # Attach to VM
# resource "azurerm_virtual_machine_data_disk_attachment" "attach" {
#   managed_disk_id    = azurerm_managed_disk.data_disk.id
#   virtual_machine_id = azurerm_linux_virtual_machine.self_hosted_agent.id
#   lun                = 0
#   caching            = "ReadWrite"
# }
# ============================================
# TODO OUTPUTS
# ============================================
output "vm_public_ip" {
  value = azurerm_public_ip.pub_ip.ip_address
}

output "ssh_command" {
  value = "ssh -i D:/azure_keys/private_key.pem adminuser@${azurerm_public_ip.pub_ip.ip_address}"
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}


# terraform apply -var-file="input.tfvars" -auto-approve
# terraform plan -var-file="input.tfvars"
