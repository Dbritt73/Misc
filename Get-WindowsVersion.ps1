Function Convert-BuildNumber {
  <#
      .SYNOPSIS
      Describe purpose of "Convert-BuildNumber" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER BuildNumber
      Describe parameter -BuildNumber.

      .EXAMPLE
      Convert-BuildNumber -BuildNumber Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Convert-BuildNumber

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [cmdletBinding()]
    Param (

        [int]$BuildNumber

    )

    Begin {}

    Process {

        Switch ($BuildNumber) {

            9600  {$result = 'Microsoft Windows 8.1'}
            10240 {$result = 'Microsoft Windows 10 Build 1507'}
            10586 {$result = 'Microsoft Windows 10 Build 1511'}
            14393 {$result = 'Microsoft Windows 10 Build 1607'}
            15063 {$result = 'Microsoft Windows 10 Build 1703'}
            16299 {$result = 'Microsoft Windows 10 Build 1709'}
            17133 {$result = 'Microsoft Windows 10 Build 1803'}
            17763 {$result = 'Microsoft Windows 10 Build 1809'}
            'Default' {$result = 'Unknown'}

        }

        $result
    }

    End {}
}

Function Get-windowsBuild {
  <#
      .SYNOPSIS
      Describe purpose of "Get-windowsBuild" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER ComputerName
      Describe parameter -ComputerName.

      .EXAMPLE
      Get-windowsBuild -ComputerName Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-windowsBuild

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [cmdletBinding()]
    Param (

        [Parameter( ValueFromPipeline,
                    ValueFromPipelineByPropertyName)]
        [string[]]$ComputerName

    )

    Begin {}

    Process {

        foreach ($computer in $ComputerName) {

            Try {

                $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer

                $props = @{

                    'ComputerName' = $computer

                    'WindowsVersion' = Convert-BuildNumber -BuildNumber $Os.BuildNumber

                }

                $obj = New-object -TypeName psobject -Property $props
                $Obj.PSObject.TypeNames.Insert(0,'System.WindowsVersion')
                Write-Output -InputObject $Obj

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                    Date         = (Get-Date)
                    ComputerName = $computer
                    Exception    = $e.Exception.Message
                    Reason       = $e.CategoryInfo.Reason
                    Target       = $e.CategoryInfo.TargetName
                    Script       = $e.InvocationInfo.ScriptName
                    Line         = $e.InvocationInfo.ScriptLineNumber
                    Column       = $e.InvocationInfo.OffsetInLine

                }
                
                # output information. Post-process collected info, and log info (optional)
                $info
            }

        }

    }

    End {}
}