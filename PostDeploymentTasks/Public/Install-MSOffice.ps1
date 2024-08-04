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
        [ValidateSet("O365","O365-32","OHBE21","OHBE21-32")]
        [string]$officevers
    )

    begin {
        switch ($officevers) {
            'O365'{ $config = "Configuration-Office365Business.xml"}
            'O365-32' {$config = "Configuration-Office365Business-32bit.xml"}
            'OHBE21' {$config = "Configuration-OfficeHBE2021.xml"}
            'OHBE21-32' {$config = "Configuration-OfficeHBE2021-32bit.xml"}
        }
        $officeupdatepath = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
        }

    process {
        if (!(Test-Path -Path $officeupdatepath)){
            try {
                $officefolder = "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\"
                Set-Location -Path $officefolder
                Write-Verbose -Message "Installing Office..."
                Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -Wait
                Set-Location -Path $PSscriptroot    
            }
            catch {
                Write-Error -Message "Failed to install Microsoft Office"
            }
        }
        if (Test-Path -Path $officeupdatepath) {
            Write-Verbose "Microsoft Office Installed." 
            try {
                Write-Verbose "Checking for Microsoftr Office Updates..."
                Start-Process -FilePath $officeupdater - -ArgumentList "/update","User" -Wait    
            }
            catch {
                Write-Error "[*] Failed to update Microsoft Office."
            }
        }
    }
    end {

    }
}