param(
    #[Parameter(Mandatory)][securestring]$pass
    [Parameter(Mandatory)][string]$rg
)
$CWD = split-path $MyInvocation.MyCommand.Definition -Parent

New-AzResourceGroupDeployment -TemplateFile $CWD\resource-existing.bicep -Mode Incremental `
    -ResourceGroupName $rg -Verbose