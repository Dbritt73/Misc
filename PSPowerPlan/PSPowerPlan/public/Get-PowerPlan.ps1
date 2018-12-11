Function Get-PowerPlan {
    [CmdletBinding()]
    Param ()

    Begin {}

    Process {

        Try {

            $wmi = @{

                'NameSpace' = 'root\cimv2\power'

                'ClassName' = 'Win32_PowerPlan'

                'ErrorAction' = 'Stop'

            }

            $PowerPlan = Get-CimInstance @wmi | Where-object {$_.IsActive -eq 'True'}

                    $Props = [ordered]@{

                        'ComputerName' = $ENV:COMPUTERNAME

                        'PowerPlan' = $PowerPlan.ElementName

                        'Description' = $PowerPlan.Description

                        'ID' = ($PowerPlan.InstanceID).Split('\')[1]

                        'IsActive' = $PowerPlan.IsActive

                    }

                    $obj = new-object -TypeName Psobject -Property $Props

                    Write-output -InputObject $obj

        } Catch {}

    }

    End {}

}