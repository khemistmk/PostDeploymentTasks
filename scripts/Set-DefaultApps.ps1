function Invoke-PostDeploymentTasks {
    <#
        .SYNOPSIS 
            This script will set the default apps for new users on a machine.
        .DESCRIPTION
            This script sets Adobe as the default .pdf viewer, Chrome as default browser, and Outlook as the default mail-to application.
    #>
        [CmdletBinding()]
        param (

        )
    
        begin {
    
        }
    
        process {
            

            
            $xml = @"
                <?xml version="1.0" encoding="UTF-8"?>
                <DefaultAssociations>
                <Association Identifier=".htm" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
                <Association Identifier=".html" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
                <Association Identifier=".pdf" ProgId="Acrobat.XDPDoc" ApplicationName="Adobe Acrobat" />
                <Association Identifier="http" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
                <Association Identifier="https" ProgId="ChromeHTML" ApplicationName="Google Chrome" />
                <Association Identifier="mailto" ProgId="Outlook.URL.mailto.15" ApplicationName="Outlook" />
                </DefaultAssociations>
                "@
            
        }
    
        end {
    
        }
    
    }