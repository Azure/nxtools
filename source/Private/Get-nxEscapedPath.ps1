function Get-nxEscapedPath
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter()]
        [System.String]
        $Path
    )

    return ('"{0}"' -f $Path)
}
