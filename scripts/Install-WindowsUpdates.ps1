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
        Import-Module PSWindowsUpdate
    }
    
    process {
        try {
            Write-Host "[*] Checking for Windows Updates..." -ForegroundColor Yellow
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
            Write-Host "[*] Windows Updates Completed" -ForegroundColor Green
        }
        catch {
            Write-Error -message "[*] Unable to run Windows Updates"
        }
    }
    end {
        Uninstall-Module PSWindowsUpdate
    }
}