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
        $lsParams  = @('-Al','--full-time','--group-directories-first','-d')
    }

    process
    {
        foreach ($pathItem in $Path.Where{$_})
        {
            $pathItem = [System.IO.Path]::GetFullPath($pathItem, $PWD.Path)
            Invoke-NativeCommand -Executable 'ls' -Parameters ($lsParams + @($pathItem)) | Convert-nxLsEntryToFileSystemInfo -InitialPath $pathItem
        }
    }
}
