Function Get-SCCMNetworkAdapter {
    <#
        .SYNOPSIS
        Describe purpose of "Get-SCCMNetworkAdapter" in 1-2 sentences.

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER ComputerName
        Describe parameter -ComputerName.

        .PARAMETER ReportUri
        Describe parameter -ReportUri.

        .EXAMPLE
        Get-SCCMNetworkAdapter -ComputerName Value -ReportUri Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Get-SCCMNetworkAdapter

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
    #>

    [CmdletBinding()]
    Param (

    [Parameter( Mandatory = $true,
                HelpMessage = 'Name of computer(s) to query',
                ValueFromPipeline = $True,
                ValueFromPipelineByPropertyName = $true,
                Position = 0)]
    [String[]]$ComputerName,

    [String]$ReportUri = 'http://Report-Server_URI-Goes_HERE%2fHardware+-+Network+Adapter%2fNetwork+adapter+information+for+a+specific+computer&rs:format=xml&variable='

    )

    Begin {}

    Process {

        Try {

            Foreach ($Computer in $ComputerName) {

                $ReportServerUri = $ReportUri + $Computer

                $splat = @{

                    'Uri'                   = $ReportServerUri
                    'UseDefaultCredentials' = $true
                    'ErrorAction'           = 'Stop'

                }

                $Response = invoke-RestMethod @splat

                #Regex required to scrub the XML string of any non-standard ASCII chars
                [xml]$XMLReport = $Response -replace '[^ -x7e]',''

                foreach ($NetAdapter in $XMLReport.Report.Table0.Detail_Collection.Detail) {

                    $Properties = [Ordered]@{

                        'ComputerName' = $NetAdapter.Details_Table0_Netbios_Name0
                        'Description'  = $NetAdapter.Details_Table0_Description0
                        'Manufacturer' = $NetAdapter.Details_Table0_Manufacturer0
                        'AdapterType'  = $NetAdapter.Details_Table0_AdapterType0
                        'MACAddress'   = $NetAdapter.Details_Table0_MACAddress0
                        'IPAddress'    = $NetAdapter.Details_Table0_IPAddress0
                        'IPSubnet'     = $NetAdapter.Details_Table0_IPSubnet0

                    }

                    $Object = New-object -typename PSObject -Property $Properties
                    $Object.PSObject.TypeNames.Insert(0,'Report.SCCM.NetworkAdapter')
                    Write-Output -InputObject $Object

                }

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



Function Invoke-WakeOnLan {
    <#
        .SYNOPSIS
        Describe purpose of "Invoke-WakeOnLan" in 1-2 sentences.

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER Target
        Describe parameter -Target.

        .PARAMETER TargetNetNeighbor
        Describe parameter -TargetNetNeighbor.

        .PARAMETER Port
        Describe parameter -Port.

        .EXAMPLE
        Invoke-WakeOnLan -Target Value -TargetNetNeighbor Value -Port Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Invoke-WakeOnLan

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
    #>


    [CmdletBinding()]
    Param (

        [String]$Target,

        [string]$TargetNetNeighbor,

        [int]$Port = 7

    )

    Begin {}

    Process {

        Try {

            $SCCMInfo = Get-SCCMNetworkAdapter -ComputerName $Target | Where-Object {$_.IPAddress -like '140.160*'}

            Invoke-Command -ComputerName $TargetNetNeighbor -ScriptBlock {

                Write-Verbose -Message "Converting MAC address $($Using:SCCMInfo.MACAddress) to the proper format of the Byte type"
                $ByteArray = $Using:SCCMInfo.MACAddress -split '[:-]' | ForEach-Object {[Byte]"0x$_"}

                Write-Verbose -Message 'Creating the Wake-On-LAN packet to send'
                [Byte[]]$MagicPacket = (,0xFF * 6) + ($ByteArray * 16)

                Write-Verbose -Message 'Initializing the native UDP Client'
                $UDP = New-Object -TypeName System.Net.Sockets.UdpClient

                Write-Verbose -Message 'Attempt connection to target network adapter'
                $UDP.Connect(([System.Net.IPAddress]::Broadcast),$Using:port)

                Write-Verbose -Message 'Broadcasting Wake-On-LAN packet to target node'
                $UDP.Send($MagicPacket, $MagicPacket.Length) | Out-Null

                Write-Verbose -Message 'Closing local UDP client'
                $UDP.Close()

                $props = [Ordered]@{

                    'ComputerName' = $Using:SCCMInfo.ComputerName
                    'IPAddress' = $Using:SCCMInfo.IPAddress
                    'MACAddress' = $Using:SCCMInfo.MACAddress

                }

                $Object = New-Object -TypeName PSObject -Property $props
                $object.PSObject.typenames.insert(0, 'Report.WakeOnLAN')
                Write-Output -InputObject $Object

            }

        } Catch {}

    }

    End {}

}