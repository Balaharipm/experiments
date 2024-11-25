param location string
param project string
param webappzoneid string
param vnetname string
param fnapps array
param fnappmap object
param lawid string
param logstorageaccountid string
param storageaccountname string
param appinsightsconnstring string
param createdbyemail string
param createddate string
param environment string
param customername string
param businesscriticality string
param dataclassification string

//Get reference to the created vnet to use for vnet integration
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetname
}

//Get reference to the storage account to set connection string in app settings
//and to create file shares for the function apps
resource st 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageaccountname
}
var ConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=core.windows.net;AccountKey=${listKeys(st.id, st.apiVersion).keys[0].value}'

//Create the app service plan for each function app in list (fhirfapp, aiagentlistener)
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = [for fnapp in fnapps:{
  name: '${project}-${environment}-${fnapp}-asp'
  location: location
  kind: 'elastic'
  tags:{
    Description: fnappmap[fnapp].Description
    CreatedBy: createdbyemail
    CreatedDate: createddate
    Region: location
    BusinessCriticality: businesscriticality
    Environment: environment
    CustomerName: customername
    DataClassification: dataclassification
  }
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
  }
  properties: {
    reserved: (fnappmap[fnapp].LinuxFxVersion == '')?false:true
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}]


//Create the function app for each function app in list (fhirfapp, aiagentlistener)
resource functionApp 'Microsoft.Web/sites@2023-01-01' = [for (fnapp,i) in fnapps:{
  name: '${project}-${environment}-${fnapp}'
  location: location
  tags:{
    Description: fnappmap[fnapp].Description
    CreatedBy: createdbyemail
    CreatedDate: createddate
    Region: location
    BusinessCriticality: businesscriticality
    Environment: environment
    CustomerName: customername
    DataClassification: dataclassification
  }
  kind: fnappmap[fnapp].kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan[i].id
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: fnappmap[fnapp].linuxFxVersion
      windowsFxVersion: fnappmap[fnapp].WindowsFxVersion
    }
    virtualNetworkSubnetId: (filter(vnet.properties.subnets, subnet => contains(subnet.name,'${project}-${fnapp}-vnetintegration-snet')))[0].id
  }
}]

//Create the app settings for each function app in list (fhirfapp, aiagentlistener)
resource fnappappsettings 'Microsoft.Web/sites/config@2022-09-01' = [for (fnapp,i) in fnapps:{
  name: 'appsettings'
  kind: 'string'
  parent: functionApp[i]
  properties: { 
    AzureWebJobsStorage: ConnectionString
    APPLICATIONINSIGHTS_CONNECTION_STRING: appinsightsconnstring
    FUNCTIONS_EXTENSION_VERSION : '~4'
    //The following three value need to be set after the function app is created
    // to allow for connection to the storage account
    //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: ConnectionString
    //WEBSITE_CONTENTSHARE: fnapp
    //WEBSITE_CONTENTOVERVNET: '1'
    FUNCTIONS_WORKER_RUNTIME: (fnapp == 'fhirfapp') ?'dotnet-isolated' : 'python' //python for aiagentlistener
    WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED: (fnapp == 'fhirfapp') ?'1' : '0'
    WEBSITE_RUN_FROM_PACKAGE: '1'
    WEBSITE_FUNCTIONS_ARMCACHE_ENABLED: 'false'
}
}]

resource pvtendpoint 'Microsoft.Network/privateEndpoints@2023-06-01' = [for (fnapp,i) in (fnapps):{
  name: '${fnapp}-pvtep'
  dependsOn: [functionApp[i]]
  tags:{
    CreatedBy: createdbyemail
    CreatedDate: createddate
    Region: location
    BusinessCriticality: businesscriticality
    Environment: environment
    CustomerName: customername
    DataClassification: dataclassification
  }
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${fnapp}-pvtep'
        properties: {
          privateLinkServiceId: functionApp[i].id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${fnapp}-pvtep-nic'
    subnet: {
      id: (filter(vnet.properties.subnets, subnet => contains(subnet.name,'${project}-fnapp-snet')))[0].id
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}]

resource pvtendpoint_pvtdnszonegroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-06-01' = [for (fnapp,i) in fnapps: {
  parent: pvtendpoint[i]
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: webappzoneid
        }
      }
    ]
  }
}]


resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (fnapp,i) in (fnapps):{
  name: fnapp
  scope: functionApp[i]
  properties: {
    workspaceId: lawid
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    metrics:[
      {
        timeGrain: null
        enabled: true
        category: 'AllMetrics'
      }
    ]
    storageAccountId: logstorageaccountid
  }
}]

resource defaultFileShareService 'Microsoft.Storage/storageAccounts/fileServices@2023-04-01' existing = {
  name: 'default' // this was created previously in hte storage account bicep file. Hence using existing
  parent: st
}
// Create file shares for each function app in list (fhirfapp, aiagentlistener)
resource fileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = [for (fnapp, i) in fnapps: {
  name: '${project}-${environment}-${fnapp}'
  parent: defaultFileShareService
  properties: {
    shareQuota: 1024
  }
}]
