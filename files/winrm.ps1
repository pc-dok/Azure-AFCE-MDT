$Cert = New-SelfSignedCertificate -DnsName $RemoteHostName, $ComputerName `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -FriendlyName "Test WinRM Cert"

$Cert | Out-String

$Thumbprint = $Cert.Thumbprint

Write-Host "Enable HTTPS in WinRM"
$WinRmHttps = "@{Hostname=`"$RemoteHostName`"; CertificateThumbprint=`"$Thumbprint`"}"
winrm create winrm/config/Listener?Address=*+Transport=HTTPS $WinRmHttps

Write-Host "Set Basic Auth in WinRM"
$WinRmBasic = "@{Basic=`"true`"}"
winrm set winrm/config/service/Auth $WinRmBasic

Write-Host "Open Firewall Port"
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5985

#Install Default Applications on MDT Server
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
choco install sql-server-management-studio notepadplusplus foxitreader microsoft-edge 7zip -y

######################################################################## 
# Install AFCE - Cloud Edition - customized by @Trond Erik Haavarstein #
########################################################################
Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)

#Create Folder for Cloud AFCE

$Source     = "C:\_AFCE_Source"
$Target     = "C:\_AFCE_Hydration"
$Logs       = "C:\_AFCE_Logs"
$LogsShare  = "AFCE_Logs$"
$Share      = "AFCE_Hydration$"

If (!(Test-Path -Path $Source)) {New-Item -ItemType directory -Path $Source | Out-Null}
CD $Source

# Speed up the download - disable progress bar
$ProgressPreference = 'SilentlyContinue'

Write-Verbose "Disable IE Security" -Verbose
reg add "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v IsInstalled /t REG_DWORD /d 0 /f

Write-Verbose "Disable IE First Time Run Wizard" -Verbose
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v DisableFirstRunCustomize /t REG_DWORD /d 1 /f

Write-Verbose "Disable Server Manager and Admin Center Popup" -Verbose
reg add HKLM\SOFTWARE\Microsoft\ServerManager /v DoNotOpenServerManagerAtLogon /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\ServerManager /v DoNotOpenServerManagerAtLogon /t REG_DWORD /d 1 /f
reg add HKLM\SOFTWARE\Microsoft\ServerManager\Oobe /v DoNotOpenInitialConfigurationTasksAtLogon /t REG_DWORD /d 1 /f
reg add HKLM\SOFTWARE\Microsoft\ServerManager /v DoNotPopWACConsoleAtSMLaunch /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\ServerManager /v DoNotPopWACConsoleAtSMLaunch /t REG_DWORD /d 1 /f

Write-Verbose "Disable Windows Firewall" -Verbose
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Windows ADK for Windows 10, version 1809
$Vendor = "Microsoft"
$Product = "ADK for Windows 10"
$Version = "10.1.17763.1"
$uri = "https://go.microsoft.com/fwlink/?linkid=2026036"
$PackageName = "adksetup.exe"
$UnattendedArgs1 = '/quiet /layout .\'
$UnattendedArgs2 = '/Features OptionId.DeploymentTools /norestart /quiet /ceip off'

Write-Verbose "Downloading $Vendor $Product $Version" -Verbose
 If (!(Test-Path -Path $PackageName)) {
            Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
            (Start-Process "$PackageName" $UnattendedArgs1 -Wait -Passthru).ExitCode
            }
        Else {
            Write-Verbose "File exists. Skipping Download." -Verbose
        }

Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process "$PackageName" $UnattendedArgs2 -Wait -Passthru).ExitCode

# Windows PE Add-on for ADK 1809

$Vendor = "Microsoft"
$Product = "Windows PE add-on for ADK"
$Version = "10.1.17763.1"
$uri = "https://go.microsoft.com/fwlink/?linkid=2022233"
$PackageName = "adkwinpesetup.exe"
$UnattendedArgs = '/Features OptionId.WindowsPreinstallationEnvironment /norestart /quiet /ceip off'

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process "$PackageName" $UnattendedArgs -Wait -Passthru).ExitCode

# Microsoft Deployment Toolkit
$Vendor = "Microsoft"
$Product = "Deployment Toolkit"
$Version = "6.3.8443.1000"
$uri = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

# System Center 2012 R2 Configuration Manager Toolkit
$Vendor = "Microsoft"
$Product = "System Center 2012 R2 Configuration Manager Toolkit"
$Version = "4.00.6221.1035"
$uri = "https://download.microsoft.com/download/5/0/8/508918E1-3627-4383-B7D8-AA07B3490D21/ConfigMgrTools.msi"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Set $Vendor $Product $Version as default Log Viewer" -Verbose
$registryPath = "HKCU:\Software\Classes\Log.File\shell\open\command"
$name = "(Default)"
$value = "`"C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe`" `"%1`""

cmd /c "Reg add HKCU\Software\Classes\.lo /ve /d Log.File /f"
cmd /c "Reg add HKCU\Software\Classes\.log /ve /d Log.File /f"
cmd /c "Reg add HKCU\Software\Classes\Log.File\shell\open\command /f"
cmd /c "Reg add HKCU\Software\Microsoft\Trace32 /v "Register File Types" /t REG_SZ /d 1 /f"

New-ItemProperty -Path $registryPath `
    -Name $name `
    -Value $value `
    -PropertyType String `
    -Force | Out-Null

# Microsoft System CLR Types for SQL Server 2012
$Vendor = "Microsoft"
$Product = "System CLR Types for SQL Server 2012 (x64)"
$Version = "11.0.2100.60"
$uri = "http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409"
$PackageName = "SQLSysClrTypes.msi"
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

# Microsoft Report Viewer 2012 Runtime
$Vendor = "Microsoft"
$Product = "Report Viewer 2012 Runtime"
$Version = "11.1.3452.0"
$uri = "https://download.microsoft.com/download/F/B/7/FB728406-A1EE-4AB5-9C56-74EB8BDDF2FF/ReportViewer.msi"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
$LogApp = "${env:SystemRoot}" + "\Temp\$PackageName.log"
$UnattendedArgs = "/i $PackageName ALLUSERS=1 /qn /liewa $LogApp"

Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

# NotePad ++
#$Vendor = "Misc"
#$Product = "Notepad++"
#$Version = "7.8.1"
#$uri = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.1/npp.7.8.1.Installer.x64.exe"
#$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
#$UnattendedArgs = '/S'

#Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
#Write-Verbose "Starting Installation of $Product $Version" -Verbose
#(Start-Process "$PackageName" $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Configuring Microsoft Deployment Toolkit" -Verbose

Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

 If (!(Test-Path -Path $Logs)) {
    New-Item -Path $Logs -Type Directory
            }

New-Item -Path $Target -Type Directory
New-SmbShare -Name $Share -Path $Target -FullAccess "EVERYONE"
New-SmbShare -Name $LogsShare -Path $Logs -FullAccess "EVERYONE"

Write-Verbose "Importing Windows 2019 x64" -Verbose
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root $Target -NetworkPath "\\$ENV:COMPUTERNAME\$Share" -Description "Hydration" | Add-MDTPersistentDrive

Write-Verbose "Creating Task Sequences" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Cloud - Domain Controller" -Template "StateRestore.xml" -Comments "" -ID "CTX-015" -Version "1.0" -Verbose
import-mdttasksequence -path "DS001:\Task Sequences" -Name "Cloud - Automation Framework" -Template "StateRestore.xml" -Comments "" -ID "CTX-016" -Version "1.0" -Verbose

new-item -path "DS001:\Applications" -enable "True" -Name "Adobe" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Bundles" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Citrix" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Google" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Microsoft" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Misc Vendors" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Mozilla" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Nutanix" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Parallels" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "Scripts" -Comments "" -ItemType "folder" -Verbose
new-item -path "DS001:\Applications" -enable "True" -Name "VMware" -Comments "" -ItemType "folder" -Verbose

Write-Verbose "Downloading Applications" -Verbose
$uri = "http://xenapptraining.s3.amazonaws.com/Hydration/Applications.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Expand-Archive -Path $PackageName -DestinationPath .
Remove-Item $Target\Applications
Move-Item -Path $Source\Applications\ -Destination $Target -Force

$uri = "http://xenapptraining.s3.amazonaws.com/Hydration/Control.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Expand-Archive -Path $PackageName -DestinationPath .
cmd /C "xcopy $Source\Control $Target\Control /E /Y /S /Q"

$uri = "http://xenapptraining.s3.amazonaws.com/Hydration/Scripts.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Expand-Archive -Path $PackageName -DestinationPath .
cmd /C "xcopy $Source\Scripts $Target\Scripts /E /Y /S /Q"

$uri = "http://xenapptraining.s3.amazonaws.com/Hydration/Drivers.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Expand-Archive -Path $PackageName -DestinationPath .\

$uri = "http://xenapptraining.s3.amazonaws.com/Hydration/Templates.zip"
$PackageName = $uri.Substring($uri.LastIndexOf("/") + 1)
Invoke-WebRequest -Uri $uri -OutFile "$Source\$PackageName"
Expand-Archive -Path $PackageName -DestinationPath .\
copy-item $Source\Templates\* "C:\Program Files\Microsoft Deployment Toolkit\Templates" -Force
copy-item $Source\Samples\* "C:\Program Files\Microsoft Deployment Toolkit\Samples" -Force

Write-Verbose "Customizing CS and Bootstrap" -Verbose
$ipV4 = Test-Connection -ComputerName (hostname) -Count 1  | Select-Object -ExpandProperty IPV4Address
$ip = $ipV4.IPAddressToString
$File = "$Target\Control\CustomSettings.ini"
Add-Content $File "WindowsUpdate=False"
Add-Content $File ""
Add-Content $File "_SMSTSOrgName=N4K GPC Cloud"
Add-Content $File "_SMSTSPackageName=Automation Framework CE"
Add-Content $File "SkipRoles=YES"
Add-Content $File "SkipSummary=YES"
Add-Content $File "SkipBitLocker=YES"
Add-Content $File "SkipFinalSummary=YES"
Add-Content $File "AdminPassword=P@ssw0rd"
Add-Content $File "SkipApplications=YES"
Add-Content $File "FinishAction=REBOOT"
Add-Content $File "EventService=http://$ip:9800"
Add-Content $File "SLSHARE=\\$ip\logs$"

$default = Get-Content $File
$default.Replace('SkipAdminPassword=NO','SkipAdminPassword=YES') | Out-File $File -Encoding ascii

$default = Get-Content $File
$default.Replace('MyCustomProperty','WindowsUpdate') | Out-File $File -Encoding ascii

$File = "$Target\Control\Bootstrap.ini"
Get-Content $File | ForEach-Object {$_ -replace "*", ""} | Out-File $File
Add-Content $File "[Settings]"
Add-Content $File "Priority=Default"
Add-Content $File ""
Add-Content $File "[Default]"
Add-Content $File "DeployRoot=\\$IP\$Share"
Add-Content $File ""
Add-Content $File "UserID=Administrator"
Add-Content $File "UserPassword=P@ssw0rd"
Add-Content $File "UserDomain=WORKGROUP"

Write-Verbose "Enable Monitoring" -Verbose
New-NetFirewallRule -Name "MDT_Monitor (Inbound,TCP)" -DisplayName "MDT_Monitor (Inbound,TCP)" -Description "Inbound rules for the TCP protocol for MDT_Monitor" -LocalPort 9800 -Protocol "TCP" -Direction "Inbound" -Action "Allow"
Set-ItemProperty DS001: -Name MonitorHost -Value $IP
Set-ItemProperty DS001: -Name MonitorEventPort -Value 9800
Set-ItemProperty DS001: -Name MonitorDataPort -Value 9801
New-Service -Name "MDT_Monitor" -Description "Microsoft Deployment Toolkit Monitor Service" -BinaryPathName "C:\Program Files\Microsoft Deployment Toolkit\Monitor\Microsoft.BDD.MonitorService.exe" -DisplayName "Microsoft Deployment Toolkit Monitor Service" -StartupType Automatic
Start-Service -Name "MDT_Monitor"

#Add Windows Features for Administrate than AADDS with this Client / only than for Azure VMs not for GCP or AWS
#Add-WindowsFeature "RSAT-AD-Tools"
#Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools
#Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools

Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
restart-computer -Force

#Enable this Section when you install over MDT Server with TS
# Run LiteTouch.vbs, replace the task sequence ID with yours
#Start-Process -FilePath 'cscript.exe' -ArgumentList "\\172.21.1.11\mdtproduction$\Scripts\LiteTouch.vbs", "/TaskSequenceID:W10-X64-015", "/SkipTaskSequence:YES" -Verb RunAs
