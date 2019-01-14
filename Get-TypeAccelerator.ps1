Function Get-TypeAccelerators {
  <#
    .SYNOPSIS
    Get a list of available Type Accelerators

    .DESCRIPTION
    A fucntion to quickly get a list of available Type Accelerators for reference

    .EXAMPLE
    Get-TypeAccelerators

    Lists available Type Accelerators

    Truncated Example Output:

    Accelerator                  TypeName
    -----------                  --------
    adsi                         System.DirectoryServices.DirectoryEntry
    adsisearcher                 System.DirectoryServices.DirectorySearcher
    Alias                        System.Management.Automation.AliasAttribute
    AllowEmptyCollection         System.Management.Automation.AllowEmptyCollectionAttribute
    AllowEmptyString             System.Management.Automation.AllowEmptyStringAttribute
    AllowNull                    System.Management.Automation.AllowNullAttribute
    ArgumentCompleter            System.Management.Automation.ArgumentCompleterAttribute
    array                        System.Array
    bigint                       System.Numerics.BigInteger
    bool                         System.Boolean
    byte                         System.Byte
    char                         System.Char

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    http://powershell-guru.com/powershell-tip-29-get-type-accelerators/

    .INPUTS
    No inputs

    .OUTPUTS
    Selected.System.Collections.Generic.KeyValuePair`2[System.String,System.Type]
  #>


    [CmdletBinding()]
    Param ()

    Begin {}

    Process {

        [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get.GetEnumerator() |
            Select-Object -Property @{Name='Accelerator'; Expression={$_.Key}},@{name='TypeName'; Expression={$_.Value}} |
                Sort-Object -Property Accelerator

    }

    End {}

}