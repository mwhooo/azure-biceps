param tenantid string = '2fb48667-a461-4cef-aa62-9a8ae4307b8f'
param objectId string = 'c04a1b8b-60e2-44c5-b9ff-512e1ade8c6b'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' existing = {
  name: 'mbit2411devst'
  scope: resourceGroup('dev')
}

resource kv 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: 'mbit2411-dev-kv01'
  scope: resourceGroup('dev')
}

resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' existing ={
  name: 'secret2'
  parent: kv
}

resource kv1 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: 'mbit2411-acc-kv01'
  location: resourceGroup().location
  properties: {
    sku: {
      //family: 'A'
      family: kv.properties.sku.family
      //name: 'standard'
      name: kv.properties.sku.name
    }
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
    tenantId: tenantid
  }
}


output blobEndpoint string = stg.properties.primaryEndpoints.blob
output kv_name string = kv.name
output secr_uri string = secret2.properties.secretUri
output kv1_name string = kv1.name

