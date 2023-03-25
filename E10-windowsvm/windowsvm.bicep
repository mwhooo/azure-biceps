param location string = resourceGroup().location
param networkInterfaceName string = 'mbit2411wvm02-nic'
param enableAcceleratedNetworking bool = true
param subnetName string = 'subnet2'
param virtualNetworkId string = '/subscriptions/760948a0-7848-47ac-bcbf-5d1b60874700/resourceGroups/dev/providers/Microsoft.Network/virtualNetworks/dev_vnet'
param virtualMachineName string
param virtualMachineComputerName string
param adminUsername string = 'mark'

@secure()
param adminPassword string

var vnetId = virtualNetworkId
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
  }
  dependsOn: []
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      //vmSize: 'Standard_D2as_v5'
      vmSize: 'Standard_D2_v4'
    }
    storageProfile: {
      osDisk: {
        name: '${virtualMachineName}-os-disk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        // patchSettings: {
        //   enableHotpatching: true
        //   patchMode: 'AutomaticByPlatform'
        // }
      }
    }

    
  }
  
}

output adminUsername string = adminUsername
output ip string = reference(networkInterfaceName).ipConfigurations[0].properties.privateIPAddress

