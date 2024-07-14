Function Remove-Bloat {
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
            if ($WinVersion -ge 22000){
                # Windows 11 build 22000 or later
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
            }
            else {
                # Windows 10
                Get-AppxPackage -Name $app -PackageTypeFilter Main, Bundle, Resource -AllUsers | Remove-AppxPackage -AllUsers
            }

            # Remove provisioned app from OS image, so the app won't be installed for any new users
            Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
        }
    }
    end{

    }
}