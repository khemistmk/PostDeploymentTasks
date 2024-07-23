Function Install-MSOffice {
<#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.
    .PARAMETER deployroot
        The folder holding the files necessary for this script. can be a remote folder or placed in same location as the script.
    .PARAMETER officefolder
        The version of Office as a directory. eg: 'Office 365'.
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("O365","O365-32","OHBE21","OHBE21-32","OHBE19","OHBE19-32")]
        [string]$officevers
    )

    begin {
        switch ($officevers) {
            'O365'{ $config = "Configuration-Office365Business.xml"}
            'O365-32' {$config = "Configuration-Office365Business32.xml"}
            'OHBE21' {$config = "Configuration-OfficeHBE2021.xml"}
        }
        $officeupdatepath = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
        }

    process {
        if (Test-Path -Path $officeupdatepath){}
        try {
            $officefolder = "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\"
            Set-Location -Path "$officefolder"
            Write-Host "[*] Installing Office..." -ForegroundColor Yellow
            Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -PassThru
            for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                Start-Sleep -Milliseconds 100
                if ($process.HasExited) {
                Write-Progress -Activity "Installer" -Completed
                break
                }
            }
            Set-Location -Path $PSscriptroot
            $officeupdater = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
            if (Test-Path -Path $officeupdater) {
                Write-Host "[*] Microsoft Office Installed Successfully." -ForegroundColor Green
                Write-Host "[*] Checking for Microsoftr Office Updates..."
                $process = Start-Process -FilePath $officeupdater - -ArgumentList "/update","User" -PassThru
                for($i = 0; $i -le 100; $i = ($i + 1) % 100) {
                    Write-Progress -Activity "Installer" -PercentComplete $i -Status "Installing"
                    Start-Sleep -Milliseconds 100
                    if ($process.HasExited) {
                    Write-Progress -Activity "Installer" -Completed
                    break
                    }
                }
            }
            else {
                Write-Error "[*] Microsoft Office Failed to install."
            }  
        }
        catch {
            Write-Error "[*] Microsoft Office Failed to install."
        }
     
    }
    end {

    }
}