<#
    .SYNOPSIS
    Configure Internet Explorer for a service

    .DESCRIPTION
    Set-IESettings.ps1 is a script designed to configure the Internet Explorer Trusted Site settings for all 
    computer users of the workstation so that it may interact with a web service that required these settings.

    .LINK
    https://support.microsoft.com/en-us/help/182569/internet-explorer-security-zones-registry-entries-for-advanced-users

    .NOTES


#>

[CmdletBinding()]
Param (

    [String]$RegType = 'DWORD'

)

Begin {

    #Apply Custom Zone Settings for TrustedSites Zone
    #Set-Location -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2'
    $Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2'

}

Process {

    Try {

        #Enable 'Automatic Prompting for ActiveX Controls'
        New-ItemProperty -Path $Path -Name 2201 -Value 0 -PropertyType $RegType -Force

        #Enable 'Initialize and script ActiveX controls not marked as safe for scripting (2101)'
        New-ItemProperty -Path $Path -Name 1201 -Value 0 -PropertyType $RegType -Force

        #Disable 'Use Pop-up blocker (1809)'
        New-ItemProperty -Path $Path -Name 1809 -Value 3 -PropertyType $RegType -Force

        #Disable 'Use Smartscreen Filter (2301)'
        New-ItemProperty -Path $Path -Name 2301 -Value 3 -PropertyType $RegType -Force

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
        Write-output -InputObject $info

    }

}

End {

    #Reset working directory back to home drive
    #Set-Location -Path $env:HOMEDRIVE

}