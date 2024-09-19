param location string
param vhdUri string = 'https://downloads.horizon3ai.com/images/NodeZero-1701112882.vhd'

param adminUsername string
@secure()
param adminPassword string

@allowed([
  'dev'
  'tst'
  'stg'
  'prd'
])
param environmentType string
param project string
var rgname = '${environmentType}-${project}-rg'
var vmname = '${environmentType}-${project}-nodezero'
var vnetname = '${environmentType}-${project}-vnet'
var nicname = '${environmentType}-${project}-nodezero-nic'

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope:subscription(subscription().subscriptionId)
  name: rgname
}

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  scope: resourceGroup(resourcegroup.name)
  name: vnetname
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: virtualnetwork
  name: 'snet-vm'
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
           id:subnet.id
          }
        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      osDisk: {
        osType: 'Linux'
        name: 'osdisk'
        createOption: 'FromImage'
        image: {
          uri: vhdUri
        }
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 40
      }
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminUsername
      adminPassword:adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkinterface.id
        }
      ]
    }
    securityProfile:{
      encryptionAtHost: true
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}
