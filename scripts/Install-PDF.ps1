Function Install-PDF {
    <#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [Validateset("AdobeSTD2020","Adobe2020Pro","AdobeReader","FoxitBusiness")]
        [string]$InstallPDFVers,
        
        [Parameter()]
        $downloadfolder = "$env:USERPROFILE\Downloads"
)

    begin {
    }

    process {
        if ($InstallPDFVers -eq "AdobeSTD2020" -or "AdobePro2020") {
            try {  
                Write-Host "[*] Downloading Adobe files..." -ForegroundColor Yellow  
                Invoke-WebRequest -Uri "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_2020_Web_WWMUI.zip" -Outfile "$downloadfolder\$InstallPDFVers.zip"
                Write-Host "[*] Extracting Adobe files..." -ForegroundColor Yellow
                Expand-Archive -Path "$downloadfolder\$InstallPDFVers.zip"
                Write-Host "[*] Installing $InstallPDFVers"
                Start-Process -FilePath "$downloadfolder\Adobe Acrobat\Setup.exe" -ArgumentList "/sl","1133","/sAll","/msi"
            }
            catch {
                Write-Error -message "[*] Unable to install $InstallPDFVers"
            }
        }
        if ($InstallPDFVers -eq "AdobeReader"){
            try {
                Write-Host "[*] Installing $InstallPDFVers..." -ForegroundColor Yellow
                winget install -e --id Adobe.Acrobat.Reader.32-bit
            }
            catch {
                Write-Error -message "[*] Unable to install $InstallPDFVers"
            }
        }
        if ($InstallPDFVers -eq "FoxitBusiness") {
            try {
                Write-Host "[*] Installing $$InstallPDFVers..." -ForegroundColor Yellow
            }
            catch {
            }
        }
    }
    end {
    }
}
