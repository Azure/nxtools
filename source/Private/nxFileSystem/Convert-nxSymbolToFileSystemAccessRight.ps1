function Convert-nxSymbolToFileSystemAccessRight
{
    [CmdletBinding()]
    [OutputType([nxFileSystemAccessRight])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Char[]]
        [Alias('Char')]
        $AccessRightSymbol
    )

    process {
        foreach ($charItem in $AccessRightSymbol)
        {
            switch -CaseSensitive ($charItem)
            {
                'w'
                {
                    [nxFileSystemAccessRight]::Write
                }

                'r'
                {
                    [nxFileSystemAccessRight]::Read
                }

                'x'
                {
                    [nxFileSystemAccessRight]::Execute
                }

                '-'
                {
                    [nxFileSystemAccessRight]::None
                }

                'T'
                {
                    Write-Debug -Message "The UpperCase 'T' means there's no Execute right."
                    [nxFileSystemAccessRight]::None
                }

                't'
                {
                    [nxFileSystemAccessRight]::Execute
                }

                'S'
                {
                    Write-Debug -Message "The UpperCase 'S' means there's no Execute right."
                    [nxFileSystemAccessRight]::None
                }

                's'
                {
                    [nxFileSystemAccessRight]::Execute
                }
            }
        }
    }
}
