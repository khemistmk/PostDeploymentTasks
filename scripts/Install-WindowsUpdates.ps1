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
        
    }
    
    process {
        try {
            Write-Host "[*] Checking for Windows Updates..." -ForegroundColor Yellow
            usoclient ScanInstallWait
            usoclient StartInstall
            Write-Host "[*] Windows Updates Completed" -ForegroundColor Green
        }
        catch {
            Write-Error -message "[*] Unable to run Windows Updates"
        }
    }
    end {

    }
}