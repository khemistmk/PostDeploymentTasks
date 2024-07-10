function Disable-Administrator {
    <#
    .SYNOPSIS 
        This script will disable the default Administrator account.
    .DESCRIPTION
        This script will check if the default Administrator account is enabled and if so, disable it.

#>
    [CmdletBinding()]
    param (
        
    )

    begin {   
        $adminaccount = Get-LocalUser -Name "Administrator"
    }
    
    process {
        Write-Host "[*] Checking default Administrator Account..." -ForegroundColor Yellow
        if ($adminaccount.Enabled -eq "False") {
            Write-Host "[*] Administrator account disabled." -ForegroundColor Yellow
        }
        else {
            Write-Host "[*] Disabling default Administrator Account..."-ForegroundColor Yellow
            Disable-LocalUser -Name "Administrator"
            Write-Host "[*] Administrator account disabled." -ForegroundColor Green
        }
    }
    end {

    }
}