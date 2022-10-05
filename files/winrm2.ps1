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
choco install notepadplusplus foxitreader 7zip -y

#Add Windows Features for Administrate than AADDS with this Client
Add-WindowsFeature "RSAT-AD-Tools"
Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools
Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools

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
