[cmdletbinding()]
param(
    [parameter(ValueFromPipeline)]
    $pipelineInput = $null,
    
    $inputfile = $null,
    
    $separator = ","
)

begin { 
    $time_array=@()
    }

process {
    
    if ($inputfile -ne $null){
        foreach ($line in (Get-Content $inputfile)) {
            $param=@{
                bed_time = $line.Split("$separator")[0]
                wakeup_time = $line.Split("$separator")[1]
            }
            $time_set = New-Object -TypeName PSObject -Property $param
            $time_array+=$time_set
        }
    } else {
            $param=@{
                bed_time = $_.Split("$separator")[0]
                wakeup_time = $_.Split("$separator")[1]
            }
            $time_set = New-Object -TypeName PSObject -Property $param
            $time_array+=$time_set
    }
}

end { 
    foreach ($line in $time_array) {
        $line.gettype()
         
    }
    ($time_array).GetType()
    $time_array
    }