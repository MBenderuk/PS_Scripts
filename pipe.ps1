[cmdletbinding()]
param(
    [parameter(ValueFromPipeline)]
    $pipelineInput = $null,
    
    $inputfile = $null,
    
    $separator = ","
)

process {
    
    if ($inputfile -ne $null){
        $Object = New-Object -TypeName PSObject
        for ($i=0; $i -lt (Get-Content $inputfile).Split("$separator").Count; $i++) {
            Add-Member -InputObject $Object -MemberType NoteProperty -Name $i -Value (Get-Content $inputfile).Split("$separator")[$i]
        }
        $Object
    } else {
        foreach ($in in $pipelineInput) {
            $in.Split("$separator")
        }
    }
}