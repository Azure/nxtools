function Convert-FileSystemUserClassToSymbol
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [nxFileSystemUserClass]
        [Alias('Class')]
        $UserClass
    )

    $symbols = switch ($UserClass)
    {
        ([nxFileSystemUserClass]::User)   { 'u' }
        ([nxFileSystemUserClass]::Group)  { 'g' }
        ([nxFileSystemUserClass]::Others) { 'o' }
    }

    return ($symbols -join '')
}
