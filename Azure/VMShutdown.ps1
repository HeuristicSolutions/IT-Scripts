$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Scripts\Logs\shutdown_$(get-date -f yyyyMM).log -append
Get-AzureVM
Stop-AzureVM -ServiceName "learningbuilder" -Name "learningbuilder" -Force | Format-Table
Stop-AzureVM -ServiceName "lbsql" -Name "lbsql" -Force | Format-Table
Get-AzureVM
Stop-Transcript
