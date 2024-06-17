# Deployment Script
# by khemist
 "---------------------------"

$serial = wmic bios get serialnumber
$cpuInfo = Get-CimInstance -ClassName Win32_Processor
$cpuname = $cpuInfo.Name

Function Get-OSName
{
    (Get-WmiObject Win32_OperatingSystem).Caption
}
$osversion = Get-OSName

Function Infoheader {
  Write-Host "---------------------------"
  Write-Host ""
  Write-Host "     Deployment Script v0.1     "
  Write-Host "---------------------------" 
  }
