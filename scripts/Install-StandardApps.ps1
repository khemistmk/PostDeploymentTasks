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
        

        [Parameter()]
        
    )

    begin {   
        Install-Module -Name Microsoft.WinGet.Client
    }

    process {
        winget install -e --id Google.Chrome
        winget install -e --id Mozilla.Firefox
        winget install -e --id VideoLAN.VLC
        winget install -e --id Adobe.Acrobat.Reader.64-bit
        winget install -e --id Microsoft.Office

        $dlurl = 'https://7-zip.org/' + (Invoke-WebRequest -UseBasicParsing -Uri 'https://7-zip.org/' |
        Select-Object -ExpandProperty Links |
        Where-Object {($_.outerHTML -match 'Download')-and ($_.href -like "a/*") -and ($_.href -like "*-x64.exe")} |
        Select-Object -First 1 |
        Select-Object -ExpandProperty href)
        # modified to work without IE
        # above code from: https://perplexity.nl/windows-powershell/installing-or-updating-7-zip-using-powershell/
        $installerPath = Join-Path.$env:TEMP (Split-Path $dlurl -Leaf)
        Invoke-WebRequest $dlurl -OutFile $installerPath
        Start-Process -FilePath $installerPath -Args "/S" -Verb RunAs -Wait
    
    }
    end {
    Remove-Item $installerPath
    }
}