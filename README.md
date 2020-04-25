## Azure - AFCE MDT

 Setup you private Azure creds before running the script :

```
subscription_id = "---"
client_id = "---"
client_secret = "---"
tenant_id = "---"
```

##### Steps to initialize this project
- Enter/edit all the variables in variable file (terraform.tfvars and variables.tf, vpn.tf and main.tf)
- Add storage account , container name , Access Key at the end of file for storing terraform state file remotely to azure (you need to have a already created storage account for storing the state file )

Run following commands to run & test Terraform scripts :

- terraform init          (To initialize the project)
- terraform plan        (To check the changes to be made by Terraform on azure )
- terraform apply       (To apply the changes to azure)

##### Installation of AFCE MDT Server
- Creator: fkoenig@n4k
- Date: 20200425
- Shareable: yes / notice Passwords in .tfvars file only for Demo Purposes
- Example for Create a DEMO LAB with Azure and Deploy than a Citrix LAB with MDT

##### Ressource Group - Create first all needed Azure Ressources what needed for our LAB

```
Create a RG
Create a vnet
Create a default Network Security Group NSG
Create a Storage Account for Boot Diagnostic
Create a Storage Account for ISO File Share and Home User Share
Create a VPN Gateway so that i can connect over my pfsense directly to Servers

```

##### MDT - Create first the MDT Server - W2K19
- Install a VM with Windows Server 2019 / with Managed Disk - Premium LRS and MDT

```
-Applications:
--sql-server-management-studio
--notepadplusplus
--foxitreader
--ms-edge
--7zip
--AFCE - Automation Framework Community Edition - MDT Server

```
