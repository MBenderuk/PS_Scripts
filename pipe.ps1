[cmdletbinding()]
param(
    [parameter(ValueFromPipeline)]
    $pipelineInput = $null,
    
    $inputfile = $null,
    
    $separator = ","
)

begin { $line_number=0 }

process {
    
    if ($inputfile -ne $null){
        $Object = New-Object -TypeName PSObject
        #for ($i=0; $i -lt (Get-Content $inputfile).Split("$separator").Count; $i++) {
            Add-Member -InputObject $Object -MemberType NoteProperty -Name $i -Value (Get-Content $inputfile).Split("$separator")[$i]
        #}
        $Object
    } else {
        $time_array=@()
        #$time_set = New-Object -TypeName PSObject
        foreach ($in in $pipelineInput) {
            $param=@{
                line_number = $line_number
                bed_time = $in.Split("$separator")[0]
                wakeup_time = $in.Split("$separator")[1]
            }
            $time_set = [pscustomobject]$param
            $time_array+=[pscustomobject]$time_set
        }
    }
    
    $time_array
    #$time_array | where -Property wakeup_time -eq 05:00 | select wakeup_time | Format-Table -HideTableHeaders
    
    #foreach ($line in $time_array[0].wakeup_time) {
    #    $line + "- line"
    #}
    #$time_array.length
    $i++
}