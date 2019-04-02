Function Invoke-HyperVFix {
    [CmdletBinding()]
    Param (

        [String[]]$ComputerName

    )

    Begin {}

    Process {

        foreach ($computer in $ComputerName) {

            Invoke-Command -computername $Computer -ScriptBlock {

                $output = MOFCOMP %SYSTEMROOT%\System32\WindowsVirtualization.V2.mof
                #if ($verbose) {

                    Write-Verbose -Message "$($Output[2])" -Verbose
                    Write-Verbose -Message "$($Output[3])" -Verbose
                    Write-Verbose -Message "$($Output[4])" -Verbose
                    Write-Verbose -Message "$($Output[5])" -Verbose

                    $props = @{

                        'Status'       = 'Success'
                        'NeedsReboot'  = 'True'

                    }

                    $object = New-Object -TypeName PSObject -Property $props
                    Write-Output $object

                #} Else {

                    #Write-Output -InputObject $output

                #}

            }

        }

    }

    End {}

}