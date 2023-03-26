param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'devvnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/21'
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vnet
  name: 'subnet1'
  properties: {
    addressPrefix: '10.0.4.0/24'
    networkSecurityGroup: {
      id: nsg1.id
    }
  }
}

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vnet
  name: 'subnet2'
  dependsOn: [
    subnet1
  ]
  properties: {
    addressPrefix: '10.0.5.0/24'
    networkSecurityGroup: {
      id: nsg2.id
    }
  }
}

resource gwsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vnet
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: '10.0.6.0/26'
  }
}

resource nsg1 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  location: location
  name: 'nsg1'
}

resource nsg2 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  location: location
  name: 'nsg2'
}

