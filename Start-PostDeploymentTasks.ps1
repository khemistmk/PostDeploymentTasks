Set-ExecutionPolicy Bypass

$OfficeVers = Read-Host "Select Office Version (O365, O365-32, OHBE21, OHBE21-32)"
$PDFVers = Read-Host "Select PDF Version (AdobeReader, Adobe2020, or FoxitBusiness)"
$SaveLocation = "$env:Userprofile\Documents"

Install-Module PostDeploymentTasks
Invoke-PostDeploymentTasks -InstallOfficeVers "$officevers" -InstallPDFVers "$PDFVersion" -SaveLocation "$SaveLocation"