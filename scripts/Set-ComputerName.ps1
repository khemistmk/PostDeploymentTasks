Function Set-ComputerName {
    Write-Host "[*] Setting Computer name..." -ForegroundColor Yellow
    $serialnumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -Property SerialNumber).serialnumber
    $computername = hostname
    if ( $computername = $hostname ){
        return
    }
    else {
        Rename-Computer -newname "$serialnumber"
    }
    Write-Host "[*] Computer name set to $computername" -ForegroundColor Green
}