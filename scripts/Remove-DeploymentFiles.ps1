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