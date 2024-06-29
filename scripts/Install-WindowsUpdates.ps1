function Install-WindowsUpdates {
    Write-Host "[*] Checking for Windows Updates..." -ForegroundColor Yellow
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "StartInteractiveScan" -Wait
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "ScanInstallWait" -Wait
    Write-Host "[*] Installing Windows Updates..." -ForegroundColor Yellow
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "StartInstall" -Wait
    Write-Host "[*] Reboot to complete Windows Updates..." -ForegroundColor Red   
}