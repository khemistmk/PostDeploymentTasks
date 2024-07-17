Set-ExecutionPolicy Bypass
New-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp" -type Directory
Invoke-WebRequest -Uri "https://github.com/khemistmk/PostDeploymentTasks/archive/refs/heads/main.zip" -OutFile "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip"
Expand-Archive -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip" -DestinationPath "$env:Userprofile\Documents\WindowsPowershell\temp\"
Move-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks*" -Destination "$env:Userprofile\Documents\WindowsPowershell\Modules\PostDeploymentTasks"
Remove-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp\" -Recurse
Import-Module PostDeploymentTasks
Invoke-PostDeploymentTasks -InstallOfficeVers O365 -InstallPDFVers Adobe2020