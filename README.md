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
```

## Compile MOF file

```powershell
.\basic-dsc-config-localhost\basic-localhost.ps1
```

## Create a custom Azure Policy / DSC3 config package.

When trying to run the `New-GuestConfigurationPackage` command, I was receiving the following error.

```
Exception: 'PsDesiredStateConfiguration' module is not supported by GuestConfiguration. Please use 'PSDSCResources' module instead of 'PsDesiredStateConfiguration' module in DSC configuration.
```

To remediate, I've update these lines in the MOF file.

```
 ModuleName = "PSDesiredStateConfiguration"; >  ModuleName = "PSDSCResources";
 ModuleVersion = "1.0"; > ModuleVersion = "2.12.0.0";
```

Now when running the following command, the .zip file is created.

```powershell
New-GuestConfigurationPackage -Name 'basic' -Configuration './basic/localhost.mof' -Type Audit -Force
```

## Test configuration package

However when testing the configuration:

```powershell
Get-GuestConfigurationPackageComplianceStatus -Path ./basic/basic.zip
```

I am getting this error.

```
Write-Error: Job 0b64f590-eca0-4b41-971d-61c882b38ee2 : MIResult: 6 Error Message: A value for the required property "ModuleName" is missing for the resource with ID "[File]AzSecPackDir" and type "MSFT_FileDirectoryConfiguration".
Please update this resource in the configuration with the required property and value. Message ID: MI RESULT 6 Error Category: 13 Error Code: 6 Error Type: MI
```