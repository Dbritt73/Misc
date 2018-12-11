Function Get-PowerPlan {
  <#
    .SYNOPSIS
    Describe purpose of "Get-PowerPlan" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-PowerPlan -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-PowerPlan

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (

        [Parameter( ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True,
                    Position = 0)]
        [string[]]$ComputerName = 'localhost'

    )

    Begin {}

    Process {

        foreach ($computer in $ComputerName) {

            Try {

                $wmi = @{

                    'ComputerName' = $Computer

                    'NameSpace' = 'root\cimv2\power'

                    'ClassName' = 'Win32_PowerPlan'

                    'ErrorAction' = 'Stop'

                }

                $PowerPlan = Get-CimInstance @wmi | Where-object {$_.IsActive -eq 'True'}

                        $Props = [ordered]@{

                            'ComputerName' = $Computer

                            'PowerPlan' = $PowerPlan.ElementName

                            'Description' = $PowerPlan.Description

                            'ID' = ($PowerPlan.InstanceID).Split('\')[1]

                            'IsActive' = $PowerPlan.IsActive

                        }

                        $obj = new-object -TypeName Psobject -Property $Props

                        Write-output -InputObject $obj

            } Catch {

                # get error record
                [Management.Automation.ErrorRecord]$e = $_

                # retrieve information about runtime error
                $info = [PSCustomObject]@{

                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine

                }

                # output information. Post-process collected info, and log info (optional)
                $info

            }

        }

    }

    End {}

}