Function Uninstall-Package {
        <#
        .SYNOPSIS 
            This script will set the default apps for new users on a machine.
        .DESCRIPTION
            This script sets Adobe, Foxit, or Chrome as the default .pdf viewer, Chrome as default browser, and Outlook as the default mail-to application.
    #>
        [CmdletBinding()]
        param (
            [Parameter(mandatory = $true)]
            $PackageName
        )

        begin {

        }

        process {
            $installed = Get-WmiObjecdt -Class Win32_Product |
            Where-Object {$_.Name -like '*$PackageName*'}
            $installed.Uninstall()
            Write-Host "[*] $PackageName Uninstalled" -ForegroundColor Green
        }
        end {
        
        }
}
