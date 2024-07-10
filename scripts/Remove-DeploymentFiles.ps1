Function Remove-Deploymentfiles {
<#
    .SYNOPSIS 
        This script will delete remnant folders left over from a deployment process.
    .DESCRIPTION
        This script will delete remnant folders left over from a deployment process.
    .PARAMETER OEM
        This is the OEM folder left over during the deployment process.
            -Default value is $OEM = "C:\OEM"
    .PARAMETER OEM
        This is the Platform folder left over during the deployment process.
            -Default value is $platform = "C:\Platform"
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        $OEM = "C:\OEM",

        [Parameter()]
        $platform = "C:\Platform"
    )

    begin {   
        
    }
    
    process {
        Write-Host "[*] Removing OEM and Platform folders..." -ForegroundColor Yellow
        if (Test-Path -Path $oem) {
        Remove-Item -LiteralPath $oem -Force -Recurse
        Write-Host "[*] $OEM folder removed." -ForegroundColor Green
        }
        else {
        Write-Host "[*] $OEM folder removed." -ForegroundColor Green
        }
        if (Test-Path -Path $platform) {
        Remove-Item -LiteralPath "C:\Platform" -Force -Recurse
        Write-Host "[*] $Platform folder removed." -ForegroundColor Green
        }
        else {
        Write-Host "[*] $Platform folder removed." -ForegroundColor Green
        }
    }
    end{

    }
}