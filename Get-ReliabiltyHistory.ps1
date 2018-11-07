
function Get-ReliabiltyHistory {
    <#

    .Synopsis
       Gets the reliability on one or more computers

    .DESCRIPTION
       Get-ReliabiltyHistory utilizes Get-CimIUnstance to query the WMI class Win32_ReliabiltyRecords for the reliabilty 
       history of the ctargeted computer

    .EXAMPLE
       Get-ReliabilityHistory -ComputerName 'SERVER01'

    .EXAMPLE
       Get-ReliabilityHistory -ComputerName 'SERVER01', 'SERVER02','SERVER03'

    .EXAMPLE
       (Get-content .\Computers.txt) | Get-ReliabilityHistory

    #>
    [CmdletBinding()]

    Param (

        # Param1 help description
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    ValueFromPipeline= $true,
                    Position=0)]
        [String[]]$ComputerName

    )

    Begin {}

    Process {

        Try {

            Foreach ($computer in $ComputerName){

                $WMI = @{

                    'Class' = 'Win32_ReliabilityRecords';
                    'ComputerName' = $computer;
                    'ErrorAction' = 'Stop'

                }

                $RH = Get-CimInstance @WMI

                foreach ($R in $RH) {

                    $Props = [Ordered]@{
                    
                        'ComputerName' = $computer;
                        'Product' = $R.ProductName;
                        'TimeGenerated' = $R.TimeGenerated;
                        'Message' = $R.Message
    
                    }
    
                    $Object = New-Object -TypeName psobject -Property $props
                    $Object.PSObject.TypeNames.Insert(0,'Report.ReliabilityRecords')
                    Write-Output -InputObject $Object
                }

            }

        } Catch {}

    }

    End {}

}