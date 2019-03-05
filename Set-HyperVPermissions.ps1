Function Set-HyperVPermissions {
    [CmdletBinding()]
    Param (

        [String[]]$ComputerName

    )

    Begin {}

    Process {

        Foreach ($Computer in $ComputerName) {

            Try {

                Invoke-Command -ComputerName $Computer -ScriptBlock {

                    Add-LocalGroupMember -Group 'Hyper-V Administrators' -Member 'NT Virtual Machine\Virtual Machines'

                    Add-LocalGroupMember -Group 'Remote Management Users' -Member 'NT Virtual Machine\Virtual Machines'

                }

            } Catch {}

        }

    }

    End {}

}