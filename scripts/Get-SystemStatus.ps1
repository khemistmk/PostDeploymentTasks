function Get-SystemStatus {
    <#
    .SYNOPSIS 
        This script will disable the default Administrator account.
    .DESCRIPTION
        This script will check if the default Administrator account is enabled and if so, disable it.

#>
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true)]
        $customername,
      
        [Parameter(mandatory = $true)]
        $Username,

        [Parameter(mandatory = $true)]
        $MSOfficeActivationEmail,

        [Parameter()]
        [string]$SaveLocation = "$env:Userprofile\Documents"
        [Parameter()]
        $MSOfficeVoucher,
        
        [Parameter()]
        $PDFkey
        
    )

    begin {   
        $date = Get-Date
        $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
        $computername = (Get-WmiObject -Class Win32_Operatingsystem).PSComputerName
        $winver = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
        $PDFVersion = (Get-Package | Where-Object {($_.Name -like "*Adobe Acrobat*") -or ($_.Name -like "*Foxit*")}).Name
        $Admin = (Get-LocalUser -Name "Administrator").Enabled
        $MSOfficevers = (Get-Package | Where-Object {($_.Name -like "*Microsoft Office*") -or ($_.Name -like "*Microsoft 365*") -and ($_.Name -notlike "*Teams*")}).Name
        $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).manufacturer
        $model = (Get-CimInstance -ClassName Win32_ComputerSystem).model
        $CPUInfo = (Get-CimInstance Win32_Processor).name
        $RAM = Get-CimInstance win32_ComputerSystem | ForEach-Object {[math]::round($_.TotalPhysicalMemory /1GB)}
        $drivesize = Get-PhysicalDisk | ForEach-Object {[math]::round($_.size /1GB)}
        $Drivemanufacturer = Get-PhysicalDisk | Select-Object -ExpandProperty FriendlyName
        $drivebrand,$driveserial = $Drivemanufacturer -split " "
        $Drivetype = Get-PhysicalDisk | Select-Object -ExpandProperty MediaType
        $Bustype = Get-PhysicalDisk | Select-Object -ExpandProperty Bustype
        $graphics = (Get-CimInstance -ClassName Win32_VideoController).Description
        $OEM =  Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\OEMInformation" | Select-Object -Property Manufacturer,SupportHours,SupportPhone,SupportURL
        $oemman = $OEM.Manufacturer
        $oemhours = $OEM.SupportHours
        $oemphone = $OEM.SupportPhone
        $oemurl = $OEM.SupportURL

    }
    process {
        if ($licensestatus.LicenseStatus -eq 1){
            $winactivation = "Activated"
        }
        if (($drivesize -gt "459")-and ($drivesize -lt "468")) { $Drive = "500 GB"}
        if (($drivesize -gt "469") -and ($drivesize -lt "479")) { $Drive = "512 GB"}
        if (($drivesize -gt "929") -and ($drivesize -lt "1024")) { $Drive = "1 TB"}
        if (($drivesize -gt "1800") -and ($drivesize -lt "2048")) { $Drive = "2 TB"}
       
        $Programs = @()
        $Programlist = "Adobe Acrobat","Reader","Foxit","Microsoft Office","Microsoft 365","Project","AutoDesk","Navisworks","VLC","Chrome","Firefox","Sophos"
        foreach ($p in $Programlist) {
            $Programs += (Get-Package | Where-Object {$_.Name -like "*$p*"}).Name
        }
        $plist = $Programs | Out-String

                if (((Get-BitLockerVolume -MountPoint "C:").VolumeStatus) -eq 'FullyEncrypted') {
            $bit = "Enabled"
        }
         else {
            $bit = "Disabled"
        }

        if (!(Test-Path "C:\Platform")) { $platform = "Removed" }
        if (!(Test-Path "C:\OEM")) { $oemfolder = "Removed" }
        if ((Get-Package | Where-Object {$_.Name -like "*SmartDeploy*"}) -eq $null) { $SmartDeploy = "Removed" }

        $Report = @"

Deployment Date:            $date
Customer Name:              $CustomerName ($Username)
Serial Number:              $SerialNumber
Computer Name:              $computername

**************************************************************
Activation Information
Windows Version:            $winver
Windows Activation:         $winactivation
$PDFVersion                 $PDFkey
$MSOfficevers               $MSOfficeVoucher
$MSOfficeActivationEmail
**************************************************************

Hardware Information
______________________________________________________________
Manufacturer:               $manufacturer
Model:                      $model
CPU:                        $CPUInfo
RAM:                        $RAM GB
Drive:                      $Drive $drivebrand $Bustype $Drivetype                           
Graphics:                   $graphics

Deployment Tasks
______________________________________________________________
OEM Info:                   Manufacturer: $oemman
                            Support Hours: $oemhours
                            Support Phone: $oemphone
                            Support URL: $oemurl 

Bitlocker:                  $bit
Platform folder:            $platform
OEM folder:                 $OEMfolder

Administrator:              $Admin
Dotnet 3.5:                 $dotnet
Power Options set:          $power
Fast Startup:               $faststart
SmartDeploy:                $SmartDeploy


______________________________________________________________
Installed Software
_____________________________________________________________
$plist
"@

Clear-Host
$Report > $SaveLocation\$Computername.txt
Write-Host "$Report"

    }
    end {

    }
}