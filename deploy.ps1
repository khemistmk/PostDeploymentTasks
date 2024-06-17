# Deployment Script
# by khemist
#
# ---------------------------
#
#This script will perform the following actions under the default profile:
# * check and Set computer name to serial number
# * check activation and activate windows based on OEM bios key
# * install and run System Update if Lenovo
# * run windows updates
# * run Ninite to install Chrome, Firefox, and VLC
# * activate bitlocker and print bitlocker key to file
# * install .Net 3.5
# * uninstall SmartDeploy
# * remove Deployment folders



Function Infoheader {
  Write-Host "---------------------------"
  Write-Host ""
  Write-Host "     Deployment Script v0.1     "
  Write-Host "---------------------------" 
  }


$serialnumber = wmic bios get serialnumber
$product key = wmic path softwarelicensingservice get OA3OriginalProductKey

$cpuInfo = Get-CimInstance -ClassName Win32_Processor

$cpuname = $cpuInfo.Name

Function Get-OSName
{
   $osversion = (Get-WmiObject Win32_OperatingSystem).Caption
   write-output "$osversion"
}

Function windowsupdate {
    # Install the Windows Update module
    Install-Module -Name PSWindowsUpdate -Force

    # Import the Windows Update module
    Import-Module PSWindowsUpdate

    # Check for updates
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot
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
    if (((Get-BitLockerVolume -MountPoint c:).VolumeStatus) -eq FullyEncrypted) {
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
    "C:\Setup Files\[System Update installation file name].exe" /VERYSILENT /NORESTART
    }
    elseif ($manufacturer -contains "HP"){
    #grab latest from http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html](http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html

    hp-hpia-5.2.1.exe /s
    cd C:\\SWSetup\\SP140024
    HPImageAssistant.exe /Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent
    }
}