function Enable-DotNet {
    #Enables .Net 3.5
    Write-Host "[*] Checking .Net 3.5 Status..." -ForegroundColor Yellow
    $dotnet3 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 3 -and $_.Minor -eq 5}).Count -ge 1
    if ($dotnet3 -eq 'True') {
        Write-Host "[*] .Net 3.5 Enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Enabling .Net 3.5..." -ForegroundColor Yellow
        DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
        Write-Host "[*] .Net 3.5 Enabled" -ForegroundColor Green
    }
    Write-Host "[*] Checking .Net 4.8 Status..." -ForegroundColor Yellow
    $dotnet4 = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]} | Where-Object {$_.Major -eq 4 -and $_.Minor -eq 8}).Count -ge 1
    if ($dotnet4 -eq 'True') {
        Write-Host "[*] .Net 4.8 Enabled" -ForegroundColor Green
    }
    else {
        Write-Host "[*] Installing .Net 4.8..."
        Invoke-WebRequest "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe" -OutFile "C:\Setup Files\net48Installer.exe"
        Start-Process -FilePath "$scriptroot\net48installer.exe" -ArgumentList "/install /quiet /norestart"
    }
}