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
        Write-Verbose "Checking Windows Activation..."
        #Get OEM Product key from bios
        $OEMproductkey = (Get-WmiObject -Class SoftwareLicensingService).OA3xOriginalProductKey
        #Get Windows licensing status
        $licensestatus = Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Where-Object -Property Name -Like "Windows*"
        if ($licensestatus.LicenseStatus -eq 1){
            Write-Host "Windows is activated."
        }
        else {
            Write-Verbose "Windows not yet activated."
            try {
                Write-Verbose "Activating Windows..."
                cscript C:\Windows\System32\slmgr.vbs /ipk $OEMproductkey | Out-Null
                cscript C:\Windows\System32\slmgr.vbs /ato | Out-Null
                if ($licensestatus.LicenseStatus -eq 1){
                    Write-Host "Windows is Activated"
                }
            }
            catch {
                Write-Error -Message "Windows failed to activate." 
            }
        }
        $ProductKey = [PSCustomObject]@{
            ProductKey = $OEMproductkey
        }
    }
    end {
        Write-Output -InputObject $ProductKey
    }
}