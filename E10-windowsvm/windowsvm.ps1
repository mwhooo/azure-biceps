#now we need global variables, that we can use across all the steps and use as input arguments for each of the bicep templates./
param(
    [Parameter(Mandatory=$true)] [string] $rg,
    [Parameter(Mandatory=$true)] [string] $virtualMachineName,
    [Parameter(Mandatory=$true)] [securestring]$pass
)

$networkInterfaceName  = "$virtualMachineName-nic"
$virtualNetworkId  = "/subscriptions/760948a0-7848-47ac-bcbf-5d1b60874700/resourceGroups/$rg/providers/Microsoft.Network/virtualNetworks/$rg" + "vnet"
$virtualMachineComputerName  = $virtualMachineName

$CWD = split-path $MyInvocation.MyCommand.Definition -Parent

if(!(Get-AzResourceGroup -Name $rg)){
    Write-Error "Could not find the RG name $rg"
    exit -1
}

$props = @{
    resourceGroupname = $rg
    networkInterfaceName = $networkInterfaceName
    virtualMachineName = $virtualMachineName
    virtualNetworkId = $virtualNetworkId
    virtualMachineComputerName = $virtualMachineComputerName
    adminPassword = $pass
    #adminUsername = "Robert"
    templatefile = "$CWD\windowsvm.bicep"
    mode = 'incremental'
    verbose = $true
}

Write-Output "deploying VM : $virtualMachineName"
New-AzResourceGroupDeployment @props

Invoke-AzVMRunCommand -ResourceGroupName $rg -vmname $virtualMachineName -ScriptPath "$CWD\chrome-install.ps1" -CommandId "RunPowershellScript"
