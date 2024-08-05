function Set-Bitlocker {
    <#
    .SYNOPSIS 
        This script will check if Bitlocker is enabled and, if not, enable it.
    .DESCRIPTION
        This script will check if Bitlocker is enabled and, if not, enable it and output the recover information into a text file
    .PARAMETER mountpoint
        This is the mountpoint to be encrypted.
    .PARAMETER savelocation
        This is the folder to save the bitlocker key.
    .PARAMETER Filename
        This is the filename to give the bitlocker key file. 
#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet("Enabled","Disabled")]
        [string]$Status = "Enabled",

        [Parameter()]
        $SaveLocation = "$env:USERPROFILE\Documents",

        [Parameter()]
        $Filename = $env:computername
    )

    begin {   
        
    }
    
    process {
        #Checks if Bitlocker enabled, if not, enables and prints recovery password to file
        switch ($status) {
            'Enabled' {
                Write-Verbose "Checking Bitlocker status."
                $bitlockerstatus = (Get-BitLockerVolume -MountPoint "C:").VolumeStatus
                if ( $bitlockerstatus -eq 'FullyEncrypted') {
                    Write-Verbose "Bitlocker already Enabled." 
                }
                else {
                    Write-Verbose "Enabling bitlocker for Volume C:"
                    Enable-BitLocker -MountPoint C: -RecoveryPasswordProtector -UsedSpaceOnly -SkipHardwareTest
                    do {
                        $Volume = Get-BitLockerVolume -MountPoint C:
                        Write-Progress -Activity "Encrypting volume $($Volume.MountPoint)" -Status "Encryption Progress:" -PercentComplete $Volume.EncryptionPercentage
                        Start-Sleep -Seconds 1
                    }
                    until ($Volume.VolumeStatus -eq 'FullyEncrypted')
                        Write-Verbose "Volume C: Fully Encrypted"
                }
                Write-Verbose "Checking Bitlocker status."
                $bitlockerstatus = Get-BitLockerVolume -MountPoint "C:"
                $Bitlockerkey = (Get-BitLockerVolume -MountPoint "C:").KeyProtector |
                    Where-Object -Property KeyProtectorType -eq RecoveryPassword |
                        Select-Object -Property KeyProtectorID,RecoveryPassword 
                $blid = $bitlockerkey.KeyProtectorID
                $blid2 = $blid -split "{" -split "}"
                $blpw = $bitlockerkey.RecoveryPassword
                $bitlockerfile = 
@"
                BitLocker Drive Encryption recovery key

        To verify that this is the correct recovery key, compare the start of the following identifier with
        the identifier value displayed on your PC.

        Identifier:

	        $blid2

        If the above identifier matches the one displayed by your PC, then use the following key to
        unlock your drive.

        Recovery Key:

	        $blpw

        If the above identifier doesn't match the one displayed by your PC, then this isn't the right key
        to unlock your drive.
        Try another recovery key, or refer to https://go.microsoft.com/fwlink/?LinkID=260589 for
        additional assistance.
"@
    
                $bitlockerfile | Out-File -Path "$SaveLocation\$Filename-bitlocker.txt"
                Write-Host "Bitlocker enabled. Bitlocker key is saved to $SaveLocation\$Filename-bitlocker.txt"
                Write-Host "$Bitlockerkey"
            }
            'Disabled' {
                Write-Verbose "Checking Bitlocker status."
                $bitlockerstatus = Get-BitLockerVolume -MountPoint "C:"
                if ( $bitlockerstatus.VolumeStatus -eq 'FullyDecripted') {
                    Write-Verbose "Bitlocker already disabled."
                }
                else {
                    Write-Verbose "Disabling bitlocker for Volume C:"
                    Disable-BitLocker -MountPoint "C:"
                    do {
                        $Volume = Get-BitLockerVolume -MountPoint C:
                        Write-Progress -Activity "Decrypting volume $($Volume.MountPoint)" -Status "Decryption Progress:" -PercentComplete $Volume.EncryptionPercentage
                        Start-Sleep -Seconds 1
                    }
                    until ($Volume.VolumeStatus -eq 'FullyDecrypted')
                    Write-Verbose "Volume C: Fully Decrypted"
                    
                }
            }
        }
    }
    end {
        $bitlockerstatus = Get-BitLockerVolume -MountPoint "C:"
        Write-Output -InputObject $bitlockerstatus
    }
}