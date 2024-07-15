function Get-SystemStatus {
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
        if ($adminaccount.Enabled -eq "False") { $Admin = "Administrator Disabled"}


        $Report = @"

Customer Name: $CustomerName ($Username)
SN: $SerialNumber

Activation Information:
$MSOfficeVoucher
$MSOfficeActivationEmail

Computer Information:
Manufacturer:         $manufacturer
Model:                $model
CPU:                  $CPUInfo
RAM:                  $RAM
Drive:                $Drive $Drivemanufacturer

Dotnet 3.5:           $dotnet
Power Options set:    $power

Installed Software:
$Software
"@

    }
    end {

    }
}