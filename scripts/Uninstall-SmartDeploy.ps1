Function Uninstall-SmartDeploy {
    Write-Host "[*] Uninstalling Smart Deploy..." -ForegroundColor Yellow
    $Installer = New-Object -ComObject WindowsInstaller.Installer 
    $InstallerProducts = $Installer.ProductsEx("", "", 7)
    $InstalledProducts = ForEach($Product in $InstallerProducts){[PSCustomObject]@{ProductCode = $Product.ProductCode()
    $LocalPackage = $Product.InstallProperty("LocalPackage"); VersionString = $Product.InstallProperty("VersionString"); ProductPath = $Product.InstallProperty("ProductName")}} $InstalledProducts
    Start-Process MsiExec.exe -ArgumentList "/X{77753FDC-5039-4F18-B37C-E86B7EF921A9}" -Wait
    Write-Host "[*] Smart Deploy Uninstalled" -ForegroundColor Green
}