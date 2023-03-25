#now we need global variables, that we can use across all the steps and use as input arguments for each of the bicep templates./
param(
    [Parameter(Mandatory=$true)] [string] $rg
)

switch ($rg) {
    'dev' {
        $subnetAddressPrefix = '10.0.7.0/26'
        $subnetAddressPrefixVpn = '10.0.8.0/26'
        $env1 = 'dev'
    }
    'acc'{
        $subnetAddressPrefix = '10.0.12.0/26'
        $subnetAddressPrefixVpn = '10.0.25.0/26'
        $env1 = 'acc'
    }
    'prd'{
        $subnetAddressPrefix = '10.0.52.0/26'
        $subnetAddressPrefixVpn = '10.0.65.0/26'
        $env1 = 'prd'
    }
    Default {
        Write-Error "could not determine value based on the rg value"
        exit -1
    }
}


$gw_name  = "mbit2411$rg`gw"
$deployName = "$($gw_name)-$(Get-date -format 'yyyy-MM-dd-hh-mm-ss')"
$gatewayType  = 'Vpn'
$sku = 'Basic'
$vpnGatewayGeneration = 'Generation1'
$existingVirtualNetworkName = "$rg" + "vnet"
$newPublicIpAddressName = "mbit2411$rg`pip"

#so now we need the basecert value here for the rootca, so we can pass that to the bicep and make is more dynamic.

$CWD = split-path $MyInvocation.MyCommand.Definition -Parent
if(!(Get-AzResourceGroup -Name $rg)){
    Write-Error "Could not find the RG name $rg"
    exit -1
}

#here we need the cert stuff and use the base64 value
$base64value = . "$CWD\cert-gw.ps1" -orgname mbit -CN "test"

$props = @{
    templatefile = "$CWD\vpngw-advanced.bicep"
    cert64code = $base64value
    gw_name = $gw_name
    env = $env1
    gatewayType = $gatewayType
    sku = $sku
    resourcegroupname = $rg
    vpnGatewayGeneration = $vpnGatewayGeneration
    existingVirtualNetworkName = $existingVirtualNetworkName
    subnetAddressPrefix = $subnetAddressPrefix
    newPublicIpAddressName = $newPublicIpAddressName
    subnetAddressPrefixVpn = $subnetAddressPrefixVpn
    verbose = $true
    #nameFromTemplate = $name
}

Write-Output "deploying GW $name"
New-AzResourceGroupDeployment @props -Name $deployName
