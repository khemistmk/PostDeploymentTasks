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
        $MSOfficeActivationEmail = Read-Host "Enter Microsoft Office Activation Email"
        $Admin = (Get-LocalUser -Name "Administrator").Enabled
        $MSOfficevers = (Get-Package | Where-Object {($_.Name -like "*Microsoft Office*") -or ($_.Name -like "*Microsoft 365*")}).Name
        $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).manufacturer
        $model = (Get-CimInstance -ClassName Win32_ComputerSystem).model
        $CPUInfo = (Get-CimInstance Win32_Processor).name
        $RAM = Get-CimInstance win32_ComputerSystem | foreach {[math]::round($_.TotalPhysicalMemory /1GB)}
        $Drivesize = Get-CimInstance -ClassName win32_logicaldisk | Where-Object {$_.Drivetype -eq "3"} | foreach {[math]::round($_.size /1GB)}
    }
    process {
        if (($drivesize -gt "459")-and ($Drivesize -lt "468")) { $Drive = "500 GB"}
        if (($drivesize -gt "469") -and ($Drivesize -lt "479")) { $Drive = "512 GB"}
        if (($drivesize -gt "929") -and ($Drivesize -lt "935")) { $Drive = "1 TB"}
        if (($drivesize -gt "1800") -and ($Drivesize -lt "1900")) { $Drive = "2 TB"}
            
            '1810' { $Drive = "2 TB"}
        }
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