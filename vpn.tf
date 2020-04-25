resource "azurerm_local_network_gateway" "On-Premises" {
  name                = "${var.prefix}ln-gw-001"
  resource_group_name = var.rg
  location            = var.location
  gateway_address     = var.your-public_ip
  address_space       = var.local-address_space
  tags = {
    LNGW = "for S2S VPN - N4K - AF LAB"
  }
  depends_on = [azurerm_subnet.GatewaySubnet]
}

resource "azurerm_public_ip" "vpn-gw-pip" {
  name                = "${var.prefix}pip-001"
  location            = var.location
  resource_group_name = var.rg
  allocation_method = "Dynamic"
  tags = {
    PIP = "for S2S VPN - N4K - AF LAB"
  }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_virtual_network_gateway" "vpn-gateway" {
  name                = "${var.prefix}vn-gw-001"
  location            = var.location
  resource_group_name = var.rg

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn-gw-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
  }
  tags = {
    VGW = "for S2S Gateway Connection - N4K - AF LAB"
  }
  depends_on = [azurerm_public_ip.vpn-gw-pip]
}

resource "azurerm_virtual_network_gateway_connection" "VPNGW_S2S_CONN" {
  name                = "${var.prefix}gw-con-001"
  location            = var.location
  resource_group_name = var.rg
    #Site-2-Site: IPSec
    #ExpressRoute: ExpressRoute
    #VNet-2-VNet: Vnet2Vnet
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn-gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.On-Premises.id
  shared_key = "yoursharedsecret"
  tags = {
    CON = "for S2S Gateway Connection - N4K - AF LAB"
  }
  depends_on = [azurerm_virtual_network_gateway.vpn-gateway]
}
