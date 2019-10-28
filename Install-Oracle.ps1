<#
.Synopsis
   Install Oracle 11g client
.DESCRIPTION
    Install script for the Oracle 11g client and drivers
.EXAMPLE
   .\Install-Oracle.ps1

   Script needs to be in the same directory as the 'Client' folder
#>

[CmdletBinding()]
Param ()

    Begin {

        #get current working directory (PowerShell 2.0)
        $ScriptPath = $MyInvocation.MyCommand.Path
        $CurrentDir = Split-Path -Path $ScriptPath

    }

    Process {

        #Install the Oracle 11g Client
        $ArgumentList = @(

            "-silent"
            "-force"
            "-nowait"
            "-responseFile $CurrentDir\client\client.rsp"
            "-waitforcompletion"

        )
        Start-Process -FilePath "$CurrentDir\Client\Setup.exe" -ArgumentList $ArgumentList -Wait

        #Configure Oracle for specific connections, described in the tnsnames.ora file
        $ArgumentList = @(

            "$CurrentDir\client"
            "$env:HOMEDRIVE\Oracle\Product\11.2.0.3\Client_32bit\network\admin"
            'tnsnames.ora'

        )
        Start-Process -FilePath "$env:windir\system32\robocopy.exe" -ArgumentList $ArgumentList -Wait -NoNewWindow

        #Add System DSN Entries for ODBC Connections
        $Connections = @('Connection1', 'Connection2', 'Connection3', 'Connection4', 'Connection15')

        ForEach ($Connection in $Connections) {

            $splat = @{

                'Name'             = $Connection
                'DsnType'          = 'System'
                'Platform'         = '32-bit'
                'DriverName'       = "Oracle in OraClient11g_home1_32bit"
                'SetPropertyValue' = "server=$Connection"

            }

            Add-OdbcDsn @splat

        }

    }

    End {}
