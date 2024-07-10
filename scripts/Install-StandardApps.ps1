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
        [string]$TemporaryDownloadFolder = "C:\Users\" + $($env:username) + "\AppData\Local\Temp\7Zip\"
        
    )

    begin {   
        Install-Module -Name Microsoft.WinGet.Client
        $7zipWebsite = 'https://7-zip.org/'
        $TemporaryDownloadFile = $TemporaryDownloadFolder + "7zip.exe" 
    }

    process {
        Write-Host "[*] Installing Google Chrome..." - Foregroundcolor Yellow
        winget install -e --id Google.Chrome
        Write-Host "[*] Google Chrome installed." - Foregroundcolor Green
        Write-Host "[*] Installing Firefox..." - Foregroundcolor Yellow
        winget install -e --id Mozilla.Firefox
        Write-Host "[*] Firefox installed." - Foregroundcolor Green
        Write-Host "[*] Installing VLC..." - Foregroundcolor Yellow
        winget install -e --id VideoLAN.VLC
        Write-Host "[*] VLC installed." - Foregroundcolor Green
        Write-Host "[*] Installing Adobe Reader..." - Foregroundcolor Yellow
        winget install -e --id Adobe.Acrobat.Reader.64-bit
        Write-Host "[*] Adobe Reader installed." - Foregroundcolor Green
        Write-Host "[*] Installing 7zip..." - Foregroundcolor Yellow
        $webLocation = $7zipWebsite + (Invoke-WebRequest -Uri $7zipWebsite | 
            Select-Object -ExpandProperty Links | 
            Where-Object {($_.innerHTML -eq 'Download') -and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} |
            Select-Object -ExpandProperty href).Split(' ')[0]
        Invoke-WebRequest $webLocation -OutFile $TemporaryDownloadFile
        Start-Process $TemporaryDownloadFile -ArgumentList "/S" -Wait
    
    }
    end {
    Remove-Item $TemporaryDownloadFolder -Recurse -Force
    }
}
