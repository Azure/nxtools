function Get-nxItem
{
    param
    (
        [Parameter()]
        [System.String[]]
        $Path = '.'
    )

    begin
    {
        $verbose   = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) -or $VerbosePreference -ne 'SilentlyContinue'
        $debug     = ($PSBoundParameters.ContainsKey('Debug') -and $PSBoundParameters['Debug']) -or $DebugPreference -ne 'SilentlyContinue'
        $lsParams  = @('-Al','--full-time','--group-directories-first','-d')
    }

    process
    {
        foreach ($pathItem in $Path.Where{$_})
        {
            $pathItem = [System.IO.Path]::GetFullPath($pathItem, $PWD.Path)
            Invoke-NativeCommand -Executable 'ls' -Parameters ($lsParams + @($pathItem)) -Verbose:($verbose -or $debug) |
                Convert-nxLsEntryToFileSystemInfo -InitialPath $pathItem -Verbose:$debug
        }
    }
}
