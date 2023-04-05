@secure()
param secretvalue string

param keyname string
param kv_name string

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: kv_name
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: keyname
  parent: kv
  properties: {
    value: secretvalue
  }
}
