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

    function check-input {
        param( 
            #[string]$param_name,
            
            [System.Collections.ArrayList]$in_array
        )
        [System.Collections.ArrayList]$out_array=@()
        foreach ($item in $in_array) {
            try {
                [datetime]$item.bed_time = Get-Date $item.bed_time -Format "HH:mm"
                [datetime]$item.wakeup_time = Get-Date $item.wakeup_time -Format "HH:mm"
                $out_array += $item
            } catch {
                log-events -severity ERROR -message "$Error[0].Exception.ErrorRecord.Exception.Message. Skipping line $($in_array.IndexOf($item)). Please check input file!!!" -logfile_full_path $logfile_full_path
                #write-host("ERROR: line $($in_array.IndexOf($item)) - $param_name = $($item.$param_name). Check input file!!!")
            }
        }
        return $out_array
    }

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
    
    log-events -severity ERROR -message "************ Script START ************" -logfile_full_path $logfile_full_path

    $time_array = check-input -in_array $time_array #-param_name "bed_time"
    #check-input -in_array $time_array -param_name "wakeup_time"
    #$time_array = check-input -in_array $time_array -param_name "bed_time" 
    #$time_array = check-input -in_array $time_array -param_name "wakeup_time"

    calculate-sleep-time -in_array $time_array

    $time_array

    log-events -severity ERROR -message "************ Script END ************" -logfile_full_path $logfile_full_path
    }