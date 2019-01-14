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

      [Parameter(ValueFromPipeline = $true,
                 ValueFromPipelineByPropertyName =$true)]
      [String[]]$ComputerName = 'localhost',

        [Parameter()]
        [ValidateSet('Balanced', 'High performance', 'Power saver', 'Ultimate Performance')]
        [String]$Configuration

      )

      Begin {}

      Process {

        Foreach ($Computer in $ComputerName) {

            $output = Invoke-command -ComputerName $Computer -ScriptBlock {

                Try {

                    $NewConfig = & "$env:windir\system32\powercfg.exe" -l | ForEach-Object {

                        if ($_.Contains("$Using:Configuration")) {

                            $_.Split()[3]

                        }

                    }

                    & "$env:windir\system32\powercfg.exe" -setactive $NewConfig

                    $wmi = @{

                        'NameSpace' = 'root\cimv2\power'

                        'ClassName' = 'Win32_PowerPlan'

                        'ErrorAction' = 'Stop'

                    }

                    $PowerPlan = Get-CimInstance @wmi | Where-object {$_.InstanceID -like "*$NewConfig*"}

                    $Props = [ordered]@{

                        'ComputerName' = $Using:Computer

                        'PowerPlan' = $PowerPlan.ElementName

                        'Description' = $PowerPlan.Description

                        'InstanceID' = ($PowerPlan.InstanceID).Split('\')[1]

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

            [PSCustomObject]$Output | Select-Object computername, powerplan, Description, InstanceID, IsActive

        }

    }

    End {}

}