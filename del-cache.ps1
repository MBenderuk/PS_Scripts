[cmdletbinding()]
param(
    [Parameter(Mandatory = $true)]
    $PathToDir,

    [Switch]
    $CheckNow = $false,

    [Switch]
    $GenerateJunk = $false,

    [validateset("B","KB","MB","GB","TB")]            
    [string]
    $Unit,

    [double]
    $CriticalSize
    )

## set logfile dir, logfile name, create log file
$logfile_path = "$PSScriptRoot"
$logfile_name = (Get-Date -Format "dd-MM-yyyy") + "-clear-cache.log"
$logfile_full_path = $logfile_path + "\" + $logfile_name
if ((Test-Path -Path $logfile_full_path) -eq  $false) {
    New-Item -Path $logfile_path -Name $logfile_name -ItemType file | Out-Null
    }
    
## this function will log events in file
function log-events {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("DEBUG","INFO","WARNING","ERROR")]
        [string]$severity = "INFO", 

        [Parameter(Mandatory=$true)]
        [string]$message,

        [Parameter(Mandatory=$true)]
        [Validatescript({ test-path -path $_ })]
        [string]$logfile_full_path
    )
        Add-content -Path $logfile_full_path `
                    -Value "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss.ffff") - $severity - $message"
    }
## this function will get size of dir content in bytes
function get-dir-size {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    $PathToDir
    )
    $DirSize = (Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum
    #$DirSize = "$([math]::round($DirSize /1KB, 3)) KB"
    #Write-Host("Size of $PathToDir is $dir_size")
    return $DirSize
}
## this is a test function. will generate "junk" files in specified directory.
function generate-junk-files {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    $PathToDir,

    [int]
    $NumberOfFiles = 5
    )
    
    log-events -severity INFO -message "Starting to generate JUNK-files." -logfile_full_path $logfile_full_path

    for ($i=0; $i -lt $NumberOfFiles; $i++) {
        $FileName = "$(-join ((48..57) + (97..122) | Get-Random -Count 5 | foreach {[char]$_})).junk "
        $FullPath = $PathToDir + "\" + $FileName
        fsutil file createnew $FullPath ((1000..100000) | Get-Random -Count 1) | Out-Null
    }

    log-events -severity INFO `
               -message "Finished generating JUNK-files. $NumberOfFiles file(s) generated. Total size of generated files is $(get-dir-size -PathToDir $PathToDir) Bytes." `
               -logfile_full_path $logfile_full_path
}
## this function will delete contents of specified directory
function del-dir-content {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    $PathToDir,

    [int]
    $CriticalSize
    )
    if ((get-dir-size -PathToDir $PathToDir) -gt $CriticalSize) {
        Write-Host("Directory was cleaned! Removed - $(get-dir-size -PathToDir $PathToDir) Bytes.")
        Remove-Item -Path "$PathToDir\*.junk" 
    } else {
        Write-Host("Nothing to delete! Directory size - $(get-dir-size -PathToDir $PathToDir) Bytes. Critical size - $CriticalSize Bytes.")
    }
}

log-events -severity INFO -message "************** Script START **************" -logfile_full_path $logfile_full_path

## convert threshold provided by user from "KB", "MB", "GB", "TB" to bytes
switch($Unit) {            
    "B" {$CriticalSize = $CriticalSize }            
    "KB" {$CriticalSize = $CriticalSize * 1024 }            
    "MB" {$CriticalSize = $CriticalSize * 1024 * 1024}            
    "GB" {$CriticalSize = $CriticalSize * 1024 * 1024 * 1024}            
    "TB" {$CriticalSize = $CriticalSize * 1024 * 1024 * 1024 * 1024}            
}   

if ($GenerateJunk -eq $true) {
    generate-junk-files -PathToDir $PathToDir -NumberOfFiles 10
    
    break
}
    
if ($CheckNow -eq $true) {
    del-dir-content -PathToDir $PathToDir -CriticalSize $CriticalSize
    break
}

while ($true) {
    Get-Date
    del-dir-content -PathToDir $PathToDir -CriticalSize $CriticalSize
    Write-Host("Sleepeng for 60 seconds. Press Ctrl+C to stop script.")
    sleep 60
}

log-events -severity INFO -message "************** Script End **************" -logfile_full_path $logfile_full_path

#get-dir-size -PathToDir $PathToDir
#generate-junk-files -PathToDir $PathToDir -NumberOfFiles 10


#[math]::round((Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum /1KB, 3) "KB"

#(Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum /1KB


