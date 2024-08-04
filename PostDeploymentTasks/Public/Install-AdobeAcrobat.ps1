Function Install-AdobeAcrobat {
    <#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
         [Validateset("Adobe2020","AdobeReader")]
        [string]$InstallPDFVers,
        
        [Parameter()]
        $downloadfolder = "$env:USERPROFILE\Downloads"
)

    begin {

    }

    process {
        switch ($InstallPDFVers) {
            'Adobe2020' {
                try {  
                    Write-Verbose " Downloading Adobe files..." 
                    Invoke-WebRequest -Uri "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_2020_Web_WWMUI.zip" -Outfile "$downloadfolder\$InstallPDFVers.zip"
                    Write-Verbose "Extracting Adobe files..."
                    Expand-Archive -Path "$downloadfolder\$InstallPDFVers.zip" -DestinationPath $downloadfolder\$InstallPDFVers
                    Write-Verbose "Installing $InstallPDFVers..."
                    Start-Process -FilePath "$downloadfolder\$InstallPDFVers\Adobe Acrobat\Setup.exe" -ArgumentList "/sl","1133","/sAll","/msi" -Wait
                    Write-Verbose "$InstallPDFVers installed."
                    Remove-Item -Path "$downloadfolder\$InstallPDFVers.zip" -Force
                    Remove-Item -Path "$downloadfolder\$InstallPDFVers" -Recurse -Force
                }
                catch {
                    Write-Error -message "Unable to install $InstallPDFVers"
                }
            }
            'AdobeReader'{
                try {
                    Write-Verbose "Installing $InstallPDFVers..."
                    winget install -e --id Adobe.Acrobat.Reader.32-bit
                }
                catch {
                    Write-Error -message "Unable to install $InstallPDFVers"
                }
            }
        }
    }
    end {
    }
}
