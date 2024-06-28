###############################
# Post-Deployment Script
# by Timothy Wilson
###############################
Requires -RunAsAdministrator
[CmdletBinding()]
# ---------------------------
#
#   This script will perform the following actions under the default profile:
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

####Update the following paths as needed####

#script root folders
$deployroot = "\\tcs-deploy\techshare\"
$scriptroot = "C:\Setup Files"
$officefolder = "\Office\"
$computername = hostname

#System Update file location
#grab latest from https://support.lenovo.com/us/en/downloads/ds012808-lenovo-system-update-for-windows-10-7-32-bit-64-bit-desktop-notebook-workstation
$systemupdate = "System Update.exe"

#HP Imaging Assistant file location
#grab latest from http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html](http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html
$HPIA = "hp-hpia-5.2.1.exe"

#Ninite file location
$ninite = "AppInstaller32.exe"

############################################
Clear-Host
#Structure
Function Set-Header {
    Clear-Host
    Write-Host "---------------------------"
    Write-Host ""
    Write-Host "Post-Deployment Script v0.1"
    Write-Host ""
    Write-Host "---------------------------" 
}

#Menu
Function Set-MainMenu {
    Clear-Host
    Set-Header 
    Write-Host "---------------------------"
    Write-Host ""
    Write-Host " (0) Default Deployment (No Office, No PDF)"
    Write-Host " (1) Custom Deployment"
    Write-Host " (q) Quit"
    Write-Host ""
    Write-Host "---------------------------" 
}

Function Set-Defaulttext {
    Clear-Host
    Set-Header
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

function Set-Office {
    Clear-Host
    Set-Header
    Write-Host "---------------------------"
    Write-Host ""
    Write-Host " Select Office Version"
    Write-Host "    (1) Office 365"
    Write-Host "    (2) Office HBE 2021"
    Write-Host ""
    Write-Host "---------------------------"
}

Function Set-PDF {    
    Clear-Host
    Set-Header
    Write-Host "---------------------------"
    Write-Host ""
    Write-Host " Select PDF Version"
    Write-Host "    (1) Adobe STD 2020"
    Write-Host "    (2) Adobe PRO 2020"
    Write-Host "    (2) Foxit Business"
    Write-Host ""
    Write-Host "---------------------------" 
}

Function Set-Customtext {
    Set-Defaulttext
    if ($Office -eq '1') {
        Write-Host "* Install Microsoft 365 Apps"
    }
    elseif ($Office -eq '2') {
        Write-Host "* Install Microsoft HBE 2021 Apps"
    }
    else {Write-Host "No Office Apps Deployed"}
    if ($PDF -eq '1') {
        Write-Host "* Install Adobe STD 2020"
    }
    elseif ($PDF -eq '2') {
        Write-Host "* Install Adobe PRO 2020"
    }
    else {Write-Host "No PDF Apps Deployed"}
}

#Installation and changes
Function Set-ComputerName {
    Write-Host "[*] Setting Computer name..." -ForegroundColor Yellow
    $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
    $computername = hostname
    if ( $computername = $hostname ){
        return
    }
    else {
        Rename-Computer -newname "$serialnumber"
    }
    Write-Host "[*] Computer name set to $computername" -ForegroundColor Green
}
function Set-AdminDisable {
    Write-Host "[*] Checking default Administrator Account..." -ForegroundColor Yellow
    $adminaccount = Get-LocalUser -Name "Administrator"
    if ($adminaccount.Enabled -eq "False") {
        Write-Host "[*] Administrator account disabled." -ForegroundColor Yellow
    }
    else {
        Write-Host "[*] Disabling default Administrator Account..."-ForegroundColor Yellow
        Disable-LocalUser -Name "Administrator"
        Write-Host "[*] Administrator account disabled." -ForegroundColor Green
    }
}
Function Install-OEMKey {
    Write-Host "[*] Checking Windows Activation..." -ForegroundColor Yellow
    #Get OEM Product key from bios
    $OEMproductkey = (Get-WmiObject -query ‘select * from SoftwareLicensingService’).OA3xOriginalProductKey
    #Get Windows licensing status
    $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
    if ($licensestatus.LicenseStatus -eq 1){
        Write-Host "[*] Windows is  Activated" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Windows not yet activated." -ForegroundColor Yellow
        Write-Host "[*] Activating Windows..." -ForegroundColor Yellow
        $licensestatus.InstallProductKey($OEMproductkey)
        $licensestatus.RefeshLicenseStatus()
        if ($licensestatus.LicenseStatus -eq 1){
            Write-Host "Windows is Permanently Activated" -ForegroundColor Green
        }
        else {
            Write-Error -Message "[*] Windows failed to activate..." 
        }
    }
}

function Install-WindowsUpdates {
    Write-Host "[*] Checking for Windows Updates..." -ForegroundColor Yellow
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "StartInteractiveScan" -Wait
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "ScanInstallWait" -Wait
    Write-Host "[*] Installing Windows Updates..." -ForegroundColor Yellow
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "StartInstall" -Wait
    Write-Host "[*] Reboot to complete Windows Updates..." -ForegroundColor Red   
}

function Enable-DotNet {
    #Enables .Net 3.5
    Write-Host "[*] Checking .Net 3.5 Status..." -ForegroundColor Yellow
    $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
    if ($dotnet3 -eq 'True') {
        Write-Host "[*] .Net 3.5 Enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Enabling .Net 3.5..." -ForegroundColor Yellow
        DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
        Write-Host "[*] .Net 3.5 Enabled" -ForegroundColor Green
    }
    Write-Host "[*] Checking .Net 4.8 Status..." -ForegroundColor Yellow
    $dotnet4 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 4 -and $_.Minor -eq 8}).Count -ge 1
    if ($dotnet4 -eq 'True') {
        Write-Host "[*] .Net 4.8 Enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Installing .Net 4.8..."
        Invoke-WebRequest "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe" -OutFile "C:\Setup Files\net48Installer.exe"
        Start-Process -FilePath "$scriptroot\net48installer.exe" -ArgumentList "/install /quiet /norestart"
    }
}
function Set-BitlockerDrive {
    #Checks if Bitlocker enabled, if not, enables and prints recovery password to file
    Write-Host "[*] Checking Bitlocker status..." -ForegroundColor Yellow
    if (((Get-BitLockerVolume -MountPoint c:).VolumeStatus) -eq 'FullyEncrypted') {
        Write-Host "[*] Bitlocker is already enabled for Drive C:" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Enabling bitlocker..." -ForegroundColor Yellow
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -RecoveryPasswordProtector
    }
    $Bitlockerkey = (Get-BitLockerVolume -MountPoint C).KeyProtector | Where-Object -Property KeyProtectorType -eq RecoveryPassword | Select-Object -Property KeyProtectorID,RecoveryPassword 
    $Bitlockerkey > "$scriptroot\$computername.txt"
    Write-Host "Bitlocker enabled. Bitlocker key is saved to $scriptroot\$computername.txt" -ForegroundColor Green
    Write-Host "$Bitlockerkey" -ForegroundColor Yellow
}
Function Install-SystemUpdate {
    Write-Host "[*] Checking manufacturer..." -ForegroundColor Yellow
    $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer 
    if ($Manufacturer -contains "Lenovo"){
    Write-Host "[*] Installing Lenovo System Update..." -ForegroundColor Yellow
    Start-Process -FilePath "$scriptroot\$systemupdate" -ArgumentList "/VERYSILENT /NORESTART" -Wait
    $RegKey = "HKLM:\SOFTWARE\Policies\Lenovo\System Update\UserSettings\General"
    $RegName = "AdminCommandLine"
    $RegValue = "/CM -search A -action INSTALL -includerebootpackages 3 -noicon -noreboot -exporttowmi"    
    # Create Subkeys if they don't exist
    if (!(Test-Path $RegKey)) {
    New-Item -Path $RegKey -Force | Out-Null
    New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue | Out-Null
    }
    else {
    New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null
    } 
    Start-Process -FilePath "C:\Program Files (x86)\Lenovo\System Update\Tvsu.exe" -ArgumentList "/CM"
    }
    elseif ($manufacturer -contains "HP"){
    Start-Process -Filepath "$scriptroot\$HPIA" -ArgumentList "/s"
    Set-Location -FilePath "C:\SWSetup\SP140024"
    Start-Process -FilePath "HPImageAssistant.exe" -ArgumentList "/Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent"
    }
}
Function Start-Ninite {
    Start-Process -Filepath "$scriptroot\$Ninite" -ArgumentList "/Silent"
}
Function Remove-Deploymentfiles {
    Write-Host "[*] Removing OEM and Platform folders..." -ForegroundColor Yellow
    $oem = "C:\OEM"
    $platform = "C:\Platform"
    if (Test-Path -Path $oem) {
        Remove-Item -LiteralPath $oem -Force -Recurse
        Write-Host "[*] OEM folder removed." -ForegroundColor Green
    }
    else {
        Write-Host "[*] OEM folder removed." -ForegroundColor Green
    }
    if (Test-Path -Path $platform) {
        Remove-Item -LiteralPath "C:\Platform" -Force -Recurse
        Write-Host "[*] Platform folder removed." -ForegroundColor Green
    }
    else {
        Write-Host "[*] Platform folder removed." -ForegroundColor Green
    }
}
Function Uninstall-SmartDeploy {
    Write-Host "[*] Uninstalling Smart Deploy..." -ForegroundColor Yellow
    $Installer = New-Object -ComObject WindowsInstaller.Installer 
    $InstallerProducts = $Installer.ProductsEx("", "", 7)
    $InstalledProducts = ForEach($Product in $InstallerProducts){[PSCustomObject]@{ProductCode = $Product.ProductCode()
    $LocalPackage = $Product.InstallProperty("LocalPackage"); VersionString = $Product.InstallProperty("VersionString"); ProductPath = $Product.InstallProperty("ProductName")}} $InstalledProducts
    Start-Process MsiExec.exe -ArgumentList "/X{77753FDC-5039-4F18-B37C-E86B7EF921A9}" -Wait
    Write-Host "[*] Smart Deploy Uninstalled" -ForegroundColor Green
}

Function Start-Defaultdeploy {
    Set-ComputerName
    Set-AdminDisable
    Install-OEMKey
    Install-SystemUpdate
    Install-WindowsUpdates
    Enable-DotNet
    Remove-Deploymentfiles
    Start-Ninite
    Uninstall-SmartDeploy
    Install-SystemUpdate
    Install-WindowsUpdates
    Set-BitlockerDrive
}

Function Start-Customdeploy {
    Start-DefaultDeploy
    $deployconnect = Test-Path -Path $deployroot
    if ($deployconnect -eq "True") {
        Write-Host "[*] Copying Office Files" -ForegroundColor Yellow
        Copy-Item -Path "$deployroot\Microsoft Office\$officefolder" -Destination "$scriptroot\$officefolder"
        Set-Location -Path "$scriptroot\$officefolder"
        Write-Host "[*] Installing Office..." -ForegroundColor Yellow
        Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -Wait
        Set-Location -Path $scriptroot
        $officeinstalled = Test-Path -Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
        if ($officeinstalled -eq "True") {
            Write-Host "[*] Microsoft Office Installed Successfully." -ForegroundColor Green
            Write-Host "[*] Running Microsoft Office Updates..." -ForegroundColor Yellow
            Start-Process -FilePath "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user"
        }
        else {
            Write-Error "[*] Microsoft Office Failed to install."
        }
        Write-Host "[*] Copying Adobe files..." -ForegroundColor Yellow  
        Copy-Item -Path $PDFDeploy -Destination $scriptroot
        Write-Host "[*] Extracting Adobe files..." -ForegroundColor Yellow
        Expand-Archive -Path "$scriptroot\$PDFzip"
        Write-Host "[*] Installing $PDFFolder"
        Start-Process -FilePath "$scriptroot\Adobe Acrobat\Setup.exe" -ArgumentList "/sl","1133","/sAll","/msi"
    }
    elseif (Test-Path -Path "$scriptroot\Office*\Setup*"){
        Set-Location -Path "$scriptroot\$officefolder"
        Write-Host "[*] Installing Office..." -ForegroundColor Yellow
        Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -Wait
        Set-Location -Path $scriptroot
        $officeinstalled = Test-Path -Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
        if ($officeinstalled -eq "True") {
            Write-Host "[*] Microsoft Office Installed Successfully." -ForegroundColor Green
            Write-Host "[*] Running Microsoft Office Updates..." -ForegroundColor Yellow
            Start-Process -FilePath "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user"
        }
        else {
            Write-Error "[*] Microsoft Office Failed to install."
        }
        Write-Host "[*] Extracting Adobe files..." -ForegroundColor Yellow
        Expand-Archive -Path "$scriptroot\$PDFzip"
        Write-Host "[*] Installing $PDFFolder"
        Start-Process -FilePath "$scriptroot\Adobe Acrobat\Setup.exe" -ArgumentList "/sl","1133","/sAll","/msi"
    }
    
    else {
        Invoke-WebRequest "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17531-20046.exe" -OutFile "$scriptroot\ODT.exe"
        Start-Process -FilePath "$scriptroot\ODT.exe" -ArgumentList "/passive /extract:C:\temp\office\" -Wait
        Move-Item -Path "C:\temp\office"-Destination "$scriptroot\Office"
        Remove-Item -Path "C:\temp\office"

    }
}

Do {
    Set-MainMenu
    $Mainmenuselect = Read-Host "Please make a selection"
    Switch ($Mainmenuselect) {
        '0' {
            Set-DefaultText
            $Defaultselect = Read-Host " Press (1) to Deploy. Press (q) to quit"
            if ($Defaultselect -eq '1') {
                Start-Defaultdeploy
            }
            if ($Defaultselect -eq 'q') {
                Exit
            }
        }
        '1' {     
            Set-Office
            $Office = Read-Host "Please make a selection"
            switch ($Office) {
                '1' {
                    $officefolder = "Office 365"
                    $config = "configuration-Office365Business.xml"
                 }
                '2' {
                    $officefolder = "Office HBE 2021"
                    $config = "configuration-OfficeHBE2021.xml"
                } 
            }
            Set-PDF
            $PDF = Read-Host "Please make a selection"
            switch ($PDF) {
                '1' {
                    $PDFDeploy = "$deployroot\Third Party\Adobe\Adobe Acrobat 2020 Standard\Acrobat_2020_STD.zip"
                    $PDFZip = "Acrobat_2020_STD.zip"
                    $PDFFolder = "Acrobat_2020_STD"
                }
                '2' {
                    $PDFDeploy = "$deployroot\Third Party\Adobe\Adobe Acrobat 2020 Pro\Acrobat_2020_Pro.zip"
                    $PDFZip = "Acrobat_2020_PRO.zip"
                    $PDFfolder = "Acrobat_2020_PRO"
                }        
            }    
            Set-Customtext
            $Customdeploy = Read-Host " Press (1) to Deploy. Press (q) to quit"
            if ($Customdeploy -eq '1') {
                Customdeploy
            }
            if ($Customdeploy -eq 'q') {
                Exit
        }
        }
        'q' {
            Return
        }
    }
    Pause
}
Until (($Mainmenuselect -eq 'q') -or ($Defaultselect -eq 'q'))
Restart-Computer
Exit
