function Get-FileHashAlgorithmFromHash
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        [Alias('Hash')]
        $FileHash
    )

    switch ($FileHash.Length)
    {
        32
        {
            'MD5'
        }

        40
        {
            'SHA1'
        }

        64
        {
            'SHA256'
        }

        128
        {
            'SHA512'
        }

        default
        {
            throw ('Could not resolve the Algorith used for hash ''{0}''' -f $FileHash)
        }
    }
}
