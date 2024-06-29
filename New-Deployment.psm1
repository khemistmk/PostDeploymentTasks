$Scripts = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "\scripts\*.ps1") -ErrorAction SilentlyContinue)

foreach ($Import in $Scripts) {
    try {
        Write-Verbose "Importing file: $($Import.FullName)"
        . $Import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_" -ErrorAction Stop
    }
}

foreach ($File in $Scripts) {
    Export-ModuleMember -Function $File.BaseName
}