# Azure Policy Ramp Notes

## PowerShell environment and Modules.

Make sure that you are working with PowerShell 7.

```
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

From what I can tell, both of these modules are required.

```
find-module PSDesiredStateConfiguration | install-module
find-module PSDSCResources | install-module
find-module GuestConfiguration | install-module
```

In addition to these files, it is necessary that separate modules be made as not all modules from DSC2 have been ported over for DSC3.

There are two options that can be used for this:
1. Create custom modules through classes (templates are available and only modifications needed are to Get, Set, and Test functions as well as class structure). This module must also be present locally at the path of the environment variable PSModulePath, containing the manifest file and class file.

2. Create a simple DSC script using the script module which appears to be ported over properly.

## Compile MOF file

```powershell
.\demo-config\demo-config.ps1
```

## Create a custom Azure Policy / DSC3 config package.

Generate the state configuration package.

```powershell
New-GuestConfigurationPackage -Name 'basic-package' -Configuration './basic/localhost.mof' -Type AuditAndSet -Force
```

## Test configuration package

However when testing the configuration (note this step is not sucessfull)

```powershell
Get-GuestConfigurationPackageComplianceStatus -Path ./basic-package/basic-package.zip
```

Alternatively, the following command can be used to test and yield compliance result.

```powershell
Start-GuestConfigurationPackageRemediation .\basic-package\basic-package.zip
```

## Publish configuration 

To publish the configuration package, begin to upload the configuration package zip file to Azure storage. This will give a location for Azure Policy to eventually access the configuration. The upload must be the exact zip package that was compiled with all modules within it as well.