function Install-WindowsUpdates {
<#
    .SYNOPSIS 
        This script automates the Post Deployment process.
    .DESCRIPTION
        This script aims to streamline and automate post-installation tasks by invoking several configurations and installations required for standard deployments.

#>
    [CmdletBinding()]
    param ()
    
    begin {
    }
    
    process {
    Write-Host "[*] Checking for Windows Updates..." -ForegroundColor Yellow
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "ScanInstallWait" -Wait
    Write-Host "[*] Installing Windows Updates..." -ForegroundColor Yellow
    Start-Process -Filepath "UsoClient.exe" -ArgumentList "StartInstall" -Wait
    Write-Host "[*] Reboot to complete Windows Updates..." -ForegroundColor Red  
$WshShell = New-Object -comObject WScript. Shell $WshShell.RegWrite('HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\InstallAtShutdown', '1', 'REG_DWORD')

Restart-Computer 
    }
    end {
    }
}