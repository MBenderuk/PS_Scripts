[cmdletbinding()]
param(
    [parameter(ValueFromPipeline)]
    $pipelineInput = $null,
    
    $inputfile = $null,
    
    $separator = ","
)

# show all sites hosted with IIS
Get-Website

# Change port for Default Web Site from 80 to 1234
Set-WebBinding -Name 'Default Web Site' -BindingInformation "*:80:" -PropertyName Port -Value 1234

# check which app is using port 80
Get-NetTCPConnection -LocalPort 80

# get info for process with ID 1432
Get-Process | where -Property Id -Match "1432" 

# get all commandlets for IIS server management
Get-Command -Module WebAdministration

# start web app "Default Web Site"
Start-Website -Name "Default Web Site"

# check IIS version
(Get-ItemProperty -Path "$Env:WinDir\System32\inetsrv\w3wp.exe").VersionInfo.ProductVersion

# disable autostart for service IIS
Set-Service W3SVC -StartupType Disabled

# stop IIS service 
Stop-Service W3SVC