[cmdletbinding()]
param (
    $bed_time,
    $wakeup_time
)

## set logfile dir, logfile name, create log file
$logfile_path = "$PSScriptRoot"
$logfile_name = (Get-Date -Format "dd-MM-yyyy") + "-WhoAmI.log"
$logfile_full_path = $logfile_path + "\" + $logfile_name
if ((Test-Path -Path $logfile_full_path) -eq  $false) {
        New-Item -Path $logfile_path -Name $logfile_name -ItemType file | Out-Null
    }

############# Functions BEGIN ################

##### logging function
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

    #will do verbose output if "-Verbose" key is given
    Write-Verbose "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss.ffff") - $severity - $message"

    #will do verbose output if "-Verbose" key is given
    Write-Debug "$(Get-Date -Format "dd-MM-yyyy HH:mm:ss.ffff") - $severity - $message"
}

##### user input validation function
function validate-user-input {
    param (
        $param_to_validate,
        [string]$param_name
    )
    log-events -message "Starting user input validation loop." -logfile_full_path $logfile_full_path
        
    # won't proceed while user don't provide correct data
    for ($exit=$false; $exit -eq $false ) {
        try {
            log-events -message "Validating: $param_name = $param_to_validate" -logfile_full_path $logfile_full_path
                  
            [datetime]$param_to_validate = Get-Date $param_to_validate -Format "HH:mm"
                
            log-events -message "User input seems valid. Creating DateTime object $param_name = $param_to_validate."`
                       -logfile_full_path $logfile_full_path
                
            # will exit loop once user input is OK.
            $exit = $true 
        } catch {
            log-events -severity ERROR -message "Validation failed. Asking user to input correct data."`
                       -logfile_full_path $logfile_full_path
                    
            Write-Host("Looks like you have entered something wrong.")
            Write-Host("Parameter - {0}, entered value - "" {1} """ -f $param_name, $param_to_validate)
            $param_to_validate= Read-Host "Please enter $param_name using following format - (HH:mm) or Ctrl+C to exit"
        }
    }
    log-events -message "User input validaton loop finished." -logfile_full_path $logfile_full_path
    return $param_to_validate 
}

##### sleep time calculation function
function calculate-sleep-time {
    param (
        [datetime]$bed_time,
        [datetime]$wakeup_time
    )
    log-events -message "Calculating sleep time." -logfile_full_path $logfile_full_path 
    
    #creating a timespan object which will contain the ammount of time which user is sleepeing 
    [timespan]$sleep_time = $bed_time.AddDays(-1).Ticks - $wakeup_time.Ticks
    log-events -message "Sleep time is $sleep_time hours" -logfile_full_path $logfile_full_path
    
    [int]$sleep_time = [Math]::Abs($sleep_time.Hours)
    log-events -message "Absolute value of sleep time is $sleep_time" -logfile_full_path $logfile_full_path
    return $sleep_time
}

############# Functions END ################

log-events -message " ************* Starting script. **************" -logfile_full_path $logfile_full_path

########## User input validation BEGIN ############

$bed_time = validate-user-input -param_name "bed_time" -param_to_validate $bed_time
$wakeup_time = validate-user-input -param_name "wakeup_time" -param_to_validate $wakeup_time

########## User input validation END ############

########### Sleeping time calculations BEGIN ############

log-events -message "Proceeding with such data:" -logfile_full_path $logfile_full_path
log-events -message "`$bed_time = $bed_time" -logfile_full_path $logfile_full_path
log-events -message "`$wakeup_time = $wakeup_time" -logfile_full_path $logfile_full_path

$sleep_time = calculate-sleep-time -bed_time $bed_time -wakeup_time $wakeup_time

########### Sleeping time calculations END ############

############## lark-owl check BEGIN ###############
############## logic #################
## lark - wakeup_time less than 06:00
## owl - wakeup_time more than 09:00
######################################
log-events -message "Making ""owl-lark"" decision." -logfile_full_path $logfile_full_path 
if ($wakeup_time.Hour -le 6 ) { 
    write-host("Looks like you are a lark.") 
    log-events -message "User is a lark." -logfile_full_path $logfile_full_path 
    }
elseif ($wakeup_time.Hour -ge 9 ) { 
    write-host("Looks like you are an owl.") 
    log-events -message "User is an owl." -logfile_full_path $logfile_full_path
    }
else { 
    write-host("Looks like you are not an owl or lark.") 
    log-events -message "User is not an owl or lark." -logfile_full_path $logfile_full_path
    }
############## lark-owl check END ###############

############## check if user have enough sleep BEGIN ###############
log-events -message "Checking if user have enough sleep." -logfile_full_path $logfile_full_path
if ($sleep_time -ge 8 ) { 
    Write-Host("You have enough sleep. (" + $sleep_time + " hours this time.)") 
    log-events -message "User have enough sleep. ( $sleep_time hours this time.)" -logfile_full_path $logfile_full_path
    }
else { 
    Write-Host("You have NOT enough sleep. (" + $sleep_time + " hours this time.)") 
    log-events -message "User have NOT enough sleep. ( $sleep_time hours this time.)" -logfile_full_path $logfile_full_path
    }

log-events -message "*************** Script finished. ***************" -logfile_full_path $logfile_full_path

############## check if user have enough sleep END ###############

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
