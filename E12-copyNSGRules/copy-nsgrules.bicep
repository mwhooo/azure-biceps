param source_rg string = 'dev'
param source_nsg_name string = 'vm_nsg'
param source_rule_name string = 'AllowCidrBlockCustom8080Inbound'
var source_full_name = '${source_nsg_name}/${source_rule_name}'

//nsg rule from DEV RG
resource nsg 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' existing = {
  name: source_full_name
  scope: resourceGroup(source_rg)
}

//applying new rule on ACC based on the DEV rule.
resource nsg2 'Microsoft.Network/networkSecurityGroups/securityRules@2022-09-01' = {
  name: nsg.name //happens to be the same name on all my env, change if that is not that base, or make input param for it.
  properties: {
    access: nsg.properties.access
    direction: nsg.properties.direction
    protocol: nsg.properties.protocol
    sourcePortRange: nsg.properties.sourcePortRange
    sourceAddressPrefix: nsg.properties.sourceAddressPrefix
    destinationPortRange: nsg.properties.destinationPortRange
    destinationAddressPrefix: nsg.properties.destinationAddressPrefix
    priority: nsg.properties.priority
  }
}
//comment
