function Disable-Administrator {
    <#
    .SYNOPSIS 
        This script will disable the default Administrator account.
    .DESCRIPTION
        This script will check if the default Administrator account is enabled and if so, disable it.

#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [string]$AccountName = "Administrator"
    )

    begin {   
        $adminaccount = Get-LocalUser -Name $AccountName
    }
    
    process {
        Write-Verbose "Checking default Administrator Account..." 
        if ($adminaccount.Enabled -eq "False") {
            Write-Verbose "Administrator account disabled." 
        }
        else {
            Write-Verbose "Disabling default Administrator Account..."
            Disable-LocalUser -Name $AccountName
            Write-Verbose "Administrator account disabled."
        }
    }
    end {
        $adminaccount | Select-Object -Property Name,Enabled
    }
}