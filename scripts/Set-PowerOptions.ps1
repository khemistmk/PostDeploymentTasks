function Set-PowerOptions {
<#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$montimeoutac,
        
        [Parameter()]
        [int]$montimeoutdc,

        [Parameter()]
        [int]$sbtimeoutac,

        [Parameter()]
        [int]$sbtimeoutdc,

        [Parameter()]
        [ValidateSet("Enabled", "Disabled")]
        [string]$faststartup,

        [Parameter()]
        [ValidateSet("Nothing", "Sleep", "Hibernate", "ShutDown")]
        [string]$powerbutton,
        
        [Parameter()]
        [ValidateSet("Nothing", "Sleep", "Hibernate", "ShutDown")]
        [string]$sleepbutton,

        [Parameter()]
        [ValidateSet("Nothing", "Sleep", "Hibernate", "ShutDown")]
        [string]$closelid
    )

    begin {
        function Test-IsAdmin {
            $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
            $p = New-Object System.Security.Principal.WindowsPrincipal($id)
            $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
        }

    }

    process {
        if (-not (Test-IsAdmin)) {
            Write-Error -Message "Access Denied. Please run with Administrator privileges."
        }
        Powercfg /Change monitor-timeout-ac $montimeoutac
        Powercfg /Change monitor-timeout-dc $montimeoutdc
        Powercfg /Change standby-timeout-ac $sbtimeoutac
        Powercfg /Change standby-timeout-dc $sbtimeoutdc
        
        $fsPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
        $fsName = "HiberbootEnabled"
        
        switch ($faststartup) {
            'Enable' {
                $fsValue = "1"
            }
            'Disable' {
                $fsValue = '0'
            }
        }
        
        try {
            if (-not $(Test-Path $fsPath)) {
                New-Item -Path $fsPath -Force | Out-Null
                New-ItemProperty -Path $fsPath -Name $fsName -Value $fsValue -PropertyType DWord -Force | Out-Null
            }
            else {
                New-ItemProperty -Path $fsPath -Name $fsName -Value $fsValue -PropertyType DWord -Force | Out-Null
            }
        }
        catch {
            Write-Error $_
            Write-Host "Failed to set Fast Boot setting"
        }

        $pbPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\7648EFA3-DD9C-4E3E-B566-50F929386280"
        $pbNameAC = "ACSettingIndex"
        $pbNameDC = "DCSettingIndex"

        switch ($powerbutton) {
            'Nothing' {
                $pbValue = "0" #Take no action
            }
            'Sleep' {
                $pbValue = '1' #Sleep
            }
            'Hibernate' {
                $pbValue = '2' #Hibernate
            }
            'ShutDown' {
                $pbValue = '3' #Shutdown
            }
        }
        
        try {
            if (-not $(Test-Path $pbPath)) {
                New-Item -Path $pbPath -Force | Out-Null
                New-ItemProperty -Path $pbPath -Name $pbNameAC -Value $pbValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $pbPath -Name $pbNameDC -Value $pbValue -PropertyType DWord -Force | Out-Null
            }
            else {
                New-ItemProperty -Path $pbPath -Name $pbNameAC -Value $pbValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $pbPath -Name $pbNameDC -Value $pbValue -PropertyType DWord -Force | Out-Null
            }
        }
        catch {
            Write-Error $_
            Write-Host "Failed to set Power Button setting"
        }
        $sbPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB"
        $sbNameAC = "ACSettingIndex"
        $sbNameDC = "DCSettingIndex"

        switch ($sleepbutton) {
            'Nothing' {
                $sbValue = "0" #Take no action
            }
            'Sleep' {
                $sbValue = '1' #Sleep
            }
            'Hibernate' {
                $sbValue = '2' #Hibernate
            }
            'ShutDown' {
                $sbValue = '3' #Shutdown
            }
        }
        
        try {
            if (-not $(Test-Path $sbPath)) {
                New-Item -Path $sbPath -Force | Out-Null
                New-ItemProperty -Path $sbPath -Name $sbNameAC -Value $sbValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $sbPath -Name $sbNameDC -Value $sbValue -PropertyType DWord -Force | Out-Null
            }
            else {
                New-ItemProperty -Path $sbPath -Name $sbNameAC -Value $sbValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $sbPath -Name $sbNameDC -Value $sbValue -PropertyType DWord -Force | Out-Null
            }
        }
        catch {
            Write-Error $_
            Write-Host "Failed to set Sleep Button setting"
        }
        $clPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\96996BC0-AD50-47EC-923B-6F41874DD9EB"
        $clNameAC = "ACSettingIndex"
        $clNameDC = "DCSettingIndex"

        switch ($closelid) {
            'Nothing' {
                $clValue = "0" #Take no action
            }
            'Sleep' {
                $clValue = '1' #Sleep
            }
            'Hibernate' {
                $clValue = '2' #Hibernate
            }
            'ShutDown' {
                $clValue = '3' #Shutdown
            }
        }
        
        try {
            if (-not $(Test-Path $clPath)) {
                New-Item -Path $clPath -Force | Out-Null
                New-ItemProperty -Path $clPath -Name $clNameAC -Value $clValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $clPath -Name $clNameDC -Value $clValue -PropertyType DWord -Force | Out-Null
            }
            else {
                New-ItemProperty -Path $clPath -Name $clNameAC -Value $clValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $clPath -Name $clNameDC -Value $clValue -PropertyType DWord -Force | Out-Null
            }
        }
        catch {
            Write-Error $_
            Write-Host "Failed to set Close Lid setting"
        }
        exit 1
    }

    end {

    }

}