Set-ExecutionPolicy Bypass
Invoke-WebRequest -Uri https://github.com/khemistmk/PostDeploymentTasks/archive/refs/heads/main.zip -OutFile "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip"
Expand-Archive -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip" -DestinationPath "$env:Userprofile\Documents\WindowsPowershell\temp\"
Remove-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks.zip"
Move-Item -Path "$env:Userprofile\Documents\WindowsPowershell\temp\PostDeploymentTasks*" -Destination "$env:Userprofile\Documents\WindowsPowershell\PostDeploymentTask"
Import-Module PostDeploymentTasks
Invoke-PostDeploymentTasks -InstallOfficeVers O365 -InstallPDFVers Adobe2020