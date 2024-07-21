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
        [string]$customername,
      
        [Parameter(mandatory = $true)]
        [string]$Username,

        [Parameter(mandatory = $true)]
        [string]$MSOfficeActivationEmail,

        [Parameter()]
        [string]$SaveLocation = "$env:Userprofile\Documents",

        [Parameter()]
        [string]$MSOfficeVoucher,
        
        [Parameter()]
        [string]$PDFkey
        
    )

    begin {   
        $date = Get-Date
        $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
        $computername = (Get-WmiObject -Class Win32_Operatingsystem).PSComputerName
        $winver = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
        $PDFVersion = (Get-Package | Where-Object {($_.Name -like "*Adobe Acrobat*") -or ($_.Name -like "*Foxit*")}).Name
        $Admin = (Get-LocalUser -Name "Administrator").Enabled
        $MSOfficevers = @((Get-Package | Where-Object {($_.Name -like "*Microsoft Office*") -or ($_.Name -like "*Microsoft 365*") -and ($_.Name -notlike "*Teams*")}).Name)
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
        $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
        $fsPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
        $fsName = "HiberbootEnabled"
        $fsvalue = (Get-ItemProperty -Path $fsPath -Name $fsName).HiberbootEnabled


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
        if ($Admin -eq "False") {
            $Adminstatus = "Disabled"
        }
        else {
            $Adminstatus = "Enabled"
        }
        if (((Get-BitLockerVolume -MountPoint "C:").VolumeStatus) -eq 'FullyEncrypted') {
            $bit = "Enabled"
        }
        else {
            $bit = "Disabled"
        }
        if (!(Test-Path "C:\Platform")) {
            $platform = "Removed"
        }
        else {
            $platform = "Not Removed"
        }
        if (!(Test-Path "C:\OEM")) { 
            $oemfolder = "Removed"
        }
        else {
            $oemfolder = "Not Removed"
        }
        if ($dotnet3 -eq 'True') {
            $dotnet = "Enabled"
        }
        else {
            $dotnet = "Disabled"
        }
        if ($fsvalue -eq "0") {
            $faststart = "Disabled"
        }
        else {
            $faststart = "Enabled"
        }
        if ($null -eq (Get-Package | Where-Object {$_.Name -like "*SmartDeploy*"})) {
            $SmartDeploy = "Removed"
        }
        else {
            $SmartDeploy = "Not Removed"
        }
        
        $montimeoutac,$montimeoutdc = powercfg @(
            '/query'
            'scheme_current'
            '7516b95f-f776-4464-8c53-06167f40cc99'
            '3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e'
        ) |
        Select-Object -Last 2 -Skip 1 |
        Foreach-Object {($_.Split(':')[1]) /60}
        
        $sleeptimeoutac,$sleeptimeoutdc = powercfg @(
            '/query'
            'scheme_current'
            '238c9fa8-0aad-41ed-83f4-97be242c8f20'
            '29f6c1db-86da-48c5-9fdb-f2b67b1f44da'
        ) |
        Select-Object -Last 2 -Skip 1 |
        Foreach-Object {($_.Split(':')[1]) /60}

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

Hardware Information
**************************************************************
Manufacturer:               $manufacturer
Model:                      $model
CPU:                        $CPUInfo
RAM:                        $RAM GB
Drive:                      $Drive $drivebrand $Bustype $Drivetype                           
Graphics:                   $graphics

Deployment Tasks
**************************************************************
OEM Info:   
            Manufacturer:   $oemman
            Support Hours:  $oemhours
            Support Phone:  $oemphone
            Support URL:    $oemurl 

Bitlocker:                  $bit
Platform folder:            $platform
OEM folder:                 $OEMfolder
Administrator:              $Adminstatus
Dotnet 3.5:                 $dotnet
Fast Startup:               $faststart
SmartDeploy:                $SmartDeploy

Power Options:  
    Monitor Timeout Battery:    $montimeoutdc   Minutes
    Monitor Timeout Plugged in: $montimeoutac   Minutes
    Sleep Timeout Battery:      $sleeptimeoutdc Minutes
    Sleep Timeout Plugged in:   $sleeptimeoutac Minutes 

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