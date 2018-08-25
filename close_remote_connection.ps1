[CmdletBinding()]
    param (
    [switch]
    $CheckStatus
    )

function disable-WinRM {
    [CmdletBinding()]
    param (
    )

    if ((Get-Service WinRM).StartType -ne "Disabled") {
        try {
            Write-Host("Trying to set WinRM service StartType to Disabled...") -NoNewline
            Set-Service WinRM -StartupType Disabled
            Write-Host("DONE!")
        } catch {
            Write-Host("Error!")
            Write-Host("Error msg: " + $PSItem )
        }
    } else {
        Write-Host("Looks like WinRM service autostart is disabled!")
        Write-Host("Current service status:")
        Get-Service WinRM | select -Property Name, Status, StartType, DisplayName
    }
    
    if ((Get-Service WinRM).Status -eq "Running") {
        try {
            Write-Host("Trying to stop WinRM service...") -NoNewline
            Stop-Service WinRM
            Write-Host("DONE!")
        } catch {
            Write-Host("Error!")
            Write-Host("Error msg: " + $PSItem )
        }
    } else {
        Write-Host("Looks like WinRM service is not running!")
        Write-Host("Current service status:")
        Get-Service WinRM | select -Property Name, Status, StartType, DisplayName
    }
}

function delete-listeners {
    [CmdletBinding()]
    param (
    )
    if (((winrm enumerate winrm/config/listener)[1] -match ".*Address = *.*") -and 
        ((winrm enumerate winrm/config/listener)[2] -match ".*Transport = HTTP.*") -and 
        ((winrm enumerate winrm/config/listener)[3] -match ".*Port = 5985.*"))  {
        try {
            Write-Host("Trying to delete listener...") -NoNewline
            winrm delete winrm/config/listener?address=*+transport=HTTP
            Write-Host("DONE!")
        } catch {
            Write-Host("Error!")
            Write-Host("Error msg: " + $PSItem )
        }
    } else {
        Write-Host("No listeners found.")
        Write-Host("Current listeners status:")
        winrm enumerate winrm/config/listener
    }
}

function disable-firewall-rules {
    [CmdletBinding()]
    param (
    )
    if ((Get-NetFirewallRule | where -Property Name -Match ".*WINRM.*" | where -Property Enabled -Match "True" | measure).count -ne 0 ) {
        try {
            Write-Host("Trying to disable firewall rules...") -NoNewline
            Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -Enabled False
            Write-Host("DONE!")
        } catch {
            Write-Host("Error!")
            Write-Host("Error msg: " + $PSItem )
        }
    } else {
        Write-Host("Looks like firewall rules are disabled already.")
        Write-Host("Current firewall rules :")
        Get-NetFirewallRule | where -Property Name -Match ".*WINRM.*" | where -Property Enabled -Match "True" | select -Property Name, Description, Enabled
    }
}


Disable-PSRemoting

disable-firewall-rules

delete-listeners

disable-WinRM



#list status of powershell remote connections
#Get-PSSessionConfiguration | Format-Table -Property Name, Permission -Wrap

#get status of win rm service
#Get-Service WinRM

#stop winrm service
#Stop-Service WinRM

#disable autostart of winrm
#Set-Service WinRM -StartupType Disabled

#list listeners
#winrm enumerate winrm/config/listener
#(Get-ChildItem wsman:\localhost\listener).name

#delete listeners
#winrm delete winrm/config/listener?address=*+transport=HTTP

#list firewall rule
#Get-NetFirewallRule | where -Property Name -Match ".*WINRM.*" | where -Property Enabled -Match "True"
#(Get-NetFirewallRule | where -Property Name -Match ".*WINRM.*" | where -Property Enabled -Match "True").gettype()
#if ((Get-NetFirewallRule | where -Property Name -Match ".*WINRM.*" | where -Property Enabled -Match "True") -eq $null) {"it works"}

# disable firewall rule
#Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-NoScope -Enabled False