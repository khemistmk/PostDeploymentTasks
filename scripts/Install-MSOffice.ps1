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
    }

    process {
        
        try {
            $officefolder = "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\"
            Set-Location -Path "$officefolder"
            Write-Host "[*] Installing Office..." -ForegroundColor Yellow
            Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -Wait
            Set-Location -Path $PSscriptroot
            $officeinstalled = Test-Path -Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
            if ($officeinstalled -eq "True") {
                Write-Host "[*] Microsoft Office Installed Successfully." -ForegroundColor Green
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