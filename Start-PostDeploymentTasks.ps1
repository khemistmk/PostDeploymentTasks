if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

. .\Invoke-PostDeploymentTasks.ps1
Invoke-PostDeploymentTasks -InstallOfficeVers O365 InstallPDFVers Adobe2020STD