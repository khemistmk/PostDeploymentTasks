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