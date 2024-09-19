param location string
param adminusername string
param snetname string
param vnetname string
@secure()
param password string
param rgname string
param vmname string
var nicname = '${vmname}-nic'

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope:subscription(subscription().subscriptionId)
  name: rgname
}
resource networkresourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope:subscription(subscription().subscriptionId)
  name: 'LhcNetworkRG'
}
resource virtualnetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(resourcegroup.name)
  name: vnetname
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: virtualnetwork
  name: snetname
}

resource networkinterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: nicname
  location: location
  properties:{
    ipConfigurations:[
      {
        name:'ipconfig1'
        properties:{
          privateIPAllocationMethod: 'Dynamic'
          subnet:{
          id: resourceId(networkresourcegroup.name, 'Microsoft.Network/virtualNetworks/subnets', vnetname , snetname)
          name: subnet.name
          }
        }
      }
    ]
  }
}

resource windowsServer 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v5'
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminusername
      adminPassword: password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vmname}-disk-os'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: 128
        osType:'Windows'
      }
      
    }
    
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface.id
        }
      ]
    }
  }
}


