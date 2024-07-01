Function Uninstall-SmartDeploy {
    $installed = Get-WmiObjecdt -Class Win32_Product | Where-Object {$_.Name -like '*SmartDeploy*'}
    $installed.Uninstall()
    Write-Host "[*] Smart Deploy Uninstalled" -ForegroundColor Green
}
