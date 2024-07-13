Function Set-ComputerName {
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
        $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
        $computername = (Get-WmiObject -Class Win32_Operatingsystem).PSComputerName
    }

    process {
        Write-Host "[*] Setting Computer name..." -ForegroundColor Yellow
        if ( $computername -eq $serialnumber ){
        return
        }
        else {
        Rename-Computer -newname "$serialnumber"
        }
        Write-Host "[*] Computer name set to $computername" -ForegroundColor Green
    }
    end {

    }
}