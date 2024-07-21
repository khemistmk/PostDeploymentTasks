function Invoke-PostDeploymentTasks {
<#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$InstallOfficeVers,
        
        [Parameter()] 
        [string]$InstallPDFVers,
    
        [Parameter()]
        [string]$SaveLocation
    )

    begin {
        Write-Host "[*] Installing Prerequisites..." -ForegroundColor Yellow
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        $nuget = Get-PackageProvider | Where-Object {$_.Name -eq "NuGet"}
        if ($nuget){
            return
        }
        else {
            Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 -Force
        }
        $winget = winget --version
        if ($winget -like "*v1.8.*"){
            return
        }
        else {
            Install-Module -Name Microsoft.WinGet.Client
        }
        Import-Module $PSScriptRoot\PostDeploymentTasks.psm1

    }

    process {
        function Invoke-Defaultdeploy {
            Install-OEMKey
            Set-ComputerName
            Disable-Administrator
            Set-PowerOptions
            Remove-DeploymentFiles
            Set-DotNet -setdotnet3 Enabled -setdotnet4 Enabled
            Uninstall-Package -PackageName "SmartDeploy"
            Install-StandardApps
            Install-SystemUpdate
            Install-WindowsUpdates
            Set-BitlockerDrive -SaveLocation $SaveLocation
        }
        Invoke-Defaultdeploy
        if ($InstallOfficevers) {
        Install-MSOffice -officevers $InstallOfficevers
        }
        if ($InstallPDFvers) {
        Install-PDF -InstallPDFVers $InstallPDFVers
        }
        Remove-Bloat
        Set-DefaultApps
        
    }

    end {
         if ($Host.Name -eq "ConsoleHost") {
            Clear-Host
            Get-SystemStatus -SaveLocation $SaveLocation
            Write-Host "Press any key to continue..."
            $Host.UI.RawUI.FlushInputBuffer()
            $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
         }
       $WshShell = New-Object -comObject WScript. Shell
     $WshShell.RegWrite('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\InstallAtShutdown', '1', 'REG_DWORD')

       Restart-Computer
    }

}
