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

//Enable ICMP (ping) on the VM by adding a Custom Script Extension that runs a PowerShell command to enable the appropriate firewall rule.

resource enablePing 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/enablePing'
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
        Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing'
        "
      '''
    }
  }
}

//Add Custom Script Extension to test network connectivity from the VM to a list of target IP addresses (which will be the private IPs of the other VMs). The script will run Test-NetConnection for each target and output the results to a text file on the VM.

resource networkTest 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: '${vmName}/networkTest'
  location: location
  dependsOn: [
    vm
    enablePing
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    settings: {
    commandToExecute: '''
      powershell -Command "
      $targets = @(${join(testTargets, ',')})
      $self = '${privateIp}'
      New-Item -Path C:\temp -ItemType Directory -Force
      foreach ($t in $targets) {
        if ($t -ne $self) {
          Test-NetConnection $t -Port 3389 | Out-File -Append C:\temp\network-test.txt
        }
      }"
      '''
    }
  }
}
