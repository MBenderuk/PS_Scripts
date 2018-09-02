[cmdletbinding()]
param(
    [parameter(ValueFromPipeline)]
    $pipelineInput = $null,
    
    $ListOfHosts = $null
)

begin {
    ## initializing array 
    $HostList = @()

    ## set logfile dir, logfile name, create log file
    $logfile_path = "$PSScriptRoot"
    $logfile_name = (Get-Date -Format "dd-MM-yyyy") + "-start-remote-IIS.log"
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
}

process {

    if ($ListOfHosts -ne $null) {
        foreach ($line in (Get-Content $ListOfHosts)) {
            $HostList+=$line
        }
    } else {
        $HostList+=$_
    }

}

end {
    
    foreach ($node in $HostList) {

        if (Test-WsMan $node -ErrorAction Ignore) {
            
            log-events -severity INFO -message "Connecting to $node." -logfile_full_path $logfile_full_path
            
            if (Invoke-Command -ComputerName $node -ScriptBlock { Test-Path $env:systemdrive\inetpub }) {
                
                log-events -severity INFO -message "Copying site files." -logfile_full_path $logfile_full_path

                Copy-Item -Path $env:SystemDrive\inetpub\testsite -Destination $env:SystemDrive\inetpub\testsite2 -Recurse -Force `
                          -ToSession $(New-PSSession -ComputerName $node -Credential (Get-Credential))
            } else {
                log-events -severity ERROR -message "Directory $env:systemdrive\inetpub doesn't exist on $node." -logfile_full_path $logfile_full_path
            }
            
            log-events -severity INFO -message "Checking IIS server status." -logfile_full_path $logfile_full_path

            If (Invoke-Command -ComputerName $node -ScriptBlock { ((Get-Service W3SVC).Status -eq "Running") }) {
                
                log-events -severity INFO -message "Registering site in IIS." -logfile_full_path $logfile_full_path
                
                Invoke-Command -ComputerName $node -ScriptBlock { 
                    New-WebSite -Name TestSite -Port 10080  -PhysicalPath "$env:systemdrive\inetpub\testsite2" | Out-Null
                }

            } else {
                log-events -severity ERROR -message "IIS server is not running on host $node." -logfile_full_path $logfile_full_path
            }

        } else {
            log-events -severity ERROR -message "Can't connect to $node. WinRM service might be down." -logfile_full_path $logfile_full_path
        }
    }

    ($HostList).length
    
}


# show all sites hosted with IIS
#Get-Website

# Change port for Default Web Site from 80 to 1234
#Set-WebBinding -Name 'Default Web Site' -BindingInformation "*:80:" -PropertyName Port -Value 1234

# check which app is using port 80
#Get-NetTCPConnection -LocalPort 80

# get info for process with ID 1432
#Get-Process | where -Property Id -Match "1432" 

# get all commandlets for IIS server management
#Get-Command -Module WebAdministration

# start web app "Default Web Site"
#Start-Website -Name "Default Web Site"

# check IIS version
#(Get-ItemProperty -Path "$Env:WinDir\System32\inetsrv\w3wp.exe").VersionInfo.ProductVersion

# disable autostart for service IIS
#Set-Service W3SVC -StartupType Disabled

# stop IIS service 
#Stop-Service W3SVC