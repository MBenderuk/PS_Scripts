[cmdletbinding()]
param(
    [Parameter(Mandatory = $true)]
    $PathToDir,

    [Switch]
    $CheckNow = $false,

    [Switch]
    $GenerateJunk = $false
    )

function get-dir-size {
    [cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    $PathToDir
    )
    $dir_size = (Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum
    $dir_size = "$([math]::round($dir_size /1KB, 3)) KB"
    Write-Host("Size of $PathToDir is $dir_size")
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

if ($GenerateJunk -eq $true) {
    generate-junk-files -PathToDir $PathToDir -NumberOfFiles 10
}
    

get-dir-size -PathToDir $PathToDir
#generate-junk-files -PathToDir $PathToDir -NumberOfFiles 10


#[math]::round((Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum /1KB, 3) "KB"

#(Get-ChildItem $PathToDir -Recurse | Measure-Object -Sum Length).Sum /1KB


