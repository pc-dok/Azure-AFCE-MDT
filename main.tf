// Note: Using a single workspace in terraform cloud for remote state tf file

#terraform {
#  backend "remote" {
#    hostname     = "app.terraform.io"
#    organization = "N4K"
#
#    workspaces {
#      name = "N4K-UAC-AF1"
#    }
#  }
#}

//Note: This is only my Azure Login Credentials for my UMB Visual Studio Enterprise MPN Account

provider "azurerm" {
  #version = "=2.7"
  subscription_id = "18074942-d5bd-48bc-af90-4af06d9526d5"
  tenant_id       = "8e7d5e9c-e72c-4d0b-9a7e-34aba5e8581c"
  features {}
}