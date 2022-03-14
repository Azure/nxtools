function Get-nxEscapedString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]
        $String
    )

    process
    {
        return ('''{0}''' -f ($String -replace "\'","''"))
    }
}
