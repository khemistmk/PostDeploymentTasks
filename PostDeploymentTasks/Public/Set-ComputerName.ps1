Function Set-ComputerName {
        <#
    .SYNOPSIS 
        This script will disable the default Administrator account.
    .DESCRIPTION
        This script will check if the default Administrator account is enabled and if so, disable it.

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ComputerSetName = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
    )

    begin {   
        $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
        $computername = (Get-WmiObject -Class Win32_Operatingsystem).PSComputerName
    }

    process {
        if ( $computername -eq $ComputerSetName ){
            Write-Verbose "Computer name: $ComputerSetName"
        }
        else {
            Write-Verbose "Setting Computer name."
            Rename-Computer -newname "$ComputerSetName"
            Write-Verbose "Computer renamed to: $ComputerSetName"
        }
        $compinfo = [PSCustomObject]@{
            ComputerName = $computername
            SerialNumber = $serialnumber
        }
    }
    end {
        Write-Output -InputObject $compinfo
    }
}