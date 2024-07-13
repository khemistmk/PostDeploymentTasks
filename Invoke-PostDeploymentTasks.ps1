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
        [Validateset("Office365","Office2021")]
        $InstallOfficeVers,
        
        [Parameter()] [Validateset("AdobeReader","Adobe2020STD","Adobe2020Pro","FoxitBusiness")]
        $InstallPDFVers
    )

    begin {
        Write-Host "[*] Installing Prerequisites..." -ForegroundColor Yellow
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Install-Module nuget
        Install-Module winget
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
            Set-BitlockerDrive
        }
        Invoke-Defaultdeploy
        if ($InstallOfficevers.IsPresent) {
        Install-MSOffice -Officevers $InstallOfficevers
        }
        if ($InstallPDFvers.Ispresent) {
        Install-PDF -PDFVers $InstallPDFVers
        }
    }

    end {

    }

}