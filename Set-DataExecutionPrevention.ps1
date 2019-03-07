Function Set-DataExecutionPrevention {
    [CmdletBinding()]
    Param(

        [String[]]$ComputerName,

        [ValidateSet('AlwaysOn', 'AlwaysOff', 'OptIn', 'OptOut')]
        [String]$Value

    )

    Begin {}

    Process {

        foreach ($Computer in $ComputerName) {

            Try {

                if ($PSBoundParameters.value -eq 'AlwaysOn') {

                    Invoke-Command -ComputerName $Computer -ScriptBlock {

                        bcdedit /set '{current}' nx AlwaysOn

                    }


                } elseif ($PSBoundParameters.value -eq 'AlwaysOff') {

                    Invoke-Command -ComputerName $Computer -ScriptBlock {

                        bcdedit /set '{current}' nx AlwaysOff

                    }

                } elseif ($PSBoundParameters.value -eq 'OptIn') {

                    Invoke-Command -ComputerName $Computer -ScriptBlock {

                        bcdedit /set '{current}' nx OptIn

                    }

                } elseif ($PSBoundParameters.value -eq 'OptOut') {

                    Invoke-Command -ComputerName $Computer -ScriptBlock {

                        bcdedit /set '{current}' nx OptOut

                    }

                }

            } Catch {}

        }

    }

    End {}

}