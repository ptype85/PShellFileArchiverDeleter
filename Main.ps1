###Stock FTP Cleaner
###peter.endacott@ivendi.com

$folders=@()
$currentDate = get-Date
$actionCount = 0


############EDITABLE VARIABLES############

###Log File
$logF = "C:\Test\FTPCleanLog.txt"

###VARIABLES
$archiveDays = 4 ###Age in days of files to be archived
$deleteDays = 15 ###Age in days of files to be deleted
$archiveFolderRoot = "C:\Test\FTPArchive\" ###Archive folder root. Files will be moved into a subdirectory named after original parent folder within this folder.

###specify the folders to crawl below
$folders = "C:\test\FTPTest\"

############END OF EDITABLE VARIABLES############

###FUNCTIONS
function archiveFile($fP, $fN, $fM){

    ##Get Variables
    $filePath = $fP
    $fileName = $fN
    $fileModi = $fM

    ##Move file to archive
    $archivePath = Split-Path (Split-Path -Path $filePath -Parent) -Leaf
    $archiveDestination = "$archiveFolderRoot$archivePath\"
    if(!(test-path $archiveDestination)){
        New-Item -ItemType directory -Path $archiveDestination
        "$currentDate Created new archive path: $archiveDestination" | Out-File -FilePath $logF -Append}
    Move-Item -Path "$filePath" -Destination "$archiveFolderRoot$archivePath\$fileName"

    ##Write action to log
    "$currentDate Archived $filePath to $archiveDestination. Modified date was $fileModi" | Out-File -FilePath $logF -Append

}

function deleteFile($fN, $fM){

    $fileName = $fN
    $fileModi = $fM
    Remove-Item -Force $fileName
    
    ##Write action to log
    "$currentDate Deleted $fileName. Modified date was $fileModi" | Out-File -FilePath $logF -Append
    }


###Archiver Loop
foreach($folder in $folders){
    $files = Get-ChildItem -Recurse -File $folder
        ForEach ($file in $files){
            $modified = $file.LastWriteTime #| select LastWriteTime
            $fileAge = New-TimeSpan -Start $modified -End $currentDate
                if ($fileAge.Days -gt $archiveDays){
                    $currFolder = $file.FullName
                    archiveFile $currFolder $_.Name $modified
                    $ActionCount ++
                              }
                                           }       
}

###Deleter Loop
Get-ChildItem -Recurse -File $archiveFolderRoot |
Foreach-Object {
    $modified = $_.LastWriteTime
    $fileAge = New-TimeSpan -Start $modified -End $currentDate
        if($fileAge.Days -gt $deleteDays){
        $currFolder = $_.FullName
        deleteFile $currfolder $modified
        $actionCount ++
        }
}

if ($actionCount -gt 0){
##Write action to log
    "$currentDate SFTPCleanup ran successfully and processed $actionCount files" | Out-File -FilePath $logF -Append
} else {##Write action to log
    "$currentDate SFTPCleanup ran successfully but found no applicable files" | Out-File -FilePath $logF -Append
    }
