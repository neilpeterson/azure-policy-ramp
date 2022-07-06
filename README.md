# Azure Policy Ramp Notes

## PowerShell environment and Modules

Make sure that you are working with PowerShell 7.

```powershell
$> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.2.3
PSEdition                      Core
GitCommitId                    7.2.3
OS                             Microsoft Windows 10.0.22000
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

Install the following PowerShell modules.

```powershell
find-module PSDesiredStateConfiguration | install-module
find-module PSDSCResources | install-module
find-module GuestConfiguration | install-module
```

## DSC Modules

Most DSC v2 modules have not been updated to be compatible with PowerShell 7. It will be necessary to create custom modules / logic until all DSC modules have been updated.

Two options can be used for this:

1. Create custom modules through PowerShell classes (templates are available; the only modifications needed are to Get, Set, and Test functions and class structure). This module must also be present locally at the path of the environment variable PSModulePath, containing the manifest file and class file.
2. Create a simple DSC script using the DSC script resource, which appears to have been ported over properly.

For this POC a custom module was created named `NewFile` and is found at the root of this repo. Copy this directory to a PowerShell module directory.

## Author a DSC configuration

See the sample in this repo at ./demo-config/demo-config.ps1. Notice that this config uses the custom NewFile module found in this repository.

## Compile MOF file

Run the following command to compile the config (.ps1) into a .mof file.

```powershell
.\tls-config\tls.ps1
```

## Create a custom Azure Policy / DSC3 config package.

The .mof file then needs to be packaged into an Azure Guest Configuration package. Use the following command to do this. The resulting package is a .zip file.

```powershell
New-GuestConfigurationPackage -Name 'tls-secure' -Configuration './tls/localhost.mof' -Type AuditAndSet -Force
```

## Test configuration package

Use the following command to test that the configuration package .zip file is specification compliant.

```powershell
Get-GuestConfigurationPackageComplianceStatus -Path ./tls-secure.zip
```

The output should look similar to this.

```powershell
PS > Get-GuestConfigurationPackageComplianceStatus -Path ./basic-package.zip

additionalProperties : {}
assignmentName       : basic-package
complianceStatus     : False
endTime              : 6/22/2022 2:50:55 AM
jobId                : 7cdcfc30-490b-4748-af83-4b439d55530e
operationtype        : Consistency
resources            : {@{complianceStatus=False; properties=; reasons=System.Object[]}}
startTime            : 6/22/2022 2:50:49 AM
```

And the following command can be used to execute the configuration and yield compliance results.

```powershell
Start-GuestConfigurationPackageRemediation ./tls-secure.zip
```

This step should create the file `/tmp/test.txt` at the root of your Windows file system with the text DSC Rocks inside the text file.

## Publish configuration 

To publish the configuration package, to upload the configuration package zip file to an Azure Blob storage container. This will give a location for Azure Policy to eventually access the configuration. The upload must be the exact zip package that was compiled with all modules within it as well.

For the commands, the following can be used:
```powershell
# Creates a new resource group, storage account, and container
New-AzResourceGroup -name myResourceGroupName -Location WestUS
New-AzStorageAccount -ResourceGroupName myResourceGroupName -Name mystorageaccount -SkuName 'Standard_LRS' -Location 'WestUs' | New-AzStorageContainer -Name guestconfiguration -Permission Blob
```

Then, create a blob and upload the storage by obtaining the context of the account:
```powershell
$Context = New-AzStorageContext -ConnectionString "DefaultEndpointsProtocol=https;AccountName=ContosoGeneral;AccountKey=< Storage Key for ContosoGeneral ends with == >;"
Set-AzStorageBlobContent -Container "guestconfiguration" -File ./MyConfig.zip -Blob "guestconfiguration" -Context $Context
```

## Create Azure Policy

Create the Azure Policy template using this command.

```powershell
$ContentUri = ''

New-GuestConfigurationPolicy -PolicyId (New-Guid).Guid -ContentUri $ContentUri -DisplayName 'TLS Secure' -Path './policies' -Platform 'Windows' -Description 'TLS Secure' -PolicyVersion 1.0.0 -Mode ApplyAndAutoCorrect -Verbose
```

And publish the policy to Azure.

```powershell
New-AzPolicyDefinition -Name 'tls-secure' -Policy .\policies\tls-secure_DeployIfNotExists.json
```

## Create Policy assignment

Use the Azure portal or other mechinism to assign the policy.

## Creating Remediation
From the current understanding and usage of Azure Policy Guest Configuration, remediation occurs only with policies of the type deployIfNotExists and modify. These are determined by the Guest Configuration package that is given ApplyAndAutoCorrect or ApplyAndMonitor when transformed to a policy. The main usage for auto-remediation is with ApplyAndAutoCorrect. However, for continuous remediation to trigger, a remediation task must be created for the policy first in the following manner:

```powershell
az policy remediation create --name myRemediation --policy-assignment '/subscriptions/{subscriptionId}/providers/Microsoft.Authorization/policyAssignments/{myAssignmentId}'
```

## Special Instructions for Naming
It was found that in order for all the policy assignments to properly form and remediation to initiate, all names within the policy definition JSON file must be the same as the zip package that was uploaded to Azure storage. In creating these definitions, the names were found to not be the same, meaning that the JSON must be edited directly.

## Creating a Policy Assignment and Remediation on Creation of Assignment
To create the policy assignment, a separate command must be run. In addition, to create a proper managed identity for the assignment to remediate the resources, the remediation is also created with the series of commands.

```powershell
$policyDef = Get-AzPolicyDefinition -Id '{policyId}'
$resourceGroup = Get-AzResourceGroup -Name '{resourceGroupName}'
$assignment = New-AzPolicyAssignment -Name 'tls-secure' -DisplayName '{policyName}' -Scope $resourceGroup.ResourceId -PolicyDefinition $policyDef -Location '{location}' -IdentityType "SystemAssigned"
```

Then, the following command can be run in order to create a remediation task:
```powershell
Start-AzPolicyRemediation -Name 'myRemedation' -PolicyAssignmentId '/subscriptions/{subscriptionId}/providers/Microsoft.Authorization/policyAssignments/{myAssignmentId}'
```