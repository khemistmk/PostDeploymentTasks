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
        [string]$setdotnet3 = "Enabled",
        
        [Parameter()]
        [ValidateSet("Enabled", "Disabled")]
        [string]$setdotnet4 = "Enabled"
    )
    begin {
    }

    process {
        switch ($setdotnet3) {
            'Enabled' {
                #Enables .Net 3.5
                Write-Verbose "Checking .Net 3.5 Status."
                $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
                if ($dotnet3 -eq 'True') {
                    $dotnet3status = "Enabled"
                    Write-Verbose ".Net 3.5 Enabled"
                }
                else {
                    Write-Verbose "Enabling .Net 3.5"
                    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -Source "SourcePath"
                    $dotnet3status = "Enabled"
                    Write-Verbose ".Net 3.5 Enabled"
                }
            }
            'Disabled' {
                Write-Verbose "Checking .Net 3.5 Status."
                $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
                if ($dotnet3 -eq 'False') {
                    $dotnet3status = "Disabled"
                    Write-Verbose ".Net 3.5 Disabled"
                }
                else {
                    Write-Verbose "Disabling .Net 3.5"
                    Disable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -Source "SourcePath"
                    $dotnet3status = "Disabled"
                    Write-Verbose ".Net 3.5 Disabled"
                }
            }
        }
        switch ($setdotnet4) {
            'Enabled' {
                Write-Verbose "Checking .Net 4.8 Status"
                $dotnet4 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 4 -and $_.Minor -eq 8}).Count -ge 1
                if ($dotnet4 -eq 'True') {
                    $dotnet4status = "Enabled"
                    Write-Verbose ".Net 4.8 Enabled"
                }
                else {
                    Write-Verbose "Enabling .Net 4.8"
                    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx4" -Source "SourcePath"
                    $dotnet4status = "Enabled"
                    Write-Verbose ".Net 4.8 Enabled"
                }
            }
            'Disabled' {
                Write-Verbose "Checking .Net 4.8 Status"
                $dotnet4 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 4 -and $_.Minor -eq 8}).Count -ge 1
                if ($dotnet4 -eq 'False') {
                    $dotnet4status = "Disabled"
                    Write-Verbose ".Net 4.8 Disabled"
                }
                else {
                    Write-Verbose "Disabling .Net 4.8"
                    Disable-WindowsOptionalFeature -Online -FeatureName "NetFx4" -Source "SourcePath"
                    $dotnet4status = "Disabled"
                    Write-Verbose ".Net 4.8 Disabled"
                }
            }

        }
        $DotnetStatus = [PSCustomObject]@{
            DotNet3 = $dotnet3status
            DotNet4 = $dotnet4status
        }
    }
    end {
        Write-Output -InputObject $DotnetStatus
    }
}
