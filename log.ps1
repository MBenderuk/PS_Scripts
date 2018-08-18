[cmdletbinding()]
    param ()

$logfile_path = "."
$logfile_name = (Get-Date -Format "dd-MM-yyyy") + "-test.log"
$logfile_full_path = $logfile_path + "\" + $logfile_name
if ((Test-Path -Path $logfile_full_path) -eq  $false) {
        New-Item -Name $logfile_full_path -ItemType file | Out-Null
    }

function log-events {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Validatescript({ test-path -path $_ })]
        [string]$logfile_full_path,
        [Parameter(Mandatory=$true)]
        [ValidateSet("DEBUG","INFO","WARNING","ERROR")]
        [string]$severity = "INFO", 
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    
    Add-content -Path $logfile_full_path -Value "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss.ffff") - $severity - $message"

    #write-verbose
    Write-Verbose "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss.ffff") - $severity - $message"

    #write-debug
    Write-Debug "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss.ffff") - $severity - $message"
}

log-events -logfile_full_path $logfile_full_path -severity INFO -message "this is a test message"
log-events -logfile_full_path $logfile_full_path -severity ERROR -message $($Error[0].InvocationInfo.PositionMessage)