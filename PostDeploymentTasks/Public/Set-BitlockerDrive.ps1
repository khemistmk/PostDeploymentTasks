function Set-BitlockerDrive {
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
        $SaveLocation = "$env:USERPROFILE\Documents",

        [Parameter()]
        $Filename = $env:computername
    )

    begin {   
        
    }
    
    process {
        #Checks if Bitlocker enabled, if not, enables and prints recovery password to file
        Write-Host "[*] Checking Bitlocker status..." -ForegroundColor Yellow
        if (((Get-BitLockerVolume -MountPoint "C:").VolumeStatus) -eq 'FullyEncrypted') {
            Write-Host "[*] Bitlocker is already enabled for Drive C:" -ForegroundColor Green
        }
         else {
            Write-Host "[*] Enabling bitlocker..." -ForegroundColor Yellow
            Enable-BitLocker -MountPoint "C:" -RecoveryPasswordProtector -UsedSpaceOnly -SkipHardwareTest
        }
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
    
        $bitlockerfile> "$SaveLocation\$Filename-bitlocker.txt"
        Write-Host "Bitlocker enabled. Bitlocker key is saved to $SaveLocation\$Filename-bitlocker.txt" -ForegroundColor Green
        Write-Host "$Bitlockerkey" -ForegroundColor Yellow
    }
    end {

    }
}