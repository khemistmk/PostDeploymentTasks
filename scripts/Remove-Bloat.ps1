Function Remove-Bloat {
<#
    .SYNOPSIS 
        This script will remove unneeded apps
    .DESCRIPTION
        This script will remove unneeded apps listed in \Assets\Applist.txt
#>
    [CmdletBinding()]
    param (
    )

    begin {   
        $applist = Get-Content "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\Applist.txt"
        $WinVersion = [System.Environment]::OSVersion.Version.Build
    }

    process {
        foreach ($app in $applist) {
            Write-Host "[*] Removing Bloat Apps..." -ForegroundColor Yellow
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