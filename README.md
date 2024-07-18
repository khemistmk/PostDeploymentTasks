# PostDeploymentTasks

This powershell module contains cmdlets to assist in rapid deployment of user machines.

## Table of Contents
- [PostDeploymentTasks](#PostDeploymentTasks)



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

## Install-OEMKey
```Powershell
Install-OEMKey
```
## Set-ComputerName
```Powershell
Set-ComputerName
```

## Disable-Administrator
```Powershell
Disable-Administrator
```

## Set-PowerOptions
```Powershell
Set-PowerOptions -montimeoutac 60 -montimeoutdc 30 -sbtimeoutac 0 -sbtimeoutdc 0 -faststartup Disabled -powerbutton Shutdown -sleepbutton Shutdown -closelid Nothing
```

## Remove-DeploymentFiles
```Powershell
Remove-DeploymentFiles
```

## Set-DotNet
```Powershell
Set-Dotnet -dotnet3 Enabled -dotnet4 Enabled 
```
          
## Uninstall-Package
```Powershell
Uninstall-Package -PackageName SmartDeploy
```

## Install-StandardApps
```Powershell
Install-StandardApps
```

## Install-SystemUpdate
```Powershell
Install-OEMKey
```

## Install-WinUpdate
```Powershell
Install-WinUpdate
```

## Set-BitlockerDrive
```Powershell
Set-BitlockerDrive
```
        
## Install-MSOffice
```Powershell
Install-MSOffice
```

## Install-PDF
```Powershell
Install-PDF
```

## Remove-Bloat
```Powershell
Remove-Bloat
```

## Set-DefaultApps
```Powershell
Set-DefaultApps
```
