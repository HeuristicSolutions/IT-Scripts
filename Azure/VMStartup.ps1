$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Scripts\Logs\startup_$(get-date -f yyyyMM).log -append
Get-AzureVM
Write-Host "Starting learningbuilder"
Write-Host "------------------"
Start-AzureVM -ServiceName "learningbuilder" -Name "learningbuilder" | Format-Table
Write-Host "Starting lbsql"
Write-Host "------------------"
Start-AzureVM -ServiceName "lbsql" -Name "lbsql" | Format-Table
Get-AzureVM
Stop-Transcript
