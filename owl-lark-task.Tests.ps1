$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Params check" {
    It "checks if params are provided" {
        .\owl-lark-task.ps1 | Should Not Be "Looks like you have entered something wrong."
    }
}
