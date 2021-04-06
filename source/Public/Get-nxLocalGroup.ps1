function Get-nxLocalGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [regex]
        $GroupName
    )

    $readEtcGroupCmd = {
        Get-Content -Path '/etc/group' | ForEach-Object -Process {
            [nxLocalGroup]$_
        }
    }

    if (-not $PSBoundParameters.ContainsKey('GroupName'))
    {
        &$readEtcGroupCmd
    }
    else
    {
        &$readEtcGroupCmd | Where-Object -FilterScript {
            $_.GroupName -match $GroupName
        }
    }
}
