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
                $systemupdate = "system_update_$version.exe"
                $LSU = "https://download.lenovo.com/pccbbs/thinkvantage_en/$systemupdate"
                Invoke-WebRequest -Uri $LSU -OutFile "$setupfolder\$systemupdate"
            }
            catch {
                Write-Error -Message "Unable to download System Update"
            }
            Write-Host "[*] Installing Lenovo System Update..." -ForegroundColor Yellow
            $process = Start-Process -FilePath "$setupfolder\$systemupdate" -ArgumentList "/VERYSILENT /NORESTART" -PassThru
            for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                Start-Sleep -Milliseconds 100
                if ($process.HasExited) {
                Write-Progress -Activity "Installer" -Completed
                break
                }
            }
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
            $process = Start-Process -FilePath "C:\Program Files (x86)\Lenovo\System Update\Tvsu.exe" -ArgumentList "/CM" -PassThru
            for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                Start-Sleep -Milliseconds 100
                if ($process.HasExited) {
                Write-Progress -Activity "Installer" -Completed
                break
                }
            }
        }
        elseif ($manufacturer -contains "HP"){
            try {
                Write-Host "[*] Downloading HPIA..."
                $response = Invoke-WebRequest -Uri "http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html" -UseBasicParsing
                $HPIAlink = $response | Select-Object -ExpandProperty Links | Where-Object {$_.href -like "*.exe"} | Select-Object -ExpandProperty href  
                $HPIAroot,$HPIAfile = $HPIAlink -split "/hpia/"
                Invoke-WebRequest -Uri $HPIAlink -OutFile "$setupfolder\$HPIAfile"
            }
            catch {
                Write-Error -Message "Unable to download HPIA"
            }
            Write-Host "[*] Running HPIA..." -ForegroundColor Yellow
            $process = Start-Process -Filepath "$setupfolder\$HPIAfile" -ArgumentList "/s" -PassThru
            for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                Start-Sleep -Milliseconds 100
                if ($process.HasExited) {
                Write-Progress -Activity "Installer" -Completed
                break
                }
            }
            $swpath = "C:\SWSetup\SP151464"
            Start-Process -FilePath "$swpath\HPImageAssistant.exe" -ArgumentList "/Operation:Analyze", "/Category:All", "/selection:All", "/action:install", "/silent", "/reportFolder:c:\temp\HPIA\Report", "/softpaqdownloadfolder:c:\temp\HPIA\download" -PassThru
            for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                Start-Sleep -Milliseconds 100
                if ($process.HasExited) {
                Write-Progress -Activity "Installer" -Completed
                break
                }
            }
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