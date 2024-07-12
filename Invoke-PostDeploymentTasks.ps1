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
        [Validateset("Office 365","Office 2021")]
        $InstallOfficeVers,
        
        [Parameter()] [Validateset("AdobeReader","Adobe2020STD","Adobe2020Pro","FoxitBusiness")]
        $InstallPDFVers
    )

    begin {
         Import-Module $PSScriptRoot\PostDeploymentTasks.psm1
    }

    process {
        function Defaultdeploy {
            Install-OEMKey
            Set-ComputerName
            Disable-Administrator
            Set-PowerOptions
            Remove-DeploymentFiles
            Set-DotNet
            Uninstall-Package
            Install-StandardApps
            Install-SystemUpdate
            Install-WindowsUpdates
            Set-BitlockerDrive
            Set-DefaultApps
        }
            Defaultdeploy
        }
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