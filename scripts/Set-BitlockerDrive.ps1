function Set-BitlockerDrive {
    #Checks if Bitlocker enabled, if not, enables and prints recovery password to file
    Write-Host "[*] Checking Bitlocker status..." -ForegroundColor Yellow
    if (((Get-BitLockerVolume -MountPoint c:).VolumeStatus) -eq 'FullyEncrypted') {
        Write-Host "[*] Bitlocker is already enabled for Drive C:" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Enabling bitlocker..." -ForegroundColor Yellow
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -RecoveryPasswordProtector
    }
    $Bitlockerkey = (Get-BitLockerVolume -MountPoint C).KeyProtector |
        Where-Object -Property KeyProtectorType -eq RecoveryPassword |
        Select-Object -Property KeyProtectorID,RecoveryPassword 
    $blid = $bitlockerkey.KeyProtectorID
    $blpw = $bitlockerkey.RecoveryPassword
    "Identifier","$blid" > "$PSScriptroot\$computername.txt"
    Write-Host "Bitlocker enabled. Bitlocker key is saved to $scriptroot\$computername.txt" -ForegroundColor Green
    Write-Host "$Bitlockerkey" -ForegroundColor Yellow
}
