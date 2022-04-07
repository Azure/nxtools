function Get-nxInitSystem
{
    [OutputType([nxInitSystem])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [switch]
        $Force
    )
    if ($script:nxInitSystem -and -not $Force.IsPresent)
    {
        Write-Debug -Message "Returning nxInitSystem from module variable."
    }
    else
    {
        Write-Debug -Message "Evaluating nxInitSystem."
        $initPath = Get-Item -ErrorAction SilentlyContinue -Path '/sbin/init'

        if ($initPath.LinkType -ne 'SymbolicLink')
        {
            # It's a hard path, so probably using initd
            $script:nxInitSystem = [nxInitSystem]::initd
        }
        elseif ($initPath.LinkTarget -match 'systemd$')
        {
            $script:nxInitSystem =  [nxInitSystem]::systemd
        }
        elseif ($initPath.LinkTarget -match 'sysvinit')
        {
            $script:nxInitSystem =  [nxInitSystem]::sysvinit
        }
        elseif ($initPath.LinkTarget -match 'busybox')
        {
            $script:nxInitSystem =  [nxInitSystem]::busybox
        }
        else
        {
            $script:nxInitSystem =  [nxInitSystem]::unknown
        }
    }

    return $script:nxInitSystem
}
