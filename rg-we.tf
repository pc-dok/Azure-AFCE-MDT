// NOTE: Create Ressource Groups in Azure West Europe
resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
  tags = {
    RG = "for N4K - Automation Framework LAB"
  }
}

