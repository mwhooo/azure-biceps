param gw_name string
param location string = resourceGroup().location
param env string

@allowed([
  'Vpn'
  'ExpressRoute'
])
param gatewayType string
param sku string
param vpnGatewayGeneration string

@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpnType string = 'RouteBased'
param existingVirtualNetworkName string
param newSubnetName string = 'GatewaySubnet' //mandatory value for gw subnet.
param subnetAddressPrefix string
param subnetAddressPrefixVpn string
param newPublicIpAddressName string
param cert64code string

resource name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: gw_name
  location: location
  tags: {}
  properties: {
    gatewayType: gatewayType
    vpnClientConfiguration: {
      vpnClientRootCertificates: [
        {
          name: 'mbitroot' //name for the ROOT ca we used during cert creation, use the same CN or it will fail epicly during connection
          properties: {
            publicCertData: cert64code
          }
        }
      ]
      vpnClientAddressPool: {
        addressPrefixes: [
          subnetAddressPrefixVpn
        ]
      }
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {

          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('${env}', 'Microsoft.Network/virtualNetworks/subnets', existingVirtualNetworkName, newSubnetName)
          }
          publicIPAddress: {
            id: resourceId('${env}', 'Microsoft.Network/publicIPAddresses', newPublicIpAddressName)
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

resource existingVirtualNetworkName_newSubnetName 'Microsoft.Network/virtualNetworks/subnets@2019-04-01' = {
  name: '${existingVirtualNetworkName}/${newSubnetName}'
  location: location
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}

resource newPublicIpAddressName_resource 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: newPublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
