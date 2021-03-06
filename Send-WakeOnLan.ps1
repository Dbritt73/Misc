﻿#!/usr/bin/env powershell

Function Send-WakeOnLAN {
    <#
    .SYNOPSIS
    Send a Wake-On-LAN packet to wake a sleeping computer

    .DESCRIPTION
    Send-WakeOnLAN takes the supplied hardware MAC address and converts into a properly formatted byte value and sends
    to the target via the native UDP Client in Windows. Able to specify the port in which to connect to the
    target as well.

    .EXAMPLE
    Send-WakeOnLAN -MAC '00:11:32:21:2D:11'

    .EXAMPLE
    Send-WakeOnLAN -MAC '00:11:32:21:2D:11' -Port 9

    .NOTES
    *Initial purpose was to copy this script to a remote computer that lives on the same subnet of the desired target
    computer, Enter-PSSession to this 'jump box' and run against actual target. This was to bypass the need to have IP
    helpers when running from a computer on a different subnet.

    *Original Code from : https://www.pdq.com/blog/wake-on-lan-wol-magic-packet-powershell/
    #>

    [CmdletBinding()]
    Param (

        [Parameter( Position = 0,
                    Mandatory=$true,
                    HelpMessage='Hardware address for the network adapter of target endpoint')]
        [String]$MAC,

        [Parameter( Position = 1)]
        [int]$Port = 7

    )

    Begin {}

    Process {

        Try {

            Write-Verbose -Message "Converting MAC address $MAC to the proper format of the Byte type"
            $ByteArray = $MAC -split '[:-]' | ForEach-Object {

                [Byte]"0x$_"

            }

            Write-Verbose -Message 'Creating the Wake-On-LAN packet to send'
            [Byte[]]$MagicPacket = (,0xFF * 6) + ($ByteArray * 16)

            Write-Verbose -Message 'Initializing the native UDP Client'
            $UDP = New-Object -TypeName System.Net.Sockets.UdpClient

            Write-Verbose -Message 'Attempt connection to target network adapter'
            $UDP.Connect(([System.Net.IPAddress]::Broadcast),$Port)

            Write-Verbose -Message 'Broadcasting Wake-On-LAN packet to target node'
            $UDP.Send($MagicPacket, $MagicPacket.Length) | Out-Null

            Write-Verbose -Message 'Closing local UDP client'
            $UDP.Close()

            Write-Output -InputObject "Magic packet sent to $MAC"

        } Catch {}

    }

    End {}
}