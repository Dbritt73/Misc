Function Invoke-DigitalSignUpdate {
  <#
    .SYNOPSIS
    Automated process to update the content on a digital sign

    .DESCRIPTION
    Invoke-DigitalSignUpdate utilizes PowerShell Remoting in conjunction with PSExec to kill the existing PowerPoint process
    on the remote machine, copy the updated content from a network share to the source directory on the remote machine.
    Once copied the function remotely starts a PowerPoint process as the currently logged in user (A local account) to
    to resume the digital sign presentation with updated content.

    .PARAMETER ComputerName
    The name of the remote computer to execute this code against

    .PARAMETER SourceDir
    Directory location of the source files you want to copy to the remote machine

    .PARAMETER DestinationDir
    Directory location on the remote machine to copy the updated content files to.

    .EXAMPLE
    Invoke-DigitalSignUpdate -ComputerName 'SERVER01' -SourceDir 'C:\temp' -DestinationDir 'C:\users\user01\Desktop\Project'

    Creates a PSSession to 'SERVER01' - Stops the running PowerPoint process - copies files from the SourceDir to the 
    DestianationDir - Starts the updated PowerPoint presentation

    .NOTES
    * PsExec required to run - sysinternals
    * The (-i) parameter allows GUI applications to run in current logged on user session at remote machine
    * Would like to find another solution with the password setup
    * Intended to be converted to .exe and run by end user with no prompting. 
  #>


    [CmdletBinding()]
    Param (

        [String]$ComputerName,

        [String]$UserName,

        [String]$SourceDir,

        [String]$DestinationDir,

        [String]$PowerPointShow

    )

    Begin {

        #$ErrorActionPreference = 'Stop'
        Write-Verbose -Message "Creating PowerShell remoting session to $ComputerName"
        $Session = New-PSSession -ComputerName $ComputerName

        $PathString = "$DestinationDir" + '\' + "$PowerPointShow"

    }

    Process {
        
        Try {

            Write-Verbose -Message "Stop running PowerPoint process on $ComputerName"
            Write-Verbose -Message "Backup previous version of presentation to $DestinationDir\Backup"

            Invoke-Command -Session $Session -ScriptBlock {

                Try {

                    Get-Process -Name 'POWERPNT' | Stop-Process -Force

                    if (test-path -Path "$using:DestinationDir\Backup") {

                        Copy-Item -Path $using:PathString -Destination "$using:DestinationDir\Backup" -Force

                    } Else {

                        New-Item -Path "$using:DestinationDir" -Name 'Backup' -ItemType 'Directory'
                        Copy-Item -Path $using:PathString -Destination "$using:DestinationDir\Backup" -Force

                    }

                } Catch {

                    Return

                }

            }

            Write-Verbose -Message "Copying $PowerPointShow to $DestinationDir on $ComputerName"
            Copy-Item -Path "$SourceDir\$PowerPointShow" -Destination $DestinationDir -ToSession $Session -Recurse -Force -ErrorAction 'Stop'

            if (Test-path -Path "$env:windir\system32\psexec.exe") {

                Write-Verbose -Message "Starting PowerPoint Presentation as $UserName"
                & "$env:windir\system32\psexec.exe" "\\$ComputerName" -i -u "$ComputerName\UserName" -p 'P@$$Word!!' Powershell.exe "Start-process '$PathString'"

            } Else {

                Write-verbose -Message "Fetching PSExec to execute remote commands - location $env:windir\system32\"
                Invoke-WebRequest -Uri 'https://live.sysinternals.com/psexec.exe' -OutFile "$env:windir\system32\psexec.exe" -ErrorAction 'Stop'
                
                Write-Verbose -Message "Starting PowerPoint Presentation as $UserName"
                & "$env:windir\system32\psexec.exe" "\\$ComputerName" -i -u "$ComputerName\UserName" -p 'P@$$Word!!' Powershell.exe "Start-process '$PathString'"

            }
            
        } Catch {

            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve information about runtime error
            $info = [PSCustomObject]@{

            Date      = (Get-Date)
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine

            }
            
            # output information. Post-process collected info, and log info (optional)
            $info | Out-File -FilePath "$ENV:TEMP\SignUpdate.Log"
        
        }

    }

    End {

        Write-Verbose -Message 'Removing PowerShell remoting session'
        Remove-PSSession -Session $Session

    }

}


#Controller Script
Invoke-DigitalSignUpdate -Verbose