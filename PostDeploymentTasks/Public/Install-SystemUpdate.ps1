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
        $setupfolder = "$env:USERPROFILE\Downloads"
    )
    begin {
        $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
        }

    process {
        if ($Manufacturer -contains "Lenovo"){
            try {
                Write-Verbose "Downloading System Update..."
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
            Write-Verbose "Installing Lenovo System Update..."
            Start-Process -FilePath "$setupfolder\$systemupdate" -ArgumentList "/VERYSILENT /NORESTART" -Wait
            $systemupdatepath = "C:\Program Files (x86)\Lenovo\System Update\Tvsu.exe"
            if (Test-Path -Path $systemupdatepath) {
                try {
                    Write-Verbose "Lenovo System Update installed"
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
                    Write-Verbose "Running Lenovo System Update..."
                    Start-Process -FilePath $systemupdatepath -ArgumentList "/CM" -Wait   
                }
                catch {
                    Write-Error -Message "Unable to run Lenovo System Update"
                }
            }
            else {
                Write-Error "Unable to install Lenovo System Update"
            }
        }
        elseif ($manufacturer -contains "HP"){
            try {
                Write-Verbose "Downloading HPIA..."
                $response = Invoke-WebRequest -Uri "http://ftp.ext.hp.com//pub/caps-softpaq/cmit/HPIA.html" -UseBasicParsing
                $HPIAlink = $response | Select-Object -ExpandProperty Links | Where-Object {$_.href -like "*.exe"} | Select-Object -ExpandProperty href  
                $HPIAroot,$HPIAfile = $HPIAlink -split "/hpia/"
                Invoke-WebRequest -Uri $HPIAlink -OutFile "$setupfolder\$HPIAfile"
            }
            catch {
                Write-Error -Message "Unable to download HPIA"
            }
            Write-Verbose "Installing HPIA..."
            Start-Process -Filepath "$setupfolder\$HPIAfile" -ArgumentList "/s" -Wait
            $HPIAPath = "C:\SWSetup\SP151464\HPImageAssistant.exe"
            if (Test-Path -Path $HPIAPath) {
                try {
                    Write-Verbose "Starting HPIA"
                    Start-Process -FilePath "$HPIAPath" -ArgumentList "/Operation:Analyze", "/Category:All", "/selection:All", "/action:install", "/silent", "/reportFolder:c:\temp\HPIA\Report", "/softpaqdownloadfolder:c:\temp\HPIA\download" -Wait
                }
                catch {
                    Write-Error -Message "Unable to start HPIA"
                }
            }
            else {
                Write-Error -Message "Unable to install HPIA"
            }
        }
        elseif ($manufacturer -contains "Dell"){
            Write-Verbose "Downloading Dell Command"
            winget install -e --id Dell.CommandUpdate --accept-source-agreements --accept-package-agreements
            $DcuClipath = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
            if (Test-Path -Path $DcuClipath) {
                Write-Verbose "Running Dell Command"
                Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=bios -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=firmware -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
                Start-Process -FilePath $DcuCliPath -ArgumentList "/applyUpdates -updateType=driver -reboot=disable" -NoNewWindow -PassThru -Wait -ErrorAction SilentlyContinue
            }
            else {
                Write-Error -Message "Unable to install Dell Command"
            }
        }
        else {
            Write-Error -Message "Unsupported Manufacturer $manufacturer"
        }
    }

    end {
        
    }
}