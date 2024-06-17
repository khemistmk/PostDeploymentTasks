# Post-Deployment Script
# by Timothy Wilson
#
# ---------------------------
#
#This script will perform the following actions under the default profile:
# * Disabled built in Administrator account
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
    #grab latest from http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html](http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html
    hp-hpia-5.2.1.exe /s
    cd C:\\SWSetup\\SP140024
    HPImageAssistant.exe /Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent
    }
}

Function Ninite {
    $Ninite
}

Function RMDeployfiles {
    del "C:\OEM"
    del "C:\Platform"
}

Function Deployment {
    WinActivation
    ComputerName
    DotNet3
    Ninite
    SystemUpdate
    windowsupdate
    Bitlocker
    
}

$cpuInfo = Get-CimInstance -ClassName Win32_Processor

$cpuname = $cpuInfo.Name




Function Get-OSName
{
   $osversion = (Get-WmiObject Win32_OperatingSystem).Caption
   write-output "$osversion"
}