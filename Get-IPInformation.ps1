Function Get-IPInformation {
  <#
    .SYNOPSIS
    Describe purpose of "Get-IPInformation" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER IPAddress
    Describe parameter -IPAddress.

    .EXAMPLE
    Get-IPInformation -IPAddress '8.8.4.4'
    Describe what this call does

    .NOTES


    .LINK
    https://www.scriptinglibrary.com/languages/powershell/how-to-get-your-external-ip-with-powershell-core-using-a-restapi/

  #>


    [CmdletBinding()]
    Param (

        [Parameter( ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true)]
        [String[]]$IPAddress

    )

    Begin {}

    Process {

        if ($PSBoundParameters.ContainsKey('IPAddress')) {

            foreach ($IP in $IPAddress) {

                Try {

                    $IPInfo = Invoke-RestMethod -Uri "Https://ipinfo.io/$IP/json"
                    #$IPv6 = Invoke-RestMethod -uri 'http://ipv6.icanhazip.com'

                    $Props = [ordered]@{

                        'IPv4'         = $IPInfo.ip;
                        #'IPv6'        = $IPv6.Trim();
                        'Hostname'     = $IPInfo.Hostname;
                        'City'         = $IPInfo.City;
                        'Region'       = $IPInfo.Region;
                        'Country'      = $IPInfo.Country;
                        'Location'     = $IPInfo.loc;
                        'Organization' = $IPInfo.Org

                    }

                    $Object = New-Object -TypeName psobject -Property $props
                    $Object.PSObject.TypeNames.Insert(0,'Net.IPInformation')
                    Write-Output -InputObject $Object

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
                    Write-Output -InputObject $info
                }

            }

        } else {

            Try {

                $IPInfo = Invoke-RestMethod -Uri 'https://ipinfo.io/json'
                $IPv6 = Invoke-RestMethod -uri 'http://ipv6.icanhazip.com'

                $Props = [ordered]@{

                    'IPv4'         = $IPInfo.ip
                    'IPv6'         = $IPv6.Trim()
                    'Hostname'     = $IPInfo.Hostname
                    'City'         = $IPInfo.City
                    'Region'       = $IPInfo.Region
                    'Country'      = $IPInfo.Country
                    'Location'     = $IPInfo.loc
                    'Organization' = $IPInfo.Org

                }

                $Object = New-Object -TypeName psobject -Property $props
                $Object.PSObject.TypeNames.Insert(0,'Net.IPInformation')
                Write-Output -InputObject $Object

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
                Write-Output -InputObject $info

            }

        }

    }

    End {}

}