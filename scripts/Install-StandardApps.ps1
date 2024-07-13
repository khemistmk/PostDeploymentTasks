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
        [string]$TemporaryDownloadFolder = "C:\Users\" + $($env:username) + "\AppData\Local\Temp\"
        
    )

    begin {
        $7zipWebsite = 'https://7-zip.org/'
        $TemporaryDownloadFile = $TemporaryDownloadFolder + "7zip.exe" 
    }

    process {
        Write-Host "[*] Installing Google Chrome..." -Foregroundcolor Yellow
        winget install -e --id Google.Chrome --silent --accept-source-agreements --accept-package-agreements
        Write-Host "[*] Google Chrome installed." -Foregroundcolor Green
        Write-Host "[*] Installing Firefox..." -Foregroundcolor Yellow
        winget install -e --id Mozilla.Firefox --silent --accept-source-agreements --accept-package-agreements
        Write-Host "[*] Firefox installed." -Foregroundcolor Green
        Write-Host "[*] Installing VLC..." -Foregroundcolor Yellow
        winget install -e --id VideoLAN.VLC --silent --accept-source-agreements --accept-package-agreements
        Write-Host "[*] VLC installed." -Foregroundcolor Green
        Write-Host "[*] Installing 7zip..." -Foregroundcolor Yellow
        $webLocation = $7zipWebsite + (Invoke-WebRequest -Uri $7zipWebsite | 
            Select-Object -ExpandProperty Links | 
            Where-Object {($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} |
            Select-Object -ExpandProperty href)
        Invoke-WebRequest $webLocation -OutFile $TemporaryDownloadFile
        Start-Process $TemporaryDownloadFile -ArgumentList "/S" -Wait
        Write-Host "[*] 7zip Installed." -Foregroundcolor Green
    
    }
    end {
    
    }
}
