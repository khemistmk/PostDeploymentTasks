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
            Write-Verbose "Checking for Windows Updates..."
            usoclient ScanInstallWait
            usoclient StartInstall
            Write-Verbose "[*] Windows Updates Completed"
        }
        catch {
            Write-Error -message "[*] Unable to run Windows Updates"
        }
    }
    end {

    }
}