// NOTE: This step is to create a W2K19 MDT Automation Framework Server / Managed Premium LRS Disk / and some Applications
locals {
  virtual_machine_name_jh2 = var.azdvops2
  virtual_machine_fqdn_jh2 = "${var.azdvops2}.${var.active_directory_domain}"
  custom_data_params_jh2   = "Param($RemoteHostName = \"${local.virtual_machine_fqdn_jh2}\", $ComputerName = \"${local.virtual_machine_name_jh2}\")"
  custom_data_content_jh2  = "${local.custom_data_params_jh2} ${file("${path.module}/files/winrm.ps1")}"
}

resource "azurerm_network_interface" "jh2" {
  name                      = "${var.prefix}nic-001"
  location                  = var.location
  resource_group_name       = var.rg
  internal_dns_name_label   = local.virtual_machine_name_jh2
    tags = {
    NIC = "for AFCE MDT Server - N4K - AF LAB"
  }
  depends_on                = [azurerm_subnet.Server]
  
  ip_configuration {
    name                          = "jh2"
    subnet_id                     = azurerm_subnet.Server.id
    private_ip_address_allocation = "static"
    private_ip_address            = "172.21.1.11"
  }
}

resource "azurerm_subnet_network_security_group_association" "RDP" {
  subnet_id                 = azurerm_subnet.Server.id
  network_security_group_id = azurerm_network_security_group.RDP.id
}

resource "azurerm_virtual_machine" "azweudevops02" {
  name                = var.azdvops2
  location            = var.location
  resource_group_name = var.rg
  vm_size             = "Standard_D2s_v3"
  network_interface_ids         = (azurerm_network_interface.jh2.*.id)
  delete_os_disk_on_termination = true
  depends_on                    = [azurerm_network_interface.jh2]
  tags = {
    VM = "W2K19 - MDT - Automation Framework"
  }

  storage_image_reference {
    publisher = var.Windows-Server-Publisher
    offer     = var.Windows-Server-Offer
    sku       = var.W2K19
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.prefix}dsk-001"
    managed_disk_type = "Premium_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.storlrsdiag.primary_blob_endpoint
  }
  os_profile {
    computer_name  = var.azdvops2
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = local.custom_data_content_jh2
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("${path.module}/files/FirstLogonCommands.xml")
    }
  }
}
