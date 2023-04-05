param(
    [Parameter(Mandatory)][securestring]$pass
)
New-AzResourceGroupDeployment -TemplateFile .\E07-keyvault-creation\keyvault.bicep -Mode Incremental `
    -ResourceGroupName dev -Verbose -pass $pass