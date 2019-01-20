Function Install-PSVimSyntaxColoring {
  <#
    .SYNOPSIS
    Install PowerShell cyntax color highlighting for vim

    .DESCRIPTION
    Install-PSVimSyntaxColoring takes the PowerShell syntax highlighting files, downloaded from vim.org and copies them
    to the correct location based on the Vim install directory parameter provided.

    .PARAMETER VimDir
    Vim's install directory

    .EXAMPLE
    Install-PSVimSyntaxColoring -VimDir 'C:\Program Files (x86)\vim\vim80'

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    https://www.vim.org/scripts/script.php?script_id=1327
  #>


    [CmdletBinding()]
    Param (

        [Parameter( Mandatory = $True,
                    HelpMessage = 'Install directory for Vim',
                    ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True)]
        [string]$VimDir

    )

    Begin {}

    Process {

        Try {

            Write-Verbose -Message "Copying contents of $PSScriptRoot\doc\ to $VimDir\doc"
            Copy-Item -Path "$PSScriptRoot\doc\*" -Destination "$VimDir\doc" -Force

            Write-Verbose -Message "Copying directory $PSScriptRoot\ftdetect to $VimDir"
            Copy-Item -Path "$PSScriptRoot\ftdetect" -Destination "$VimDir" -Recurse -Force

            Write-Verbose -Message "Copying contents of $PSScriptRoot\ftplugin\ to $VimDir\ftplugin"
            Copy-Item -Path "$PSScriptRoot\ftplugin\*" -Destination "$VimDir\ftplugin" -Force

            Write-Verbose -Message "Copying contents of $PSScriptRoot\indent\ to $VimDir\indent"
            Copy-Item -Path "$PSScriptRoot\indent\*" -Destination "$VimDir\indent" -Force

            Write-Verbose -Message "Copying contents of $PSScriptRoot\syntax\ to $VimDir\syntax"
            Copy-Item -Path "$PSScriptRoot\syntax\*" -Destination "$VimDir\syntax" -Force

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

#Controller
Install-PSVimSyntaxColoring -VimDir "${env:ProgramFiles(x86)}\vim\vim80" -Verbose