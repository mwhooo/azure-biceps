resource storacc 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'mbit2411devst'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'None'
      ipRules: [
        {
          value: '1.1.1.1'
          action: 'Allow'
        }
      ]
    }

  }
}
