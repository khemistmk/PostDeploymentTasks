$params = @{
    InstallOfficeVers = Read-Host "Select Office Version (O365 or OHBE21)"
    InstallPDFVers = Read-Host "Select PDF Version (AdobeReader, Adobe2020, or FoxitBusiness)"
}

Set-ExecutionPolicy Bypass
New-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp" -type Directory | Out-Null
$Moduledir = "$env:Userprofile\Documents\WindowsPowershell\Modules"
if(!(TestPath $Moduledir)) {
    New-Item -Path "$env:Userprofile\Documents\WindowsPowershell\Modules" -type Directory -Force | Out-Null
}
Invoke-WebRequest -Uri "https://github.com/khemistmk/PostDeploymentTasks/archive/refs/heads/main.zip" -OutFile "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip"
Expand-Archive -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip" -DestinationPath "$env:Userprofile\Documents\WindowsPowershell\temp\"
Move-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks*" -Destination "$env:Userprofile\Documents\WindowsPowershell\Modules\PostDeploymentTasks"
Remove-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp\" -Recurse
Import-Module PostDeploymentTasks
Invoke-PostDeploymentTasks $params