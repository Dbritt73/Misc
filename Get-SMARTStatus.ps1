Function Get-SMARTStatus {
    <#
    .SYNOPSIS
    Get hard disk status based off built in SMART reporting
    
    .DESCRIPTION
    Get-SmartStatus utilizes WMI via Get-CIMInstance to find the physical disks of a system and report on the appoximate
    health of the disk by using the built in SMART Reporting.

    .EXAMPLE
    Get-SMARTStatus -ComputerName 'SERVER1'
    
    .NOTES
    General notes
    #>

     [CmdletBinding()]
    Param (

        [Parameter( HelpMessage="One or multiple system names to inspect.")]
        [String[]]$ComputerName = 'LocalHost'
        
    )

        Begin {}

        Process {

            ForEach ($Computer in $ComputerName) {

                Try {

                    $WMI = @{

                        'Class' = 'Win32_DiskDrive';
                        'ComputerName' = $Computer;
                        'Property' = '*';
                        'ErrorAction' = 'Stop'

                    }

                    $Disks = Get-CimInstance @WMI

                    foreach ($disk in $disks) {

                        $ObjProps = @{

                            'SystemName' = $Disk.SystemName;
                            'DiskName' = $Disk.Caption;
                            'SMARTStatus' = $Disk.Status

                        }
    
                        $DiskObject = New-object -TypeName PSObject -Property $ObjProps
                        $DiskObject.PSObject.Typenames.Insert(0, 'Report.DiskSmartStatus')
                        Write-Output $DiskObject
                    }

                } Catch {

                    Write-Warning -Message "Exception Message for computer ${computer}: $($_.Exception.Message)"

                }

            }

        }

        End {}

}