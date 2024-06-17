# Post-Deployment Script
# by Timothy Wilson
#
# ---------------------------
#
#This script will perform the following actions under the default profile:
# * Disable built in Administrator account
# * check and Set computer name to serial number
# * check activation and activate windows based on OEM bios key
# * install and run System Update if Lenovo, HP Image assistant if HP
# * run windows updates
# * run Ninite to install Chrome, Firefox, and VLC
# * activate bitlocker and print bitlocker key to file
# * install .Net 3.5
# * configure power plan: On Battery (screen off: 30min, sleep: never), Plugged in (screen off: 1 hr, sleep: never)
# * uninstall SmartDeploy
# * remove Deployment folders

#Update the following paths as needed
#System Update file location
$systemupdate = Start-Process -FilePath "C:\Setup Files\System Update.exe" -ArgumentList "/VERYSILENT /NORESTART"

#HP Imaging Assistant file location
#grab latest from http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html](http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html
$HPIA = Start-Process -Filepath "C:\Setup Files\hp-hpia-5.2.1.exe" -ArgumentList "/s"

#Ninite file location
$ninite =  Start-Process "C:\Setup Files\AppInstaller32.exe"

#Structure
Function Infoheader {
  Write-Host "---------------------------"
  Write-Host ""
  Write-Host "     Post-Deployment Script v0.1     "
  Write-Host ""
  Write-Host "---------------------------" 
}

#Menu
Function MainMenu {
    Write-Host "---------------------------"
    Write-Host ""
    Write-Host " (0) Default Deployment (No Office, No PDF)"
    Write-Host " (1) Custom Deployment"
    Write-Host ""
    Write-Host "---------------------------" 
    $Deploy = Read-Host "Please make a selection"
  }

Function Default {
    Write-Host "This script will perform the following actions under the default profile:"
    Write-Host "* Disable built in Administrator account"
    Write-Host "* check and Set computer name to serial number"
    Write-Host "* check activation and activate windows based on OEM bios key"
    Write-Host "* install and run System Update if Lenovo, HP Image assistant if HP"
    Write-Host "* run windows updates"
    Write-Host "* run Ninite to install Chrome, Firefox, and VLC"
    Write-Host "* activate bitlocker and print bitlocker key to file"
    Write-Host "* install .Net 3.5"
    Write-Host "* configure power plan: On Battery (screen off: 30min, sleep: never), Plugged in (screen off: 1 hr, sleep: never)"
    Write-Host "* uninstall SmartDeploy"
    Write-Host "* remove Deployment folders"
}

#Installation and changes
Function ComputerName {
    $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
    $computername = hostname
    if ( $computername = $hostname ){
        return
    }
    else {
        Rename-Computer -newname "$computername"
    }
}

Function WinActivation {
    $OEMproductkey = wmic path softwarelicensingservice get OA3OriginalProductKey
    $activationstatus = cscript c:\windows\system32\slmgr.vbs /xpr
    if (($activationstatus -contains "permanently activated")){
        return
    }
    else {
        slmgr /ipk $OEMproductkey
    }
}

Function windowsupdate {
    # Install the Windows Update module
    Install-Module -Name PSWindowsUpdate -Force
    # Import the Windows Update module
    Import-Module PSWindowsUpdate
    # Check for updates
    Start-Process (Get-WindowsUpdate -AcceptAll -Install -AutoReboot)
    Uninstall-Module -Name PSWindowsUpdate -Force
    # Restart the system if updates require a reboot
    Restart-Computer -Force
}

function DotNet3 {
    #Enables .Net 3.5
    Write-Host "[*] Enabling .Net 3.5" -ForegroundColor Green
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
    Write-Host "[*] .Net 3.5 Enabled"
}

function Bitlocker {
    #Checks if Bitlocker enabled, if not, enables and prints recovery password to file
    if (((Get-BitLockerVolume -MountPoint c:).VolumeStatus) -eq 'FullyEncrypted') {
        Write-Host "[*] Bitlocker is already enabled for Drive C:"
    }
    else {
        Enable-Bitlocker -MountPoint C -UsedSpaceOnly -RecoveryPassword
    }
    $Bitlockerkey = (Get-BitLockerVolume -MountPoint C).KeyProtector | Where-Object -Property KeyProtectorType -eq RecoveryPassword | Select-Object -Property KeyProtectorID,RecoveryPassword 
    $Bitlockerkey > "$HOME\$computername.txt"
    Write-Output "Bitlocker enabled. Bitlocker key is saved to $HOME\$computername.txt"
    Write-Output "$Bitlockerkey"
}

Function SystemUpdate {
    $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer 
    if ($Manufacturer -contains "Lenovo"){
    $systemupdate
    Start-Process -FilePath "C:\Program Files (x86)\Lenovo\System Update\Tvsu.exe" -ArgumentList "/CM -search R -action INSTALL -nolicense -IncludeRebootPackages 1,3,4"
    }
    elseif ($manufacturer -contains "HP"){
    $HPIA
    Set-Location -FilePath "C:\SWSetup\SP140024"
    Start-Process -FilePath "HPImageAssistant.exe" -ArgumentList "/Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent"
    }
}

Function Ninite {
    $Ninite
}

Function RMDeployfiles {
    del "C:\OEM" 
    del "C:\Platform"
}

Function SmartDeploy {
    $Installer = New-Object -ComObject WindowsInstaller.Installer 
    $InstallerProducts = $Installer.ProductsEx("", "", 7)
    $InstalledProducts = ForEach($Product in $InstallerProducts){[PSCustomObject]@{ProductCode = $Product.ProductCode()
    $LocalPackage = $Product.InstallProperty("LocalPackage"); VersionString = $Product.InstallProperty("VersionString"); ProductPath = $Product.InstallProperty("ProductName")}} $InstalledProducts

    Start-Process MsiExec.exe -ArgumentList "/X{77753FDC-5039-4F18-B37C-E86B7EF921A9}"
}

Infoheader
MainMenu

Function Deployment {
    switch ($Deploy) {
        '1'{ 
            WinActivation
            ComputerName
            DotNet3
            Ninite
            SystemUpdate
            windowsupdate
            Bitlocker
         }
        
    }
   
    
}

$cpuInfo = Get-CimInstance -ClassName Win32_Processor

$cpuname = $cpuInfo.Name




Function Get-OSName
{
   $osversion = (Get-WmiObject Win32_OperatingSystem).Caption
   write-output "$osversion"
}