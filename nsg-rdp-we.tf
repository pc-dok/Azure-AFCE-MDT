# ************************** NETWORK SECURITY GROUPS - NSG - RDP **************************** #
resource "azurerm_network_security_group" "RDP" {
  name                = "${var.prefix}nsg-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    NSG = "for RDP Port 3389"
  }

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  depends_on = [azurerm_resource_group.rg]
}

