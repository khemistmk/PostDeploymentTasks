Function Install-SystemUpdate {
        <#
    .SYNOPSIS 
        This script installs the OEM recommended system updater program and runs updates.
    .DESCRIPTION
        This script installs the OEM recommended system updater program and runs updates. supported OEMs are HP, Lenovo, and Dell.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        $setupfolder,

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
            $RegValue = "/CM -search A -action INSTALL -includerebootpackages 3 -noicon -exporttowmi"    
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
            try {
                Write-Host "[*] Downloading HPIA..."
                $response = Invoke-WebRequest -Uri "http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html" -UseBasicParsing
                $HPIAlink = $response | Select-Object -ExpandProperty Links | Where-Object {$_.href -like "*.exe"} | Select-Object -ExpandProperty href  
                $HPIAroot,$HPIAfile = $HPIA -split "/hpia/"
                Invoke-WebRequest -Uri $HPIAlink -OutFile "$PSScriptroot\$HPIAfile"
            }
            catch {
                Write-Error -Message "Unable to download HPIA"
            }
            Start-Process -Filepath "$PSScriptroot\$HPIAfile" -ArgumentList "/s"
            Set-Location -FilePath "C:\SWSetup\SP140024"
            Start-Process -FilePath "HPImageAssistant.exe" -ArgumentList "/Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent"
        }
        else {
            Write-Host "[*] Unsupported Manufacturer $manufacturer" -ForegroundColor Red
        }
    }
    end {
        
    }
}