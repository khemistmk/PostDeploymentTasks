function Set-PowerOptions {
<#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param {
        [Parameter()]
        [int]$montimeoutac,
        
        [Parameter()]
        [int]$montimeoutdc,

        [Parameter()]
        [int]$sbtimeoutac,

        [Parameter()]
        [int]$sbtimeoutdc
    }

    begin {

    }

    process {
        Powercfg /Change monitor-timeout-ac $montimeoutac
        Powercfg /Change monitor-timeout-dc $montimeoutdc
        Powercfg /Change standby-timeout-ac $sbtimeoutac
        Powercfg /Change standby-timeout-dc $sbtimeoutdc
    }

    end {

    }

}