function Install-WindowsUpdates {
<#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param ()
    
    begin {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
        Install-Module -Name PSWindowsUpdate -Force
        Import-Module PSWindowsUpdate
    }
    
    process {
    Write-Host "[*] Checking for Windows Updates..." -ForegroundColor Yellow
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnorReboot
    Write-Host "[*] Windows Updates Completed" -ForegroundColor Green
    }
    end {
        Remove-Module PSWindowsUpdate
    }
}