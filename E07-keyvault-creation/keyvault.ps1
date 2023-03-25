param(
    [Parameter(Mandatory)][securestring]$pass
)
New-AzResourceGroupDeployment -TemplateFile .\keyvault.bicep -Mode Incremental `
    -ResourceGroupName dev -Verbose -pass $pass