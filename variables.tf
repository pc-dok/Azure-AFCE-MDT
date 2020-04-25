# General Variables for this Example
variable "prefix" {
  type        = string
  default     = "n4k-v01-we-"
  description = "The prefix used for all resources in this example. Needs to be a short (6 characters) alphanumeric string. Example: `myprefix`."
}

variable "prefix2" {
  type        = string
  default     = "n4k-v01-ne-"
  description = "The prefix used for all resources in this example. Needs to be a short (6 characters) alphanumeric string. Example: `myprefix`."
}

variable "rg" {
  type        = string
  default     = "n4k-v01-we-001"
  description = "Ressoure Group for Azure Dev Ops"
}

variable "rg2" {
  type        = string
  default     = "n4k-v01-ne-001"
  description = "Ressoure Group for Azure Dev Ops"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "The location from Azure Ressource"
}

variable "location2" {
  type        = string
  default     = "northeurope"
  description = "The location from Azure Ressource"
}

variable "storlrsdiag" {
  type        = string
  default     = "stgn4kv01wediag001"
  description = "Storage Account for Boot Diagnostic"
}

variable "storlrssmb" {
  type        = string
  default     = "stgn4kv01wesmb001"
  description = "Storage Account for SMB Azure File Share"
}

variable "active_directory_domain" {
  type        = string
  default     = "lab.local"
  description = "The name of the Active Directory domain, for example `consoto.local`"
}

variable "your-public_ip" {
  type        = string
  default     = "1.1.1.1"
  description = "Your Public IP"
}

variable "local-address_space" {
  default     = ["192.168.1.0/24"]
  description = "Your Local IP Address Space"
}

variable "azdvops1" {
  type        = string
  default     = "vsrvazwe-mdt-02"
  description = "Azure Dev OPS VM for IAC - Windows Server 2016"
}

variable "azdvops2" {
  type        = string
  default     = "vsrvazwe-mdt-01"
  description = "Azure Dev OPS VM for MDT - Windows Server 2019"
}

variable "Windows-Server-Offer" {
  type        = string
  default     = "WindowsServer"
  description = "Offer Windows Server 2016"
}

variable "Windows-Server-Publisher" {
  type        = string
  default     = "MicrosoftWindowsServer"
  description = "Publisher Windows Server"
}

variable "W2K16" {
  type        = string
  default     = "2016-Datacenter"
  description = "Windows Server 2016 Datacenter"
}

variable "W2K19" {
  type        = string
  default     = "2019-Datacenter"
  description = "Windows Server 2019 Datacenter"
}

#Variables for terraform.tfvars file
variable "regions" {
  type        = list(string)
  default     = ["West Europe"]
  description = "Regions to deploy your resources, can be one or more. Defaults to West Europe and North Europe."
}

variable "admin_username" {
  type        = string
  default     = "admin"
}

variable "admin_password" {
  type        = string
  default     = "Passw0rd"
}

variable "administrator_login" {
  type        = string
  default     = "admin"
}

variable "administrator_login_password" {
  type        = string
  default     = "Passw0rd"
}

#Variables for Tags

variable "tag_department" {
  type        = string
  default     = "N4K-IT-Infrastructure"
  description = "TAG for Department ID"
}

variable "tag_division" {
  type        = string
  default     = "N4K-IT"
  description = "TAG for Division ID"
}

variable "tag_environment" {
  type        = string
  default     = "DEV"
  description = "TAG for the Environment"
}

variable "tag_scope" {
  type        = string
  default     = "Terraform Automatisation"
  description = "TAG for the Scope"
}

