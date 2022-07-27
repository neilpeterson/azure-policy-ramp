param AdminUserName string
@secure()
param AdminPassword string
param VMName string
param location string = resourceGroup().location
param random string = uniqueString(resourceGroup().id)
param signCert string = 'https://azurepolicycdef.blob.core.windows.net/guestconfiguration/GCPublicKey.cer?sp=r`&st=2022-07-27T18:27:19Z`&se=2023-07-28T02:27:19Z`&spr=https`&sv=2021-06-08`&sr=b`&sig=wDj8u366WPvg5J5713EIJrKZfRZsjr%2Bv4bjYALlR9bk%3D'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: random
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: random
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: VMName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'name'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetwork.id}/subnets/${random}'
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: VMName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: VMName
    }
  }
}

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: VMName
  location: location
  identity: {
     type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D3_v2'
    }
    osProfile: {
      computerName: VMName
      adminUsername: AdminUserName
      adminPassword: AdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: VMName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource windowsVMGuestConfigExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'AzurePolicyforWindows'
  parent: windowsVM
  location: location
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource singingCertificate 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if (!empty(signCert)) {
  name: 'singingCertificate'
  parent: windowsVM
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      commandToExecute: 'powershell.exe Invoke-WebRequest "${signCert}" -OutFile c:\\cert.cer && powershell.exe Import-Certificate -FilePath c:\\cert.cer -CertStoreLocation Cert:\\LocalMachine\\TrustedPublisher\\'
    }
  }
}
