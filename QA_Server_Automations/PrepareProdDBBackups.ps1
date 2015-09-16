# Setup Logging
. ".\Logging_Functions.ps1"
$yearAndMonth = Get-Date -Format "yyyy_MM" #one file per month
$logFile = ".\PrepareProdDBBackups_$yearAndMonth.log"
Log-Start -LogFile $logFile


# Setup the configuration variables
$DbBackupDir = "C:\Data\Backups"
$DestinationDir = "C:\Data\Destination"


$dbDirs = Get-ChildItem $DbBackupDir

Foreach ($dir in $dbDirs){
	$dirName = $dir.FullName
    $latestFile = Get-ChildItem -Path $dirName | Sort-Object LastAccessTime -Descending | Select-Object -First 1

    Try {
        Copy-Item $latestFile.FullName $DestinationDir
        Log-Write -LogFile $logFile -LineValue "Copied $latestFile"
    }
    Catch {
        Log-Error -LogFile $logFile -ExitGracefully False -ErrorDesc $_.Exception.Message
    }
}

Log-Finish -LogFile $logFile

