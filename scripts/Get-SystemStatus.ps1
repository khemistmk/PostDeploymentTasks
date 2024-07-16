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
        $CustomerName = Read-Host -Prompt "Enter customer name:"
        $Username = Read-Host -Prompt "Enter username:"
        $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
        $computername = (Get-WmiObject -Class Win32_Operatingsystem).PSComputerName
        $PDFVersion = (Get-Package | Where-Object {($_.Name -like "*Adobe*") -or ($_.Name -like "*Foxit*")}).Name
        $MSOfficeVoucher = Read-Host "Enter Microsoft Office Voucher:"
        $MSOfficeActivationEmail = $serialnumber + "@tuscom.us"
        $adminaccount = Get-LocalUser -Name "Administrator"
        $MSOfficevers = (Get-Package | Where-Object {($_.Name -like "*Microsoft Office*") -or ($_.Name -like "*Microsoft 365*")}).Name
        $CPUInfo = (Get-CimInstance Win32_Processor).name
        $RAM = Get-CimInstance win32_ComputerSystem | foreach {[math]::round($_.TotalPhysicalMemory /1GB)}
    }

    process {
        if ($adminaccount.Enabled -eq "False") { $Admin = "Administrator Disabled"}


        $Programs = @()
        $Programlist = "Adobe Acrobat","Reader","Foxit","Microsoft Office","Microsoft 365","Project","AutoDesk","Navisworks","VLC","Chrome","Firefox","Sophos"
        foreach ($p in $Programlist) {
            $Programs += (Get-Package | Where-Object {$_.Name -like "*$p*"}).Name
        }
        $plist = $Programs | Out-String
        $Report = @"

Customer Name:              $CustomerName ($Username)
SN:                         $SerialNumber
Computer Name:              $computername

**************************************************************
Activation Information
$PDFVersion                 $PDFkey
$MSOfficevers               $MSOfficeVoucher
$MSOfficeActivationEmail
**************************************************************

Computer Information
______________________________________________________________
Manufacturer:               $manufacturer
Model:                      $model
CPU:                        $CPUInfo
RAM:                        $RAM GB
Drive:                      $Drive GB $Drivemanufacturer

Administrator:              $Admin
Dotnet 3.5:                 $dotnet
Power Options set:          $power

Installed Software
_____________________________________________________________
$plist
"@

Clear-Host
$Report > $env:USERPROFILE\Documents\$Computername.txt
Write-Host "$Report"

    }
    end {

    }
}