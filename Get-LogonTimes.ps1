Function Get-LogonTimes {
  <#
    .SYNOPSIS
    Describe purpose of "Get-LogonTimes" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER ComputerName
    Describe parameter -ComputerName.

    .EXAMPLE
    Get-LogonTimes -ComputerName Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-LogonTimes

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (

        [string[]]$ComputerName

    )

    Begin {}

    Process {

        Foreach ($Computer in $ComputerName) {

            Try {

                $CimSession = New-CimSession -ComputerName $Computer
                $LogonSession = Get-CimInstance -ClassName 'Win32_LogonSession' -CimSession $CimSession

                foreach ($Session in $LogonSession) {

                    $Splat = @{

                        'InputObject'     = $Session
                        'ResultClassName' = 'Win32_Account'
                        'CimSession'      = $CimSession

                    }

                    $user = Get-CimAssociatedInstance @Splat

                    $Props = [ordered]@{

                        'ComputerName' = $Computer
                        'Name'         = $user.Fullname
                        'UserId'       = $user.Name
                        'Domain'       = $user.Domain
                        'LocalAccount' = $user.LocalAccount
                        'LogonTime'    = $Session.StartTime

                    }

                    New-Object -TypeName PSobject -Property $props

                }

                Remove-CimSession -CimSession $CimSession

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
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}
