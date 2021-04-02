function Convert-CharToNxFileSystemSpecialMode
{
    [CmdletBinding()]
    [OutputType([nxFileSystemSpecialMode])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Char[]]
        [Alias('Char')]
        # the possible char are [sStT], but if other values sucha as [rwx-] are passed, we should just ignore them (no special permission).
        $SpecialModeSymbol,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [nxFileSystemUserClass]
        $UserClass
    )

    process {
        foreach ($charItem in $SpecialModeSymbol)
        {
            Write-Debug -Message "Converting '$charItem' to [nxFileSystemSpecialMode]."
            switch ($charItem)
            {
                't'
                {
                    Write-Debug -Message "Adding StickyBit."
                    [nxFileSystemSpecialMode]::StickyBit
                }

                's'
                {
                    if ($UserClass -eq [nxFileSystemUserClass]::User)
                    {
                        Write-Debug -Message "Adding SetUserId."
                        [nxFileSystemSpecialMode]::SetUserId
                    }

                    if ($UserClass -band [nxFileSystemUserClass]::Group)
                    {
                        Write-Debug -Message "Adding SetGroupId."
                        [nxFileSystemSpecialMode]::SetGroupId
                    }

                    if ((-not $UserClass -band [nxFileSystemUserClass]::Group) -and (-not $UserClass -eq [nxFileSystemUserClass]::User))
                    {
                        Write-Warning -Message "Cannot determine whether to set the SUID or SGID because the User class is invalid: '$UserClass'"
                    }
                }

                Default {
                    Write-Debug -Message "Nothing to return for char '$charItem'."
                }
            }
        }
    }
}
