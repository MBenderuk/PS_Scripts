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

function generate-junk-files {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    $PathToDir,

    [int]
    $NumberOfFiles = 5
    )
    
    for ($i=0; $i -lt $NumberOfFiles; $i++) {
        $FileName = "$(-join ((48..57) + (97..122) | Get-Random -Count 5 | foreach {[char]$_})).junk "
        $FullPath = $PathToDir + "\" + $FileName
        fsutil file createnew $FullPath ((1000..100000) | Get-Random -Count 1) | Out-Null
    }
}

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

switch($Unit) {            
    "B" {$CriticalSize = $CriticalSize }            
    "KB" {$CriticalSize = $CriticalSize * 1024 }            
    "MB" {$CriticalSize = $CriticalSize * 1024 * 1024}            
    "GB" {$CriticalSize = $CriticalSize * 1024 * 1024 * 1024}            
    "TB" {$CriticalSize = $CriticalSize * 1024 * 1024 * 1024 * 1024}            
}   

if ($GenerateJunk -eq $true) {
    generate-junk-files -PathToDir $PathToDir -NumberOfFiles 10
}
    
if ($CheckNow -eq $true) {
    del-dir-content -PathToDir $PathToDir -CriticalSize $CriticalSize
}



#get-dir-size -PathToDir $PathToDir
#generate-junk-files -PathToDir $PathToDir -NumberOfFiles 10


#[math]::round((Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum /1KB, 3) "KB"

#(Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum /1KB


