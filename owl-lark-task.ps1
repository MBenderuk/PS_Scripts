[cmdletbinding()]
param (
       $bed_time,
       $wakeup_time
)

############# Logging setup ################
## set logfile dir, logfile name, create log file
$logfile_path = "."
$logfile_name = (Get-Date -Format "dd-MM-yyyy") + "-WhoAmI.log"
$logfile_full_path = $logfile_path + "\" + $logfile_name
if ((Test-Path -Path $logfile_full_path) -eq  $false) {
        New-Item -Name $logfile_full_path -ItemType file | Out-Null
    }
## logging function
function log-events {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Validatescript({ test-path -path $_ })]
        [string]$logfile_full_path,
        [Parameter(Mandatory=$false)]
        [ValidateSet("DEBUG","VERBOSE","INFO","WARNING","ERROR")]
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

log-events -logfile_full_path $logfile_full_path -message " ************* Starting script. **************"

########## User input validation ############
## validating user input
log-events -logfile_full_path $logfile_full_path -message "Creating hashtable from user-provided data." 
$user_input = @{bed_time = $bed_time
                wakeup_time = $wakeup_time}
foreach($key in $user_input.keys.Clone()) { #iterating throught each element in the hashtable
    log-events -logfile_full_path $logfile_full_path -message "Starting user input validation loop."
    $exit=$false
    while ($exit -eq $false) { # won't proceed while user don't provide correct data
        try {
              log-events -logfile_full_path $logfile_full_path -message "Validating: $key = $($user_input[$key])"
              [datetime]$user_input[$key] = get-date $user_input[$key] -Format "HH:mm"
              log-events -logfile_full_path $logfile_full_path -message "User input seems valid. Creating DateTime object $key = $($user_input[$key])."
              $exit = $true # will exit loop once user input is OK.
        }
        catch {
                log-events -logfile_full_path $logfile_full_path -severity ERROR -message "Validation failed. Asking user to input correct data."
                Write-host("Looks like you have entered something wrong.")
                Write-Host("Parameter - {0}, entered value - "" {1} """ -f $key, $user_input[$key])
                $user_input[$key]= read-Host "Please enter $key using following format - (HH:mm)"
        }
    }
}
log-events -logfile_full_path $logfile_full_path -message "User input validaton loop finished."

########### Sleeping time calculations ############
## calculating how many hours user is sleepeing
log-events -logfile_full_path $logfile_full_path -message "Extracting data from hashtable."
log-events -logfile_full_path $logfile_full_path -message "Proceeding with such data:"
[datetime]$bed_time = $user_input["bed_time"]
log-events -logfile_full_path $logfile_full_path -message "`$bed_time = $bed_time"
[datetime]$wakeup_time = $user_input["wakeup_time"]
log-events -logfile_full_path $logfile_full_path -message "`$wakeup_time = $wakeup_time"
#createing a timespan object which will contain the ammount of time which user is sleepeing 
log-events -logfile_full_path $logfile_full_path -message "Calculating sleep time."
[timespan]$sleep_time = $bed_time.AddDays(-1).Ticks - $wakeup_time.Ticks
log-events -logfile_full_path $logfile_full_path -message "Sleep time is $sleep_time hours"
[int]$sleep_time = [Math]::Abs($sleep_time.Hours)
log-events -logfile_full_path $logfile_full_path -message "Absolute value of sleep time is $sleep_time"
log-events -logfile_full_path $logfile_full_path -message "Making ""owl-lakr"" decision."

############## lark-owl check logic ###############
## lark - wakeup_time less than 06:00
## owl - wakeup_time more than 09:00
if ($wakeup_time.Hour -le 6 ) { 
    write-host("Looks like you are a lark.") 
    log-events -logfile_full_path $logfile_full_path -message "User is a lark."
    }
elseif ($wakeup_time.Hour -ge 9 ) { 
    write-host("Looks like you are an owl.") 
    log-events -logfile_full_path $logfile_full_path -message "User is an owl."
    }
else { 
    write-host("Looks like you are normal human :)") 
    log-events -logfile_full_path $logfile_full_path -message "User is an ordinary human."
    }

#### check if user have enough sleep
log-events -logfile_full_path $logfile_full_path -message "Checking if user have enough sleep."
if ($sleep_time -ge 8 ) { 
    Write-Host("You have enough sleep. (" + $sleep_time + " hours this time.)") 
    log-events -logfile_full_path $logfile_full_path -message "User have enough sleep. ( $sleep_time hours this time.)"
    }
else { 
    Write-Host("You have NOT enough sleep. (" + $sleep_time + " hours this time.)") 
    log-events -logfile_full_path $logfile_full_path -message "User have NOT enough sleep. ( $sleep_time hours this time.)"
    }

log-events -logfile_full_path $logfile_full_path -message "*************** Script finished. ***************"

#script help
<#
.SYNOPSIS

writes whether the user is an owl or a lark depending on time when user goes to bed and wakes up at

.DESCRIPTION

Script calulates how many hours user sleeps based on -bed_time and -wakeup_time parameters passed to the script by user.
Also script writes whether the user is an owl or a lark based on same input parameters.

.PARAMETER bed_time
 
Time when user goes to sleep. Format: "HH:mm"

.PARAMETER wakeup_time

Time when user wakes up. Format: "HH:mm"

.EXAMPLE

.\task1-4.ps1 -bed_time 23:00 -wakeup_time 22:00

.Inputs

You cannot pipe input to this script.

.OUTPUTS

Few lines of text.

.NOTES
This is a script for task 1-4 of Pre_Prod_DevOps_2018_q3q4

.Link
No links.

#>