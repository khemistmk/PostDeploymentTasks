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
        $HPIA = "HPIA.exe",
        
        [Parameter()]
        $DellCommand = "DellCommand.exe"
    )
    begin {
        $manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
        }

    process {
        Write-Host "[*] Checking manufacturer..." -ForegroundColor Yellow
            if ($Manufacturer -contains "Lenovo"){
              function global:au_GetLatest {
                  $response = Invoke-RestMethod -Uri "https://download.lenovo.com/ibmdl/pub/pc/pccbbs/agent/SSClientCommon/HelloLevel_9_59_00.xml"
                  if ($response.Length -gt 0) {
        $xml = [xml] $response.Substring(3)
        $version = $xml.LevelDescriptor.Version
        $buildDate = $xml.LevelDescriptor.BuildDate
    }
    
    $Latest = createLatest $version $buildDate

    # Sometimes the version might be wrong, so check first
    try {
        Get-redirectedUri $Latest.URL32
    }
    catch {
        # Fallback to scraping the webpage
        $response = Invoke-WebRequest -Uri "https://support.lenovo.com/us/en/downloads/ds012808-lenovo-system-update-for-windows-10-7-32-bit-64-bit-desktop-notebook-workstation" -UseBasicParsing
        $pattern = '(?<="Name":"Lenovo\ System\ Update")[\S\s]*,"Version":"(?<Version>[\d\.]+)'
        $version = [regex]::Match($response.Content, $pattern).groups['Version'].value
        $pattern = '(?<="Name":"Lenovo\ System\ Update")[\S\s]*,"Date":\{"Unix":(?<Date>\d+)\}'
        $unixTime = [regex]::Match($response.Content, $pattern).groups['Date'].value
        $buildDate = [System.DateTimeOffset]::FromUnixTimeMilliseconds($unixTime).DateTime.ToString("d MMM yyyy")
        
        $Latest = createLatest $version $buildDate
    }

    return $Latest
}




            Write-Host "[*] Installing Lenovo System Update..." -ForegroundColor Yellow
            Start-Process -FilePath "$setupfolder\$systemupdate" -ArgumentList "/VERYSILENT /NORESTART" -Wait
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
        Start-Process -Filepath "$setupfolder\$HPIA" -ArgumentList "/s"
        Set-Location -FilePath "C:\SWSetup\SP140024"
        Start-Process -FilePath "HPImageAssistant.exe" -ArgumentList "/Action:Install /AutoCleanup /Category:BIOS, Drivers,Firmware /Silent"
        }
    }
    end {
        
    }
}