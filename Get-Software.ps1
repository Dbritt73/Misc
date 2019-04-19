Function Get-Software  {
  <#
      .SYNOPSIS
      Get a list of installed software on the local or remote systems

      .DESCRIPTION
      Get-Software queries the Uninstall registry keys in the software hive to gather information on installed software.
      Properties gathered include Name, version, vendor information, date installed, and the unisntall string for the
      software.

      .PARAMETER ComputerName
      Computer name(s) you want to query installed software.

      .EXAMPLE
      Get-Software -ComputerName 'SERVER01'
      Example of querying a single remote machine

      .EXAMPLE
      Get-Software -ComputerName 'SERVER01', 'SERVER02', 'SERVER03'
      Example of querying a multiple remote machine

      .EXAMPLE
      'SERVER01', 'SERVER02', 'SERVER03' | Get-Software
      Example of querying a multiple remote machines using the pipeline

      .EXAMPLE
      (Get-Content -path .\computers.txt) | Get-Software
      Example of querying a multiple remote machine names from file contents using the pipeline

      .NOTES
      Reworked the object creation from original code to make (in my opinion) more readable

      .LINK
      Original script code found here:
      http://techibee.com/powershell/powershell-script-to-query-softwares-installed-on-remote-computer/1389

      .INPUTS
      String or an array of strings that represent computer names

      .OUTPUTS
      Custom object of type Software.Inventory.Report
  #>

    [cmdletbinding()]
    param(

     [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true)]
     [string[]]$ComputerName = $env:computername

    )

    Begin {

     $UninstallRegKeys=@('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall',
                        'SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall')

    }

    Process {

        foreach($Computer in $ComputerName) {

            Write-Verbose -Message "Working on $Computer"
            if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) {

                Foreach($UninstallRegKey in $UninstallRegKeys) {

                    Try {

                        $HKLM          = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer)
                        $UninstallRef  = $HKLM.OpenSubKey($UninstallRegKey)
                        $Applications  = $UninstallRef.GetSubKeyNames()

                    } Catch {

                        Write-Verbose -Message "Failed to read $UninstallRegKey on $computer"
                        Continue

                    }

                    Foreach ($App in $Applications) {

                        $AppRegistryKey  = $UninstallRegKey + '\\' + $App
                        $AppDetails      = $HKLM.OpenSubKey($AppRegistryKey)
                        $AppGUID         = $App

                        If($UninstallRegKey -match 'Wow6432Node') {

                            $Softwarearchitecture = 'x86'

                        } Else {

                            $Softwarearchitecture = 'x64'

                        }

                        If ( ! $($AppDetails.GetValue('DisplayName')) ) { continue }

                        $Objprops = [ordered]@{

                            'ComputerName' = $Computer
                            'AppName'      = $($AppDetails.GetValue('DisplayName'))
                            'AppVersion'   = $($AppDetails.GetValue('DisplayVersion'))
                            'AppVendor'    = $($AppDetails.GetValue('Publisher'))
                            'InstallDate'  = $($AppDetails.GetValue('InstallDate'))
                            'UninstallKey' = $($AppDetails.GetValue('UninstallString'))
                            'AppGUID'      = $AppGUID
                            'SoftwareArch' = $Softwarearchitecture

                        }

                        $Obj = New-Object -TypeName PSObject -Property $ObjProps
                        $Obj.psobject.typenames.insert(0, 'Report.Software.Inventory')
                        Write-output -InputObject $Obj

                    }

                }

            }

        }

    }

    End {}

}