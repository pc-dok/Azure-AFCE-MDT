// NOTE: Create the Storage Account for ISO Fileshare and Homes
resource "azurerm_storage_account" "storlrssmb" {
  name                     = var.storlrssmb
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    STG = "for ISO Fileshare and Homes - N4K - AF LAB"
  }
  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_storage_share" "ISO" {
  name                 = "isos"
  storage_account_name = azurerm_storage_account.storlrssmb.name
  quota                = 4096
  depends_on = [azurerm_storage_account.storlrssmb]
}

resource "azurerm_storage_share" "Homes" {
  name                 = "homes"
  storage_account_name = azurerm_storage_account.storlrssmb.name
  quota                = 4096
  depends_on = [azurerm_storage_account.storlrssmb]
}
