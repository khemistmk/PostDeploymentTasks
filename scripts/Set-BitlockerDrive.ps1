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
    $bitlockerfile = @"
          BitLocker Drive Encryption recovery key

To verify that this is the correct recovery key, compare the start of the following identifier with
the identifier value displayed on your PC.

Identifier:

	$blid

If the above identifier matches the one displayed by your PC, then use the following key to
unlock your drive.

Recovery Key:

	$blpw

If the above identifier doesn't match the one displayed by your PC, then this isn't the right key
to unlock your drive.
Try another recovery key, or refer to https://go.microsoft.com/fwlink/?LinkID=260589 for
additional assistance.
"@
    
    $bitlockerfile> "$PSScriptroot\$computername.txt"
    Write-Host "Bitlocker enabled. Bitlocker key is saved to $scriptroot\$computername.txt" -ForegroundColor Green
    Write-Host "$Bitlockerkey" -ForegroundColor Yellow
}
