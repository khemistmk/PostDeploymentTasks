Function Uninstall-Package {
        <#
        .SYNOPSIS 
            This script will uninstall the named package.
        .DESCRIPTION
            This script will uninstall the named package.
        .PARAMETER PackageName
            The name of the package to be uninstalled.
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
