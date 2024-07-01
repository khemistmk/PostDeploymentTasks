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
        [string]$deployroot 

        [Parameter()]
        [string]$officefolder 

    )

    begin {
        
    }

    process {
        if ($deployroot -neq $PSScriptRoot) {
            $deployconnect = Test-Path -Path $deployroot
        }
        if ($deployconnect -eq "True") {
            Write-Host "[*] Copying Office Files" -ForegroundColor Yellow
            Copy-Item -Path "$deployroot\Microsoft Office\$officefolder" -Destination "$PSScriptRoot\$officefolder"
            Set-Location -Path "$scriptroot\$officefolder"
            Write-Host "[*] Installing Office..." -ForegroundColor Yellow
            Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -Wait
            Set-Location -Path $scriptroot
            $officeinstalled = Test-Path -Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
            if ($officeinstalled -eq "True") {
                Write-Host "[*] Microsoft Office Installed Successfully." -ForegroundColor Green
                Write-Host "[*] Running Microsoft Office Updates..." -ForegroundColor Yellow
                Start-Process -FilePath "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user"
            }
            else {
                Write-Error "[*] Microsoft Office Failed to install."
            }  
        }
        elseif ($deployroot -eq $PSScriptRoot){
            Set-Location -Path "$PSScriptRoot\$officefolder"
            Write-Host "[*] Installing Office..." -ForegroundColor Yellow
            Start-Process -FilePath "Setup.exe" -ArgumentList "/Configure $config" -Wait
            Set-Location -Path $scriptroot
            $officeinstalled = Test-Path -Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
            if ($officeinstalled -eq "True") {
                Write-Host "[*] Microsoft Office Installed Successfully." -ForegroundColor Green
                Write-Host "[*] Running Microsoft Office Updates..." -ForegroundColor Yellow
                Start-Process -FilePath "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "/update user"
            }
            else {
                Write-Error "[*] Microsoft Office Failed to install."
            }
        }
        else {
        Invoke-WebRequest "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17531-20046.exe" -OutFile "$scriptroot\ODT.exe"
        Start-Process -FilePath "$scriptroot\ODT.exe" -ArgumentList "/passive /extract:C:\temp\office\" -Wait
        Move-Item -Path "C:\temp\office"-Destination "$scriptroot\Office"
        Remove-Item -Path "C:\temp\office"
        }
    }
    end {

    }
}