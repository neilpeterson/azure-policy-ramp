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
        [String]$path,

        [String]$content
    )
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
        content = $existingFileContent
        Reasons = @($filePresent,$fileContent)
    }
}

function Set-File {
    param(
        [Ensure]$ensure = "Present",

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$path,

        [String]$content
    )
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
        [String]$path,

        [String]$content
    )
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
class NewFile {

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
        This property is optional. When provided, the content of the file
        will be overwridden by this value.
    #>
    [DscProperty()]
    [string] $content

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
    [NewFile] Get() {
        $get = Get-File -ensure $this.ensure -path $this.path -content $this.content
        return $get
    }

    <#
        This method is equivalent of the Set-TargetResource script function.
        It sets the resource to the desired state.
    #>
    [void] Set() {
        $set = Set-File -ensure $this.ensure -path $this.path -content $this.content
    }

    <#
        This method is equivalent of the Test-TargetResource script
        function. It should return True or False, showing whether the
        resource is in a desired state.
    #>
    [bool] Test() {
        $test = Test-File -ensure $this.ensure -path $this.path -content $this.content
        return $test
    }
}