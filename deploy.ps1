# Deployment Script
# by khemist
#
# ---------------------------
#
#This script will perform the following actions under the default profile:
# * check and Set computer name to serial number
# * check activation and activate windows based on OEM bios key
# * install and run System Update if Lenovo
# * run windows updates
# * run Ninite to install Chrome, Firefox, and VLC
# * activate bitlocker and print bitlocker key to file
# * install .Net 3.5
# * uninstall SmartDeploy
# * remove Deployment folders



Function Infoheader {
  Write-Host "---------------------------"
  Write-Host ""
  Write-Host "     Deployment Script v0.1     "
  Write-Host "---------------------------" 
  }


$serialnumber = wmic bios get serialnumber
$product key = wmic path softwarelicensingservice get OA3OriginalProductKey

$cpuInfo = Get-CimInstance -ClassName Win32_Processor

$cpuname = $cpuInfo.Name

Function Get-OSName
{
   $osversion = (Get-WmiObject Win32_OperatingSystem).Caption
   write-output "$osversion"
}
