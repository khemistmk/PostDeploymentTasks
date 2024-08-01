# PostDeploymentTasks

This powershell module contains cmdlets to assist in rapid deployment of user machines.

## Table of Contents

- [PostDeploymentTasks](#PostDeploymentTasks)
- [Release Notes](#Release-Notes)
- [Usage and Examples](#Usage-and-Examples)
  - [Invoke-PostDeploymentTasks](#Invoke-PostDeploymentTasks)
  - [Disable-Administrator](##Disable-Administrator)
  - [Get-SystemStatus](#Get-SystemStatus)
  - [Install-MSOffice](#Install-MSOffice)
  - [Install-OEMKey](#Install-OEMKey)
  - [Install-PDF](#Install-PDF)
  - [Install-StandardApps](#Install-StandardApps)
  - [Install-SystemUpdate](#Install-SystemUpdate)
  - [Install-WinUpdate](#Install-WinUpdate)
  - [Remove-Bloat](#Remove-Bloat)
  - [Remove-DeploymentFiles](#Remove-DeploymentFiles)
  - [Set-BitlockerDrive](#Set-BitlockerDrive)
  - [Set-BitlockerDrive](#Set-BitlockerDrive)
  - [Set-DefaultApps](#Set-DefaultApps)
  - [Set-DotNet](#Set-DotNet)
  - [Set-PowerOptions](#Set-PowerOptions)
  - [Uninstall-Package](#Uninstall-Package)



# Release Notes
v0.0.1 Alpha
- This is a prerelease of the script. Use at your own risk. Errors are common.

# Usage and Examples
- Modules can be imported by running the Import batch file
```Command Prompt
.\Import-PostDeploymentTasks.bat
```
  Or in powershell directly
```Powershell
Import-Module .\PostDeploymentTasks.psm1
```

## Invoke-PostDeploymentTasks
- Invokes several submodules to automate the post-deployment process.

```Powershell
Invoke-PostDeploymentTasks -InstallOfficeVers OHBE21 -InstallPDFVers AdobeReader
```

## Disable-Administrator
```Powershell
Disable-Administrator
```

## Get-SystemStatus
```Powershell
Get-SystemStatus
```

## Install-MSOffice
```Powershell
Install-MSOffice -officevers O365
```

## Install-OEMKey
```Powershell
Install-OEMKey
```

## Install-PDF
```Powershell
Install-PDF -PDFVersion Adobe2020
```

## Install-StandardApps
```Powershell
Install-StandardApps -Tempfolder "C:\temp" -applist "Google.Chrome", "Mozilla.Firefox"
```

## Install-SystemUpdate
```Powershell
Install-OEMKey
```

## Install-WinUpdate
```Powershell
Install-WinUpdate
```

## Remove-Bloat
```Powershell
Remove-Bloat
```

## Remove-DeploymentFiles
```Powershell
Remove-DeploymentFiles
```

## Set-BitlockerDrive
```Powershell
Set-BitlockerDrive -SaveLocation "$env:Userprofile\Documents" -Filename $env:computername
```

## Set-DefaultApps
```Powershell
Set-DefaultApps
```

## Set-DotNet
```Powershell
Set-Dotnet -dotnet3 Enabled -dotnet4 Enabled 
```

## Set-PowerOptions
```Powershell
Set-PowerOptions -montimeoutac 60 -montimeoutdc 30 -sbtimeoutac 0 -sbtimeoutdc 0 -faststartup Disabled -powerbutton Shutdown -sleepbutton Shutdown -closelid Nothing
```

## Uninstall-Package
```Powershell
Uninstall-Package -PackageName McAfee
```