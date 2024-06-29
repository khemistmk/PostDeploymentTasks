Function Install-PDF {
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