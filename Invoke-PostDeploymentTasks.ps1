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
        [ValidateSet("O365","O365-32","OHBE21","OHBE21-32","OHBE19","OHBE19-32","None")]
        [string]$InstallOfficeVers,
        
        [Parameter()] 
        [Validateset("AdobeReader","Adobe2020STD","Adobe2020Pro","FoxitBusiness","None")]
        [string]$InstallPDFVers
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
        Install-Module -Name PSWINDOWSUPDATE
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
            Set-BitlockerDrive C:
        }
        Invoke-Defaultdeploy
        if ($InstallOfficeVers -eq "None") {Return}
        if ($InstallOfficevers -Like "*O*") {
        Install-MSOffice -officevers $InstallOfficevers
        }
        if ($InstallPDFVers -eq "None") {Return}
        if ($InstallPDFvers -Like "*A*" -or $InstallPDFVers -like "*F*") {
        Install-PDF -InstallPDFVers $InstallPDFVers
        }
        Remove-Bloat
        Set-DefaultApps
        
    }

    end {
       
        if ($Host.Name -eq "ConsoleHost")
{
            Write-Host "Press any key to continue..."
             $Host.UI.RawUI.FlushInputBuffer()
                 $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
       Uninstall-Module -Name PSWINDOWSUPDATE
       Restart-Computer
    }

}