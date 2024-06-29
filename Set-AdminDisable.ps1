function Set-AdminDisable {
    Write-Host "[*] Checking default Administrator Account..." -ForegroundColor Yellow
    $adminaccount = Get-LocalUser -Name "Administrator"
    if ($adminaccount.Enabled -eq "False") {
        Write-Host "[*] Administrator account disabled." -ForegroundColor Yellow
    }
    else {
        Write-Host "[*] Disabling default Administrator Account..."-ForegroundColor Yellow
        Disable-LocalUser -Name "Administrator"
        Write-Host "[*] Administrator account disabled." -ForegroundColor Green
    }
}