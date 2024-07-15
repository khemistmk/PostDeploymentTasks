Function Install-SystemUpdate {
        <#
    .SYNOPSIS 
        This script installs the OEM recommended system updater program and runs updates.
    .DESCRIPTION
        This script installs the OEM recommended system updater program and runs updates. supported OEMs are HP, Lenovo, and Dell.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        $setupfolder = "$env:USERPROFILE\Downloads",

        [Parameter()]
        $systemupdate = "System Update.exe",

        [Parameter()]
        $HPIA = "HPIA.exe"
        
        #[Parameter()]
        #$DellCommand = "DellCommand.exe"
    )
    begin {
        Write-Host "[*] Checking manufacturer..." -ForegroundColor Yellow
        $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
        }

    process {
        if ($Manufacturer -contains "Lenovo"){
            try {
                Write-Host "[*] Downloading System Update..."
                $response = Invoke-WebRequest -Uri "https://support.lenovo.com/us/en/downloads/ds012808-lenovo-system-update-for-windows-10-7-32-bit-64-bit-desktop-notebook-workstation" -UseBasicParsing
                $pattern = '(?<="Name":"Lenovo\ System\ Update")[\S\s]*,"Version":"(?<Version>[\d\.]+)'
                $version = [regex]::Match($response.Content, $pattern).groups['Version'].value
                $LSU = "https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_$version.exe"
                Invoke-WebRequest -Uri $LSU -OutFile "$PSScriptRoot\$systemupdate.exe"
            }
            catch {
                Write-Error -Message "Unable to download System Update"
            }
            Write-Host "[*] Installing Lenovo System Update..." -ForegroundColor Yellow
            Start-Process -FilePath "$PSScriptRoot\$systemupdate.exe" -ArgumentList "/VERYSILENT /NORESTART" -Wait
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
            Write-Host "[*] Running Lenovo System Update..." -ForegroundColor Yellow
            Start-Process -FilePath "C:\Program Files (x86)\Lenovo\System Update\Tvsu.exe" -ArgumentList "/CM"
        }
        elseif ($manufacturer -contains "HP"){
            try {
                Write-Host "[*] Downloading HPIA..."
                $response = Invoke-WebRequest -Uri "http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html" -UseBasicParsing
                $HPIAlink = $response | Select-Object -ExpandProperty Links | Where-Object {$_.href -like "*.exe"} | Select-Object -ExpandProperty href  
                $HPIAroot,$HPIAfile = $HPIAlink -split "/hpia/"
                Invoke-WebRequest -Uri $HPIAlink -OutFile "$PSScriptroot\$HPIAfile"
            }
            catch {
                Write-Error -Message "Unable to download HPIA"
            }
            Write-Host "[*] Running HPIA..." -ForegroundColor Yellow
            Start-Process -Filepath "$PSScriptroot\$HPIAfile" -ArgumentList "/s"
            Set-Location -FilePath "C:\SWSetup\SP151464"
            Start-Process -FilePath "HPImageAssistant.exe" -ArgumentList "/Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent"
        }
        elseif ($manufacturer -contains "Dell"){
            Write-Host "[*] Downloading Dell Command" -ForegroundColor Yellow
            winget install -e --id Dell.CommandUpdate --accept-source-agreements --accept-package-agreements
            $DcuClipath = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
            Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=bios -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
            Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=firmware -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
            Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=driver -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
        }
        else {
            Write-Host "[*] Unsupported Manufacturer $manufacturer" -ForegroundColor Red
        }

    }
    end {
        
    }
}