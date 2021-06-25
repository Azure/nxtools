function Get-nxEscapedPath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]
        $Path
    )

    process
    {
        return ('"{0}"' -f $Path)
    }
}
