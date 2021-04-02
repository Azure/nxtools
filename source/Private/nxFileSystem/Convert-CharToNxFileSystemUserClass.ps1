function Convert-CharTonxFileSystemUserClass
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
                Default { throw "Unexpected char '$CharItem'" }
            }
        }
    }
}
