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