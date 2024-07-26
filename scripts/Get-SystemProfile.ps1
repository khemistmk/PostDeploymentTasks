function Get-SystemProfile {
    <#
    .SYNOPSIS 
        This script will disable the default Administrator account.
    .DESCRIPTION
        This script will check if the default Administrator account is enabled and if so, disable it.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Manufacturer,

        [Parameter()]
        [switch]$Hardware,

        [Parameter()]
        $RAMDetails,

        [Parameter()]
        $DriveDetails,

        [Parameter()]
        [switch]$OperatingSystem,

        [Parameter()]
        [switch]$Programs,

        [Parameter()]
        [switch]$CommonSettings,

        [Parameter()]
        [switch]$PowerSettings,

        [Parameter()]
        [switch]$All

    )

    begin {   
        $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
        $computername = (Get-WmiObject -Class Win32_Operatingsystem).PSComputerName
        $winver = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
        $Winbuild = (Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DisplayVersion')
        $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
        $Admin = (Get-LocalUser -Name "Administrator").Enabled
        $man = (Get-CimInstance -ClassName Win32_ComputerSystem).manufacturer
        $model = (Get-CimInstance -Namespace root\wmi -ClassName MS_SystemInformation).SystemVersion
        $CPUInfo = (Get-CimInstance Win32_Processor).name
        $RAM = Get-CimInstance win32_ComputerSystem | ForEach-Object {[math]::round($_.TotalPhysicalMemory /1GB)}
        $drivesize = Get-PhysicalDisk | ForEach-Object {[math]::round($_.size /1GB)}
        $Drivemanufacturer = Get-PhysicalDisk | Select-Object -ExpandProperty FriendlyName
        $drivebrand,$driveserial = $Drivemanufacturer -split " "
        $Drivetype = Get-PhysicalDisk | Select-Object -ExpandProperty MediaType
        $Bustype = Get-PhysicalDisk | Select-Object -ExpandProperty Bustype
        $graphic = (Get-CimInstance -ClassName Win32_VideoController).Description
        $graphiclist = $graphic -split "{" -split "}"
        $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
        $fsPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
        $fsName = "HiberbootEnabled"
        $fsvalue = (Get-ItemProperty -Path $fsPath -Name $fsName).HiberbootEnabled
        $RAMinfo = Get-CimInstance -Classname Win32_PhysicalMemory
        $ramcap = $RAMinfo | ForEach-Object {[math]::round($_.Capacity /1GB)}
        $ramman = $RAMinfo.Manufacturer
        $ramloc = $RAMinfo.DeviceLocator
        $ramspeed = $RAMinfo.Speed
        $ramchannel = $RAMinfo.InterleaveDataDepth
        $Programlist = Get-Package |
            Where-Object {($_.ProviderName -Like "Programs") -and ($_.Name -notLike "*Visual C++*")} |
            Select-Object -Property Name,Version |
            Sort-Object -Property Name | Format-Table
            }
    process {
        if ($licensestatus.LicenseStatus -eq 1){
            $winactivation = "Activated"
        }
        if (($drivesize -gt "459")-and ($drivesize -lt "468")) { $Drive = "500 GB"}
        if (($drivesize -gt "469") -and ($drivesize -lt "479")) { $Drive = "512 GB"}
        if (($drivesize -gt "929") -and ($drivesize -lt "1024")) { $Drive = "1 TB"}
        if (($drivesize -gt "1800") -and ($drivesize -lt "2048")) { $Drive = "2 TB"}
        if (!$Admin) {
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

        $OSinfo = [PSCustomObject]@{
            WindowsVerson       =   $winver
            BuildVersion        =  $winbuild
            WindowsActivation   =   $winactivation
        }
        $Maninfo = [PSCustomObject]@{
            Manufacturer        =   $Man
            Model               =   $model
            ComputerName        =   $computername
            SerialNumber        =   $serialnumber
        }
        $Hardwareinfo = [PSCustomObject]@{
            CPU                 =   $CPUInfo
            RAM                 =   "$RAM GB"
            Drive               =   "$Drive $drivebrand $Bustype $Drivetype"
            Graphics            =   $graphiclist
        }
        $DriveInformation = [PSCustomObject]@{
            Size                =   $Drive
            Manufacturer        =   $drivebrand
            BusType             =   $Bustype
            DriveType           =   $Drivetype
        }
      
        $CommonSetinfo = [PSCustomObject]@{
            Bitlocker           =   $bit
            Administrator       =   $Adminstatus
            Dotnet3             =   $dotnet
            FastStartup         =   $faststart
        }
        $Powerinfo = [PSCustomObject]@{
            MonitorTimeoutDC    =   "$montimeoutdc Min"
            MonitorTimeoutAC    =   "$montimeoutac Min"
            SleepTimeoutDC      =   "$sleeptimeoutdc Min"
            SleepTimeoutAC      =   "$sleeptimeoutac Min"
        }

        $AllInfo = [PSCustomObject]@{
            WindowsVerson       =   $winver
            WindowsActivation   =   $winactivation
            BuildVersion        =   $Winbuild
            Manufacturer        =   $Man
            Model               =   $model
            ComputerName        =   $computername
            SerialNumber        =   $serialnumber
            CPU                 =   $CPUInfo
            RAM                 =   "$RAM GB"
            Drive               =   "$Drive $drivebrand $Bustype $Drivetype"
            Graphics            =   $graphiclist
            Bitlocker           =   $bit
            Administrator       =   $Adminstatus
            Dotnet3             =   $dotnet
            FastStartup         =   $faststart
            MonitorTimeoutDC    =   "$montimeoutdc Min"
            MonitorTimeoutAC    =   "$montimeoutac Min"
            SleepTimeoutDC      =   "$sleeptimeoutdc Min"
            SleepTimeoutAC      =   "$sleeptimeoutac Min"
            

        }
        if ($Manufacturer) {
            Write-Output -InputObject  $Maninfo
        }
        if ($Hardware) {
            Write-Output -InputObject  $Hardwareinfo
        }
        if ($RAMDetails) {
            Write-Output -InputObject  $RAMInformation
        }
        if ($DriveDetails) {
            Write-Output -InputObject  $DriveInformation
        }
        if ($OperatingSystem) {
            Write-Output -InputObject  $OSinfo
        }
        if ($Programs) {
            Write-Output -InputObject  $Programlist
        }
        if ($CommonSettings) {
            Write-Output -InputObject  $CommonSetinfo
        }
        if ($PowerSettings) {
            Write-Output -InputObject  $Powerinfo
        }
        if ($All) {
            Write-Output -InputObject $AllInfo
            Write-Output -InputObject $Programlist  
        }
    }
    end {

    }
}
