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
        
        [Parameter()]
        [Validateset("AdobeReader","Adobe2020STD","Adobe2020Pro","FoxitBusiness")]
        $InstallPDFVers
    )

    begin {

    }

    process {
        function Defaultdeploy {
            Install-OEMKey
            Set-ComputerName
            Disable-Administrator
            Set-PowerOptions
            Remove-DeploymentFiles
            Uninstall-SmartDeploy
            Start-Ninite
            Install-SystemUpdate
            Install-WindowsUpdates
            Get-BitLockerVolume
        }
        if (-Not $InstallOfficevers.IsPresent -and -not $InstallPDFvers.Ispresent) {
            Defaultdeploy
        }
        
    }

    end {

    }

}