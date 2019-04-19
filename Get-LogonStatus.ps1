
Function Get-LogonStatus {
    <#
    .SYNOPSIS
        Will report the logon status of a remote or local computer
    .DESCRIPTION
        Get-LogonStatus utilizies a combination of WMI via CimInstance, and Get-Process to determine the logon status of
        a local or remote computer(s)
    .EXAMPLE
        Get-LogonStatus -ComputerName SERVER1
    .NOTES
        Original code borrowed from a script Written by BigTeddy 10 September 2012
    #>
    [Cmdletbinding()]
    Param (
        [parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String[]]$Computername
    )

    Begin {}

    Process {

        Foreach ($Computer in $computername) {

            Try {

                $wmi = @{

                    'Class' = 'Win32_ComputerSystem';
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'

                }

                $user = Get-CimInstance @wmi


            } Catch {

                #Write-output "Unable to Connect to $computer"
                $LogonStatus = @{

                    'ComputerName' = $computer;
                    'Status' = 'Inaccessible';
                    'User' = 'NA'

                }

                $LogonStatusObj = New-Object -TypeName psobject -Property $LogonStatus
                $LogonStatusObj.PSObject.TypeNames.Insert(0,'LogonStatus.Object')
                Write-Output $LogonStatusObj
                Return

            }

            Try {

                $logonUI = Get-Process logonui -ComputerName $Computer -ErrorAction 'Stop'

                if (($logonUI) -and ($user.username)) {

                    $LogonStatus = @{

                        'ComputerName' = $computer;
                        'Status' = 'Locked';
                        'User' = $User.Username

                    }

                    $LogonStatusObj = New-Object -TypeName psobject -Property $LogonStatus
                    $LogonStatusObj.PSObject.TypeNames.Insert(0,'LogonStatus.Object')
                    Write-Output $LogonStatusObj

                }

                if (($logonUI) -and ($user.username -eq $Null) ) {

                    $LogonStatus = @{

                        'ComputerName' = $computer;
                        'Status' = 'NoLogon';
                        'User' =  'None'

                    }

                    $LogonStatusObj = New-Object -TypeName psobject -Property $LogonStatus
                    $LogonStatusObj.PSObject.TypeNames.Insert(0,'LogonStatus.Object')
                    Write-Output $LogonStatusObj

                }

            } Catch {

                if ($user.username -ne $null) {

                    $LogonStatus = @{

                        'ComputerName' = $computer;
                        'Status' = 'ActiveLogon';
                        'User' =  $User.username

                    }

                    $LogonStatusObj = New-Object -TypeName psobject -Property $LogonStatus
                    $LogonStatusObj.PSObject.TypeNames.Insert(0,'LogonStatus.Object')
                    Write-Output $LogonStatusObj

                }

            }

        }

    }

    End {}

}