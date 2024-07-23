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
         [Validateset("Adobe2020","AdobeReader","FoxitBusiness")]
        [string]$InstallPDFVers,
        
        [Parameter()]
        $downloadfolder = "$env:USERPROFILE\Downloads"
)

    begin {
        Import-module bitstransfer
    }

    process {
        if ($InstallPDFVers -eq "Adobe2020") {
            try {  
                Write-Host "[*] Downloading Adobe files..." -ForegroundColor Yellow  
                Invoke-WebRequest -Uri "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_2020_Web_WWMUI.zip" -Outfile "$downloadfolder\$InstallPDFVers.zip"
                Write-Host "[*] Extracting Adobe files..." -ForegroundColor Yellow
                Expand-Archive -Path "$downloadfolder\$InstallPDFVers.zip" -DestinationPath $downloadfolder\$InstallPDFVers
                Write-Host "[*] Installing $InstallPDFVers..." -ForegroundColor Yellow
                $process = Start-Process -FilePath "$downloadfolder\$InstallPDFVers\Adobe Acrobat\Setup.exe" -ArgumentList "/sl","1133","/sAll","/msi" - -PassThru
                for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                    Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                    Start-Sleep -Milliseconds 100
                    if ($process.HasExited) {
                    Write-Progress -Activity "Installer" -Completed
                    break
                    }
                }
                Write-Host "[*] $InstallPDFVers installed." -ForegroundColor Green
            }
            catch {
                Write-Error -message "[*] Unable to install $InstallPDFVers"
            }
        }
        elseif ($InstallPDFVers -eq "AdobeReader"){
            try {
                Write-Host "[*] Installing $InstallPDFVers..." -ForegroundColor Yellow
                winget install -e --id Adobe.Acrobat.Reader.32-bit
            }
            catch {
                Write-Error -message "[*] Unable to install $InstallPDFVers"
            }
        }
        elseif ($InstallPDFVers -eq "FoxitBusiness") {
            try {
                Write-Host "[*] Installing $$InstallPDFVers..." -ForegroundColor Yellow
            }
            catch {
            }
        }
        else {
            Write-Error -message "[*] Unable to install $InstallPDFVers."
        }
    }
    end {
    }
}
