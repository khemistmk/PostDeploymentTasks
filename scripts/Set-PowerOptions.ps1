function Set-PowerOptions {
<#
    .SYNOPSIS 
        This script automates setting various power options.
    .DESCRIPTION
        This script aims to streamline and automate setting various power options required for standard deployments.

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]$montimeoutac = 60,
        
        [Parameter()]
        [int]$montimeoutdc = 30,

        [Parameter()]
        [int]$sbtimeoutac = 0,

        [Parameter()]
        [int]$sbtimeoutdc = 0,

        [Parameter()]
        [ValidateSet("Enabled", "Disabled")]
        [string]$faststartup = "Disabled",

        [Parameter()]
        [ValidateSet("Nothing", "Sleep", "Hibernate", "ShutDown")]
        [string]$powerbutton = "Shutdown",
        
        [Parameter()]
        [ValidateSet("Nothing", "Sleep", "Hibernate", "ShutDown")]
        [string]$sleepbutton = "Shutdown",

        [Parameter()]
        [ValidateSet("Nothing", "Sleep", "Hibernate", "ShutDown")]
        [string]$closelid = "Nothing"
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
        Write-Host "[*] Setting Power Options..." -ForegroundColor Yellow
        Powercfg /Change monitor-timeout-ac $montimeoutac
        Write-Host "[*] Set Display Turn off in $montimeoutac minutes when plugged in." -ForegroundColor Green
        Powercfg /Change monitor-timeout-dc $montimeoutdc
        Write-Host "[*] Set Display Turn off in $montimeoutdc minutes when on battery." -ForegroundColor Green
        Powercfg /Change standby-timeout-ac $sbtimeoutac
        if ($sbtimeoutac -eq 0) {
            $sleepac = "Never"
        }
        else {
            $sleepac = "$sbtimeoutac minutes" 
        }
        Write-Host "[*] Set Sleep Turn off in $sleepac when plugged in." -ForegroundColor Green
        Powercfg /Change standby-timeout-dc $sbtimeoutdc
        if ($sbtimeoutac -eq 0) {
            $sleepdc = "Never"
        }
        else {
            $sleepdc = "$sbtimeoutac minutes" 
        }
        Write-Host "[*] Set Sleep Turn off in $sleepdc when on battery." -ForegroundColor Green
        
        $fsPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Power"
        $fsName = "HiberbootEnabled"
        
        switch ($faststartup) {
            'Enabled' {
                $fsValue = "1"
            }
            'Disabled' {
                $fsValue = '0'
            }
        }
        
        try {
            if (-not $(Test-Path $fsPath)) {
                New-Item -Path $fsPath -Force | Out-Null
                New-ItemProperty -Path $fsPath -Name $fsName -Value $fsValue -PropertyType DWord -Force | Out-Null
                Write-Host "[*] Fast Startup set to $faststartup." -ForegroundColor Green
            }
            else {
                New-ItemProperty -Path $fsPath -Name $fsName -Value $fsValue -PropertyType DWord -Force | Out-Null
                Write-Host "[*] Fast Startup set to $faststartup." -ForegroundColor Green
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
                Write-Host "[*] Power button set to $powerbutton." -ForegroundColor Green
            }
            else {
                New-ItemProperty -Path $pbPath -Name $pbNameAC -Value $pbValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $pbPath -Name $pbNameDC -Value $pbValue -PropertyType DWord -Force | Out-Null
                Write-Host "[*] Power button set to $powerbutton." -ForegroundColor Green
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
                Write-Host "[*] Sleep button set to $sleepbutton." -ForegroundColor Green
            }
            else {
                New-ItemProperty -Path $sbPath -Name $sbNameAC -Value $sbValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $sbPath -Name $sbNameDC -Value $sbValue -PropertyType DWord -Force | Out-Null
                Write-Host "[*] Sleep button set to $sleepbutton." -ForegroundColor Green
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
                Write-Host "[*] Close lid set to $closelid." -ForegroundColor Green
            }
            else {
                New-ItemProperty -Path $clPath -Name $clNameAC -Value $clValue -PropertyType DWord -Force | Out-Null
                New-ItemProperty -Path $clPath -Name $clNameDC -Value $clValue -PropertyType DWord -Force | Out-Null
                Write-Host "[*] Close lid set to $closelid." -ForegroundColor Green
            }
        }
        catch {
            Write-Error $_
            Write-Host "Failed to set Close Lid setting"
        }
    }

}