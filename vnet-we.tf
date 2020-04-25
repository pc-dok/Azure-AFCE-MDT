// NOTE: Create vLAN Segment with 3 Subnets in Azure West Europe
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}vn-001"
  address_space       = ["172.21.0.0/16"]
  location            = var.location
  resource_group_name = var.rg

  // dns_servers         = ["172.31.2.11", "172.31.2.12", "8.8.8.8"] // activate when needed
  depends_on = [azurerm_resource_group.rg]
  tags = {
    VNET = "for N4K - Automation Framework LAB"
  }
}

resource "azurerm_subnet" "Server" {
  name                 = "Server"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "172.21.1.0/24"
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "172.21.2.0/24"
}

resource "azurerm_subnet" "Internet" {
  name                 = "Internet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "172.21.3.0/24"
}

