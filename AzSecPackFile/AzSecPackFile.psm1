enum Ensure {
    Absent
    Present
}

<#
    This class is used within the DSC Resource to standardize how data
    is returned about the compliance details of the machine.
#>
class Reason {
    [DscProperty()]
    [string] $Code

    [DscProperty()]
    [string] $Phrase
}

<#
   Public Functions
#>

function Get-File {
    param(
        [Ensure]$ensure,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$path
    )
    $content = "
    set MONITORING_DATA_DIRECTORY=C:\Monitoring\Data
    set MONITORING_TENANT=%USERNAME%
    set MONITORING_ROLE=admin
    set MONITORING_ROLE_INSTANCE=%COMPUTERNAME%
    set MONITORING_GCS_ENVIRONMENT=DiagnosticsProd
    set MONITORING_GCS_ACCOUNT=shivam
    set MONITORING_GCS_NAMESPACE=policy
    set MONITORING_GCS_REGION=centralus
    set MONITORING_GCS_AUTH_ID_TYPE=AuthKeyVault
    set MONITORING_GCS_AUTH_ID= PPE.GENEVA.KEYVAULT.AZSECPACK.FIT-MTP.FME.MICROSOFT.COM
    set MONITORING_CONFIG_VERSION=1.0
    set AZSECPACK_PILOT_FEATURES=MdeServer2019Support
    %MonAgentClientLocation%\MonAgentClient.exe -useenv"
    $fileContent        = [Reason]::new()
    $fileContent.code   = 'file:file:content'

    $filePresent        = [Reason]::new()
    $filePresent.code   = 'file:file:path'

    $ensureReturn = 'Absent'

    $fileExists = Test-path $path -ErrorAction SilentlyContinue

    if ($true -eq $fileExists) {
        $filePresent.phrase = "The file was expected to be: $ensure`nThe file exists at path: $path"

        $existingFileContent = Get-Content $path -Raw
        if ([string]::IsNullOrEmpty($existingFileContent)) {
            $existingFileContent = ''
        }

        if ($false -eq ([string]::IsNullOrEmpty($content))) {
            $content = $content | ConvertTo-SpecialChars
        }

        $fileContent.phrase = "The file was expected to contain: $content`nThe file contained: $existingFileContent"

        if ($content -eq $existingFileContent) {
            $ensureReturn = 'Present'
        }
    }
    else {
        $filePresent.phrase = "The file was expected to be: $ensure`nThe file does not exist at path: $path"
        $path = 'file not found'
    }

    return @{
        ensure  = $ensureReturn
        path    = $path
        Reasons = @($filePresent,$fileContent)
    }
}

function Set-File {
    param(
        [Ensure]$ensure = "Present",

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$path
    )
    $content = "
    set MONITORING_DATA_DIRECTORY=C:\Monitoring\Data
    set MONITORING_TENANT=%USERNAME%
    set MONITORING_ROLE=admin
    set MONITORING_ROLE_INSTANCE=%COMPUTERNAME%
    set MONITORING_GCS_ENVIRONMENT=DiagnosticsProd
    set MONITORING_GCS_ACCOUNT=shivam
    set MONITORING_GCS_NAMESPACE=policy
    set MONITORING_GCS_REGION=centralus
    set MONITORING_GCS_AUTH_ID_TYPE=AuthKeyVault
    set MONITORING_GCS_AUTH_ID= PPE.GENEVA.KEYVAULT.AZSECPACK.FIT-MTP.FME.MICROSOFT.COM
    set MONITORING_CONFIG_VERSION=1.0
    set AZSECPACK_PILOT_FEATURES=MdeServer2019Support
    %MonAgentClientLocation%\MonAgentClient.exe -useenv"
    Remove-Item $path -Force -ErrorAction SilentlyContinue
    if ($ensure -eq "Present") {
        New-Item $path -ItemType File -Force
        if ([ValidateNotNullOrEmpty()]$content) {
            $content | ConvertTo-SpecialChars | Set-Content $path -NoNewline -Force
        }
    }
}

function Test-File {
    param(
        [Ensure]$ensure = "Present",

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$path
    )
    $content = "
    set MONITORING_DATA_DIRECTORY=C:\Monitoring\Data
    set MONITORING_TENANT=%USERNAME%
    set MONITORING_ROLE=admin
    set MONITORING_ROLE_INSTANCE=%COMPUTERNAME%
    set MONITORING_GCS_ENVIRONMENT=DiagnosticsProd
    set MONITORING_GCS_ACCOUNT=shivam
    set MONITORING_GCS_NAMESPACE=policy
    set MONITORING_GCS_REGION=centralus
    set MONITORING_GCS_AUTH_ID_TYPE=AuthKeyVault
    set MONITORING_GCS_AUTH_ID= PPE.GENEVA.KEYVAULT.AZSECPACK.FIT-MTP.FME.MICROSOFT.COM
    set MONITORING_CONFIG_VERSION=1.0
    set AZSECPACK_PILOT_FEATURES=MdeServer2019Support
    %MonAgentClientLocation%\MonAgentClient.exe -useenv"

    $test = $false
    $get = Get-File @PSBoundParameters

    if ($get.ensure -eq $ensure) {
        $test = $true
    }
    return $test
}

<#
   Private Functions
#>

function ConvertTo-SpecialChars {
    param(
        [parameter(Mandatory = $true,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$string
    )
    $specialChars = @{
        '`n' = "`n"
        '\\n' = "`n"
        '`r' = "`r"
        '\\r' = "`r"
        '`t' = "`t"
        '\\t' = "`t"
    }
    foreach ($char in $specialChars.Keys) {
        $string = $string -replace ($char,$specialChars[$char])
    }
    return $string
}

<#
    This resource manages the file in a specific path.
    [DscResource()] indicates the class is a DSC resource
#>

[DscResource()]
class AzSecPackFile {

    <#
        This property is the fully qualified path to the file that is
        expected to be present or absent.

        The [DscProperty(Key)] attribute indicates the property is a
        key and its value uniquely identifies a resource instance.
        Defining this attribute also means the property is required
        and DSC will ensure a value is set before calling the resource.

        A DSC resource must define at least one key property.
    #>
    [DscProperty(Key)]
    [string] $path

    <#
        This property indicates if the settings should be present or absent
        on the system. For present, the resource ensures the file pointed
        to by $Path exists. For absent, it ensures the file point to by
        $Path does not exist.

        The [DscProperty(Mandatory)] attribute indicates the property is
        required and DSC will guarantee it is set.

        If Mandatory is not specified or if it is defined as
        Mandatory=$false, the value is not guaranteed to be set when DSC
        calls the resource.  This is appropriate for optional properties.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $ensure


    <#
        This property reports the reasons the machine is or is not compliant.

        [DscProperty(NotConfigurable)] attribute indicates the property is
        not configurable in DSC configuration.  Properties marked this way
        are populated by the Get() method to report additional details
        about the resource when it is present.
    #>
    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    <#
        This method is equivalent of the Get-TargetResource script function.
        The implementation should use the keys to find appropriate
        resources. This method returns an instance of this class with the
        updated key properties.
    #>
    [AzSecPackFile] Get() {
        $get = Get-File -ensure $this.ensure -path $this.path
        return $get
    }

    <#
        This method is equivalent of the Set-TargetResource script function.
        It sets the resource to the desired state.
    #>
    [void] Set() {
        $set = Set-File -ensure $this.ensure -path $this.path
    }

    <#
        This method is equivalent of the Test-TargetResource script
        function. It should return True or False, showing whether the
        resource is in a desired state.
    #>
    [bool] Test() {
        $test = Test-File -ensure $this.ensure -path $this.path
        return $test
    }
}