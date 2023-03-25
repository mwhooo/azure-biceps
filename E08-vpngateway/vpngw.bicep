param name string = 'mbit2411devgw'
param location string = resourceGroup().location

@allowed([
  'Vpn'
  'ExpressRoute'
])
param gatewayType string = 'Vpn'
param sku string = 'Basic'
param vpnGatewayGeneration string = 'Generation1'

@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpnType string = 'RouteBased'
param subnetId string = '/subscriptions/760948a0-7848-47ac-bcbf-5d1b60874700/resourceGroups/dev/providers/Microsoft.Network/virtualNetworks/devvnet/subnets/GatewaySubnet'
param newPublicIpAddressName string = 'mbit2411devpip'

resource name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: name
  location: location
  tags: {}
  properties: {
    gatewayType: gatewayType
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: resourceId('dev', 'Microsoft.Network/publicIPAddresses', newPublicIpAddressName)
          }
        }
      }
    ]
    vpnType: vpnType
    vpnGatewayGeneration: vpnGatewayGeneration
    sku: {
      name: sku
      tier: sku
    }
  }
  dependsOn: [
    newPublicIpAddressName_resource
  ]
}

resource newPublicIpAddressName_resource 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: newPublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
