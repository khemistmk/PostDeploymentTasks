Function Remove-Folder {
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
        [string[]]$Folder = @("C:\OEM","C:\Platform")
    )

    begin {   
        
    }
    
    process {
        foreach ($f in $Folder){
            if (Test-Path -Path $f) {
                Write-Verbose "Removing $f"
                Remove-Item -LiteralPath $f -Recurse -Force
                Write-Verbose "$f removed."
            }
            else {
                Write-Error "Folder location $f does not exist"
            }
        }
    }
    end{

    }
}