// NOTE: Create the Storage Account for Boot Diagnostic for VM's
resource "azurerm_storage_account" "storlrsdiag" {
  name                     = var.storlrsdiag
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    STG = "for VM BootDiagnostic - N4K - AF LAB"
  }
  depends_on = [azurerm_resource_group.rg]
}

