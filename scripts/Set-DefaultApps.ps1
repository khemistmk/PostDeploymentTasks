function Set-DefaultApps {
    <#
        .SYNOPSIS 
            This script will set the default apps for new users on a machine.
        .DESCRIPTION
            This script sets Adobe, Foxit, or Chrome as the default .pdf viewer, Chrome as default browser, and Outlook as the default mail-to application.
    #>
        [CmdletBinding()]
        param (

        )
    
        begin {
            $Programs = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
            $Chrome = "Google Chrome.lnk"
            $AdobeReader = "Acrobat Reader.lnk"
            $AdobeAcrobat = "Adobe Acrobat.lnk"
            $Foxit = "Foxit Editor.lnk"
            $Outlook = "Outlook.lnk"
            $path = "$(($PSSCRIPTROOT).Parent.FullName)\Assests"
        }
    
        process {           
            if (Test-Path "$Programs\$Chrome") { $Browser = "Chrome" }
            if (Test-Path "$Programs\$Outlook") { $Mail = "Outlook" }
            if (Test-Path "$Programs\$Foxit") { $PDF = "Foxit" }
            elseif (Test-Path "$Programs\$AdobeAcrobat") { $PDF = "AdobeAcrobat" }
            elseif (Test-Path "$Programs\$AdobeReader") { $PDF = "AdobeReader" }
            else { $PDF = "Chrome" }
            $config = "$Browser$Mail$PDF.xml"
            try {
                Write-Host "[*] Setting Default Apps..." -ForegroundColor Yellow 
                DISM /Online /DefaultAppAssociations:$path\$config
                Write-Host "[*] Default Apps set." -ForegroundColor Green
            }
            catch {
                Write-Error-message "[*] Unable to set Default Apps."
        }
    
        end {
    
        }
    
    }