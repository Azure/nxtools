function Convert-nxSymbolToFileSystemUserClass
{
    [CmdletBinding()]
    [OutputType([nxFileSystemUserClass])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [char[]]
        $Char
    )

    process {
        foreach ($charItem in $char)
        {
            switch ($charItem)
            {
                'u' { [nxFileSystemUserClass]'User'   }
                'g' { [nxFileSystemUserClass]'Group'  }
                'o' { [nxFileSystemUserClass]'Others' }
                'a' { [nxFileSystemUserClass]'User, Group, Others' }
                default { throw "Unexpected char '$CharItem'" }
            }
        }
    }
}
