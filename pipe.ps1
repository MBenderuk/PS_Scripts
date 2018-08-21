[cmdletbinding()]
param(
    [parameter(ValueFromPipeline)]
    $pipelineInput = $null,
    
    $inputfile = $null,
    
    $separator = ","
)

begin { 
    [System.Collections.ArrayList]$time_array=@()
    
    ## set logfile dir, logfile name, create log file
    $logfile_path = "$PSScriptRoot"
    $logfile_name = (Get-Date -Format "dd-MM-yyyy") + "-WhoAmI-Pipe-Input.log"
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
    ## this function will check input data
    function check-input {
        param( 
            [System.Collections.ArrayList]$in_array
        )
        [System.Collections.ArrayList]$out_array=@()
        foreach ($item in $in_array) {
            try {
                [datetime]$item.bed_time = Get-Date $item.bed_time -Format "HH:mm"
                [datetime]$item.wakeup_time = Get-Date $item.wakeup_time -Format "HH:mm"
                $out_array += $item
            } catch {
                log-events -severity ERROR -message "$PSItem. Skipping line $($in_array.IndexOf($item)). Please check input file!!!" -logfile_full_path $logfile_full_path
                #write-host("ERROR: line $($in_array.IndexOf($item)) - $param_name = $($item.$param_name). Check input file!!!")
            }
        }
        return $out_array
    }
    ## this function will calculate sleep time
    function calculate-sleep-time {
        param (
            [System.Collections.ArrayList]$in_array
        )
        
        foreach ($item in $in_array) {
            try {
                [timespan]$sleep_time = $item.bed_time.AddDays(-1).Ticks - $item.wakeup_time.Ticks
            } catch {
                log-events -severity ERROR -message "Line $($in_array.IndexOf($item)) - Can't calculate sleep time. Check input file!!!" -logfile_full_path $logfile_full_path
                #write-host("ERROR: line $($in_array.IndexOf($item)) - $param_name = $($item.$param_name). Check input file!!!")
            }
            [int]$sleep_time = [Math]::Abs($sleep_time.Hours)
            Add-Member -InputObject $item -NotePropertyName sleep_time -NotePropertyValue $sleep_time
        }
    }
    ## this function will check if there was enough time to sleep
    function had_enough-sleep-time {
        param (
            [System.Collections.ArrayList]$in_array
        )
        foreach ($item in $in_array){
            if ($item.sleep_time -ge 8 ) { 
                $enough_sleep_time = "Yes"
                Add-Member -InputObject $item -NotePropertyName had_enough_sleep_time? -NotePropertyValue $enough_sleep_time
            } else { 
                $not_enough_sleep_time = "NO"
                Add-Member -InputObject $item -NotePropertyName had_enough_sleep_time? -NotePropertyValue $not_enough_sleep_time
            }
        }
    }
    ## this function will do "lark-owl" check
    function lark-owl-check {
        param (
                [System.Collections.ArrayList]$in_array
            )
        foreach ($item in $in_array){
            if ($item.wakeup_time.Hour -le 6 ) { 
                $lark = "Lark"
                Add-Member -InputObject $item -NotePropertyName lakr_or_owl? -NotePropertyValue $lark
                }
            elseif ($item.wakeup_time.Hour -ge 9 ) { 
                $owl = "Owl"
                Add-Member -InputObject $item -NotePropertyName lakr_or_owl? -NotePropertyValue $owl
                }
            else { 
                $not_owl_or_lark = "Not Owl or Lark"
                Add-Member -InputObject $item -NotePropertyName lakr_or_owl? -NotePropertyValue $not_owl_or_lark
                }
        }
    } 
}

process {
    
    if ($inputfile -ne $null){
        foreach ($line in (Get-Content $inputfile)) {
            $param=[ordered]@{
                bed_time = $line.Split("$separator")[0]
                wakeup_time = $line.Split("$separator")[1]
            }
            $time_set = New-Object -TypeName PSObject -Property $param
            $time_array+=$time_set
        }
    } else {
            $param=[ordered]@{
                bed_time = $_.Split("$separator")[0]
                wakeup_time = $_.Split("$separator")[1]
            }
            $time_set = New-Object -TypeName PSObject -Property $param
            $time_array+=$time_set
    }
}

end { 
    
    log-events -severity INFO -message "************ Script START ************" -logfile_full_path $logfile_full_path

    $time_array = check-input -in_array $time_array 

    calculate-sleep-time -in_array $time_array

    had_enough-sleep-time -in_array $time_array

    lark-owl-check -in_array $time_array
    
    foreach ($line in $time_array) {
        $line.wakeup_time = Get-Date $line.wakeup_time -Format "HH:mm"
        $line.bed_time = Get-Date $line.bed_time -Format "HH:mm"
    }
    
    $time_array | Format-Table -AutoSize

    log-events -severity INFO -message "************ Script END ************" -logfile_full_path $logfile_full_path
    }

<#
.SYNOPSIS

writes whether the user is an owl or a lark depending on time when user goes to bed and wakes up at

.DESCRIPTION

Script takes input from pipeline or file and calulates how many hours user sleeps based on -bed_time and -wakeup_time parameters.
Also script writes whether the user is an owl or a lark based on same parameters.

.PARAMETER inputfile
 
Take with wakeup_time and bed_time defined as separate columns.

.PARAMETER separator

Specify character which separates columns in inputfile or piped input.

.EXAMPLE

Get-Content .\time.txt | .\pipe.ps1 -separator " "

.\pipe.ps1 -inputfile .\time.txt -separator " "

.Inputs

You can pipe input to this script.

.OUTPUTS

Few lines of text.

.NOTES

This is a script for task 1-7 of Pre_Prod_DevOps_2018_q3q4

.Link

No links.
#>