Function Install-OEMKey {
    Write-Host "[*] Checking Windows Activation..." -ForegroundColor Yellow
    #Get OEM Product key from bios
    $OEMproductkey = (Get-WmiObject -query ‘select * from SoftwareLicensingService’).OA3xOriginalProductKey
    #Get Windows licensing status
    $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
    if ($licensestatus.LicenseStatus -eq 1){
        Write-Host "[*] Windows is  Activated" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Windows not yet activated." -ForegroundColor Yellow
        Write-Host "[*] Activating Windows..." -ForegroundColor Yellow
        $licensestatus.InstallProductKey($OEMproductkey)
        $licensestatus.RefeshLicenseStatus()
        if ($licensestatus.LicenseStatus -eq 1){
            Write-Host "Windows is Permanently Activated" -ForegroundColor Green
        }
        else {
            Write-Error -Message "[*] Windows failed to activate..." 
        }
    }
}