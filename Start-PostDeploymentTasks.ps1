Set-ExecutionPolicy -Scope Process Bypass
. .\Invoke-PostDeploymentTasks.ps1
Invoke-PostDeploymentTasks -InstallOfficeVers O365 -InstallPDFVers AdobeReader