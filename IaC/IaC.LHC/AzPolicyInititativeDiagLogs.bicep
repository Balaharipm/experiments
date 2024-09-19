targetScope = 'managementGroup'

resource centralLAW 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  scope: resourceGroup('5e60a394-1eaf-441d-9c3c-868c5c891187','mis')
  name: 'gzn-sentinel'

}

resource logmonPolicySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name:'logging-monitoring-policy-set'
  scope: managementGroup()
  properties:{
    displayName:'Logging and Monitoring Policy Set'
    policyType:'Custom'
    metadata:{
      category:'Monitoring'
    }
    policyDefinitions:[
      {
        policyDefinitionId: managementGroupResourceId('Microsoft.Authorization/policyDefinitions','26b16f13-6da9-4ba0-bf8b-07f859066b90')
        parameters:{
          logAnalytics:{
              value: centralLAW.id
          }
    }
      }
    ]
  }
}

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'logmonpolicyassn'
  location: 'eastus2'
  identity:{
      type: 'SystemAssigned'
  }
  properties:{
    displayName:'Deploy diagnostic settings to workspace assignment'
    policyDefinitionId:logmonPolicySetDefinition.id

  }
}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managementGroup().id,'logmonpolicy', 'Contributor')
  scope: managementGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: policyAssignment.identity.principalId
  }
}
