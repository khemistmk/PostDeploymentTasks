Function Install-OEMKey {
    <#
    .SYNOPSIS 
        This script activates Microsoft Windows using the OEM product key from BIOS.
    .DESCRIPTION
        This script activates Microsoft Windows by pulling the OEM product key from BIOS and activating Windows via the OEM key.
#>
    [CmdletBinding()]
    param ()

    begin {
        
    }

    process {
        Write-Host "[*] Checking Windows Activation..." -ForegroundColor Yellow
        #Get OEM Product key from bios
        $OEMproductkey = (Get-WmiObject -Class SoftwareLicensingService).OA3xOriginalProductKey
        #Get Windows licensing status
        $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
        if ($licensestatus.LicenseStatus -eq 1){
            Write-Host "[*] Windows is  Activated" -ForegroundColor Green
        }
        else {
            Write-Host "[*] Windows not yet activated." -ForegroundColor Yellow
            Write-Host "[*] Activating Windows..." -ForegroundColor Yellow
            try {
            $licensestatus.InstallProductKey($OEMproductkey)
            $licensestatus.RefeshLicenseStatus()
            if ($licensestatus.LicenseStatus -eq 1){
                Write-Host "Windows is Permanently Activated" -ForegroundColor Green
            }
            }
            catch {
                Write-Error -Message "[*] Windows failed to activate." 
            }
        }
    }
    end {

    }
}