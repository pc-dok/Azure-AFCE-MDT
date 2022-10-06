#Install Default Applications on AVD Image
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
choco install notepadplusplus foxitreader 7zip vscode choco install libreoffice-fresh -y
