function Set-StartMenuTemplate {
    [cmdletbinding()]
    param (
        [Parameter()]
        [string]$startbin = "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\\start.bin",

        [Parameter()]
        [string]$start2bin = "$((Get-Item $PSScriptRoot).Parent.FullName)\Assets\\start2.bin"
    )
    begin {
        $defaultstartpath = "C:\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
    }
    process {
        Create default 
        New-Item -ItemType Directory -Force -Path $defaultstartpath | Out-Null
        #Copies template start.bin  
        Copy-Item -path $startbin -Destination $defaultstartpath
        Copy-Item -path $start2bin -Destination $defaultstartpath
    }
    end {

    }
}