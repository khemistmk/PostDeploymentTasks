Function Remove-App {
<#
    .SYNOPSIS 
        This script will remove unneeded applications
    .DESCRIPTION
        This script will remove unneeded apps listed in \Assets\Applist.txt or supplied by the parameter.
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]$applist = (Get-Content "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\Applist.txt")
    )

    begin {   
        
        $WinVersion = [System.Environment]::OSVersion.Version.Build
    }

    process {
        foreach ($app in $applist) {
            try {
                Write-Verbose "Removing application $app."
                if ($WinVersion -ge 22000){
                    # Windows 11 build 22000 or later
                    $removeapp = Get-AppxPackage -Name $app -AllUsers
                    if ($removeapp){
                        $removeapp |
                            Remove-AppxPackage -AllUsers
                    }
                    else {
                        write-error -Message "$app not installed."
                    }            
                }
                else {
                    $removeapp = Get-AppxPackage -Name $app -PackageTypeFilter Main, Bundle, Resource -AllUsers
                    if ($removeapp){
                        $removeapp |
                            Remove-AppxPackage -AllUsers
                    }
                    else {
                        write-error -Message "$app not installed."
                    } 
                }
                # Remove provisioned app from OS image, so the app won't be installed for any new users
                Get-AppxProvisionedPackage -Online |
                    Where-Object { $_.PackageName -like $app } |
                        ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
            }
            catch {
                Write-Error -Message "Unable to remove $app"
            }
        }    
       
    }
    end{

    }
}