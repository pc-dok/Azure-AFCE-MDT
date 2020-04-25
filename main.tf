// Note: Using a single workspace in terraform cloud for remote state tf file

#terraform {
#  backend "remote" {
#    hostname     = "app.terraform.io"
#    organization = "yourID"
#
#    workspaces {
#      name = "yourRepo"
#    }
#  }
#}

provider "azurerm" {
  #version = "=2.7"
  subscription_id = "yourId"
  tenant_id       = "yourID"
  features {}
}
