#=========================================================================================================================
#As of Feb 21st, these items are still setup to simulate the events. 
# Please review lines 26, 56, & 100
# If the line does not end with Remove-Item -WhatIf then DO NOT RUN IT as it will actually delete/archive files
#=========================================================================================================================


$Now = Get-Date
$Days = "7" # Change this number to increase or decrease the number of days to be retained.
$LastWrite = $Now.AddDays(-$Days)
$currdate = Get-Date -format "ddMMyyyy"
$scriptPath = "C:\tools\System Maintenance\Logs\$Currdate.log"
$logdate = Get-Date -format "yyyy-MM-dd hh:mm:ss"

# This Function will delete the IIS Logs
Function Delete-IISLogs {

$TargetFolder = (Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory).Value
$TargetFolder = $TargetFolder -replace '%SystemDrive%','C:'
$logdate = Get-Date -format "yyyy-MM-dd hh:mm:ss"
$LogCount = (Get-ChildItem -Path $TargetFolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $LastWrite }).Count
$LogSize = foldersize $TargetFolder

Add-Content -Path $scriptPath -Value "     Deleted $LogCount files totalling $logSize from $TargetFolder at $logdate***" -Force

Get-ChildItem -Path $TargetFolder -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $LastWrite } |  Remove-Item  -WhatIf

Start-Sleep -Milliseconds 100
}


#This Function will delete the items in the Client Staging Upload folders.
Function Delete-StagingUploads {
$maindir = @()
$Websites = Get-ChildItem IIS:\Sites 
 foreach ($site in $Websites) {
        $path = $site.physicalPath
        If ( $path.IndexOf('prod') -gt 0) {
            $dirPath = $path.Substring(0, $path.IndexOf('prod')+4) 
            $dirCheck = $dirPath + '\web_private\uploads\staging'
            If (Test-Path $dirCheck) {
                $mainDir += $dirCheck
                }
            Else {    
                $last_index = $path.LastIndexOf('web')
                $mainDir += $path.Remove($last_index, 3).Insert($last_index, 'web_private\uploads\staging')
         }
      
}}
foreach ($dir in $mainDir) {
    $logdate = Get-Date -format "yyyy-MM-dd hh:mm:ss"
    $LogCount = (Get-ChildItem -Path $dir -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $LastWrite }).Count
    $LogSize = foldersize $TargetFolder
    $LogInput = "   Deleted $LogCount files from $dir at $logdate"
   
    Get-ChildItem -Path $dir -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $LastWrite } |  Remove-Item  -WhatIf
   
    Add-Content -Path $scriptPath -Value $LogInput -Force
    Start-Sleep -Milliseconds 100
 }
}

#This function goes through the maintenance archive folders for each client and archives any file over 7 days old and then deletes it.
Function Archive-MaintFiles {
$Websites = Get-ChildItem IIS:\Sites 
    foreach ($site in $Websites) {
        $path = $site.physicalPath
        $last_index = $path.LastIndexOf('web')
        if( $last_index -gt 0){
            $path = $path.Remove($last_index, 3).Insert($last_index, 'tools\maintenance\Archive')
           }
        $zipFilename = "ArchiveFiles.zip"
        $zipFile = $path +'\' + $zipFilename
        #Check if there are files to archive
        $LogCount = (Get-ChildItem -Path $path -Recurse -Force | Where-Object {!$_.PSIsContainer -and $_.CreationTime -lt $LastWrite -and $_.Extension -ne ".zip"}).Count
        If ($LogCount -ge 1) {
            #Prepare zip file
            if(-not (test-path($zipFile))) {
                set-content $zipFile ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
                (dir $zipFile).IsReadOnly = $false  
            }

            $shellApplication = new-object -com shell.application
            $zipPackage = $shellApplication.NameSpace($zipFile)
            #Get files to Archive
            $logdate = Get-Date -format "yyyy-MM-dd hh:mm:ss"
            $LogInput = "$LogCount files from $path added to Archive $zipFile and deleted at $logdate"
            $files = Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $LastWrite -and $_.Extension -ne ".zip"}
        
         #Add each file to the archive
            foreach($file in $files) { 
                $zipPackage.CopyHere($file.FullName)
                #using this method, sometimes files can be 'skipped'
                #this 'while' loop checks each file is added before moving to the next
                    while($zipPackage.Items().Item($file.name) -eq $null){
                        Start-sleep -milliseconds 500
                    }
            }
            #This removes the files after we have adding them to the Archive
            Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $LastWrite } |  Remove-Item  -Whatif

            Add-Content -Path $scriptPath -Value $LogInput -Force
            Start-Sleep -Milliseconds 100

            
        }
     }
}
# Used to get size of files
Function folderSize  {
    try
        {
            $colItems = ((Get-ChildItem -Path $arg -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $LastWrite })| Measure-Object -property length -sum)
            $sizeDir = "{0:N2}" -f ($colItems.sum / 1MB) + " MB"
        }
    catch
        {
            $sizeDir = "0.00 MB"
        }
return $sizeDir
}
# MAIN CALLS

#Add new entry to Log (creates log if it doesnt already exist
Add-Content -Path $scriptPath -Value "*** Cleanup stated at $logdate ***" -Force
Delete-IISLogs
Delete-StagingUploads
Archive-MaintFiles

$logdate = Get-Date -format "yyyy-MM-dd hh:mm:ss"
Add-Content -Path $scriptPath -Value "*** Cleanup completed at $logdate ***" -Force
