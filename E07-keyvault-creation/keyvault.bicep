param kvname string
param location string = resourceGroup().location
param tenantid string = '2fb48667-a461-4cef-aa62-9a8ae4307b8f'
param objectId string = 'c04a1b8b-60e2-44c5-b9ff-512e1ade8c6b'

// @secure()
// param pass string

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: kvname
  location: location
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '1.2.3.4/32'
        }
      ]
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantid
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantid
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
      {
        objectId: objectId
        tenantId: tenantid
        permissions: {
          certificates: [
            'all'
          ]
        }
      }
      {
        objectId: objectId
        tenantId: tenantid
        permissions: {
          keys: [
            'create'
            'delete'
            'get'
            'recover'
          ]
        }
      }
    ]
  }
}

resource secret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: kv
  name: 'adminpass'
  properties: {
    value: 'Mark35'
  }
}

resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: kv
  name: 'secret2'
  properties: {
    value: 'doesnot matter much'
  }
}


