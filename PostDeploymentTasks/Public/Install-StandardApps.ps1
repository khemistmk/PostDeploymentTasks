Function Install-StandardApps {
<#
    .SYNOPSIS 
        This script will install standard apps used in deployments.
    .DESCRIPTION
        This script will install standard apps used in deployments, including VLC, 7zip, Google Chrome, and Firefox
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$TemporaryDownloadFolder = "C:\Users\" + $($env:username) + "\AppData\Local\Temp\",
        
        [Parameter()]
        [string[]]$applist =@("Google.Chrome","Mozilla.Firefox","VideoLAN.VLC","7zip")
    )

    begin {
        $7zipWebsite = 'https://7-zip.org/'
        $TemporaryDownloadFile = $TemporaryDownloadFolder + "7zip.exe" 
    }

    process {
        foreach ($a in $applist) {
            if ($a -eq "7zip") {
               Write-Verbose "Installing $a ..." -Foregroundcolor Yellow
               $webLocation = $7zipWebsite + (Invoke-WebRequest -Uri $7zipWebsite | 
                   Select-Object -ExpandProperty Links | 
                   Where-Object {($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} |
                   Select-Object -ExpandProperty href)
               Invoke-WebRequest $webLocation -OutFile $TemporaryDownloadFile
               Start-Process $TemporaryDownloadFile -ArgumentList "/S" -Wait
               Write-Verbose " $a Installed." -Foregroundcolor Green
            }
            else {
                Write-Verbose "Installing $a ..." -Foregroundcolor Yellow
                winget install -e --id $a --silent --accept-source-agreements --accept-package-agreements
                Write-Verbose "$a Installed." -Foregroundcolor Green
            }
        }
    }
    end {
    
    }
}
