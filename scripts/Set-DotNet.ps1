function Set-DotNet {
<#
    .SYNOPSIS 
        This script will enable or disable .Net Framework.
    .DESCRIPTION
        This script aims to streamline and automate the enabling and disabling of.Net framework version 3.5 and 4.8.
    .PARAMETER setdotnet3
        Sets .Net Framework version 3.5 to enabled or disabled.
    .PARAMETER setdotnet4
        Sets .Net Framework version 4.8 to enabled or disabled.
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("Enabled", "Disabled")]
        [string]$setdotnet3,
        
        [Parameter()]
        [ValidateSet("Enabled", "Disabled")]
        [string]$setdotnet4
    )
    begin {
    }

    process {
        switch ($setdotnet3) {
            'Enabled' {
                #Enables .Net 3.5
                Write-Host "[*] Checking .Net 3.5 Status..." -ForegroundColor Yellow
                $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
                if ($dotnet3 -eq 'True') {
                    Write-Host "[*] .Net 3.5 Enabled" -ForegroundColor Green
                }
                else {
                    Write-Host "[*] Enabling .Net 3.5..." -ForegroundColor Yellow
                    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -Source "SourcePath"
                    Write-Host "[*] .Net 3.5 Enabled" -ForegroundColor Green
                }
            }
            'Disabled' {
                Write-Host "[*] Checking .Net 3.5 Status..." -ForegroundColor Yellow
                $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
                if ($dotnet3 -eq 'False') {
                    Write-Host "[*] .Net 3.5 Disabled" -ForegroundColor Green
                }
                else {
                    Write-Host "[*] Disabling .Net 3.5..." -ForegroundColor Yellow
                    Disable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -Source "SourcePath"
                    Write-Host "[*] .Net 3.5 Disabled" -ForegroundColor Green
                }
            }
        }
        switch ($setdotnet4) {
            'Enabled' {
                Write-Host "[*] Checking .Net 4.8 Status..." -ForegroundColor Yellow
                $dotnet4 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 4 -and $_.Minor -eq 8}).Count -ge 1
                if ($dotnet4 -eq 'True') {
                    Write-Host "[*] .Net 4.8 Enabled" -ForegroundColor Green
                }
                else {
                    Write-Host "[*] Enabling .Net 4.8..." -ForegroundColor Yellow
                    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx4" -Source "SourcePath"
                    Write-Host "[*] .Net 4.8 Enabled" -ForegroundColor Green
                }
            }
        }
    }
    end {
    }
}
