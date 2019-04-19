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

            10240 {$result = 'Microsoft Windows 10 1507'}

            10586 {$result = 'Microsoft Windows 10 1511'}

            14393 {$result = 'Microsoft Windows 10 1607'}

            15063 {$result = 'Microsoft Windows 10 1703'}

            16299 {$result = 'Microsoft Windows 10 1709'}

            17134 {$result = 'Microsoft Windows 10 1803'}

            17763 {$result = 'Microsoft Windows 10 1809'}

            'Default' {$result = 'Unknown'}

        }

        $result

    }

    End {}
}

Function Get-windowsBuild {
    <#
        .SYNOPSIS
        Retrieves information on the version/build of Windows

        .DESCRIPTION
        Get-Windows build utilizes CIM commands to retrieve information on the version of Windows installed on the computer.
        Works on Windows 8.1 and higher.

        .PARAMETER ComputerName
        Name of computer(s) to query the Windows version

        .EXAMPLE
        Get-windowsBuild -ComputerName 'localhost'

        ComputerName WindowsVersion            WindowsBuild InstallDate
        ------------ --------------            ------------ -----------
        localhost    Microsoft Windows 10 1809 17763        10/3/2018 2:54:35 PM

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Get-windowsBuild

        .INPUTS
        [string[]]

        .OUTPUTS
        Report.WindowsVersion
    #>


    [cmdletBinding()]
    Param (

        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName

    )

    Begin {}

    Process {

        foreach ($computer in $ComputerName) {

            Try {

                $splat = @{

                    'ClassName'    = 'Win32_OperatingSystem'
                    'ComputerName' = $Computer
                    'ErrorAction'  = 'Stop'

                }

                $OS = Get-CimInstance @Splat

                $props = [Ordered]@{

                    'ComputerName'   = $computer
                    'WindowsVersion' = Convert-BuildNumber -BuildNumber $Os.BuildNumber
                    'WindowsBuild'   = $OS.BuildNumber
                    'InstallDate'    = $OS.InstallDate

                }

                $obj = New-object -TypeName psobject -Property $props
                $Obj.PSObject.TypeNames.Insert(0,'Report.WindowsVersion')
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
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}
