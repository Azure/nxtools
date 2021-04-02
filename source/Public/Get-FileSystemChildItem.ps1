function Get-FileSystemChildItem
{
    param
    (
        [Parameter()]
        [System.String[]]
        $Path = '.',

        [Parameter()]
        [Switch]
        $Recurse,

        [Parameter()]
        [Switch]
        $Directory
    )

    begin
    {
        $lsParams  = @('-Al','--full-time','--group-directories-first')

        switch ($PSboundParameters.keys)
        {
            'Recurse'   { $lsParams += '--recursive' }
            'Directory' { $lsParams += '-d' }
            Default     { Write-Debug -Message "Parameter '$_' not added automatically." }
        }
    }

    process
    {
        foreach ($pathItem in $Path.Where{$_})
        {
            $pathItem = [System.IO.Path]::GetFullPath($pathItem, $PWD.Path)
            Invoke-NativeCommand -Executable 'ls' -Parameters ($lsParams + @($pathItem)) | Convert-lsEntryToFileSystemInfo -InitialPath $pathItem
        }
    }
}
