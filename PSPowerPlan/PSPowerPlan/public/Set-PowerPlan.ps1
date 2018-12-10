Function Set-PowerPlan {
  <#
    .SYNOPSIS
    Describe purpose of "Set-PowerPlan" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER Configuration
    Describe parameter -Configuration.

    .EXAMPLE
    Set-PowerPlan -Configuration Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Set-PowerPlan

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (

        [Parameter()]
        [ValidateSet('Balanced', 'High performance', 'Power saver', 'Ultimate Performance')]
        [String]$Configuration

    )

    Begin {}

    Process {

        Try {

            $NewConfig = & "$env:windir\system32\powercfg.exe" -l | ForEach-Object {

                if ($_.Contains("$Configuration")) {

                    $_.Split()[3]

                }

            }

            $Currentconfig = $(& "$env:windir\system32\powercfg.exe" -getactivescheme).Split()[3]

            if ($Currentconfig -ne $NewConfig) {

                & "$env:windir\system32\powercfg.exe" -setactive $NewConfig

                $wmi = @{

                    'NameSpace' = 'root\cimv2\power'

                    'ClassName' = 'Win32_PowerPlan'

                    'ErrorAction' = 'Stop'

                }

                $PowerPlan = Get-CimInstance @wmi | Where-object {$_.InstanceID -like "*$NewConfig*"}

                $Props = [ordered]@{

                    'ComputerName' = $ENV:COMPUTERNAME

                    'PowerPlan' = $PowerPlan.ElementName

                    'Description' = $PowerPlan.Description

                    'ID' = ($PowerPlan.InstanceID).Split('\')[1]

                    'IsActive' = $PowerPlan.IsActive

                }

                $obj = new-object -TypeName Psobject -Property $Props

                Write-output -InputObject $obj

            } Else {

                Write-output -InputObject "$Configuration is already active"

            }

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

    End {}

}