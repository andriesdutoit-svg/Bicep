param vmName string
param vnetName string
param vmSize string
param adminUsername string
@secure()
param adminPassword string
param tags object = {}
param image object
param osDisk object
param privateIp string
param testTargets array
param location string

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${vmName}-nic'
  location: resourceGroup().location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
               vnetName,
                '${vnetName}-subnet-default')
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: resourceGroup().location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: image
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDisk.storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

//Enable ICMP (ping) and test network connectivity.

resource vmScript 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/vmScript'
  location: location
  dependsOn: [
    vm
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
      commandToExecute: '''
powershell -Command "
Start-Sleep -Seconds 60

# Enable ping
Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing'

# Network test
$targets = '${join(testTargets, ',')}'
$targets = $targets.Split(',')
$self = '${privateIp}'

New-Item -Path C:\temp -ItemType Directory -Force

foreach ($t in $targets) {
  if ($t -ne $self) {
    Test-NetConnection $t -Port 3389 | Out-File -Append C:\temp\network-test.txt
  }
}
"
'''
    }
  }
}
