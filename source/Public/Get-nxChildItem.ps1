function Get-nxChildItem
{
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType([nxFileSystemInfo[]])]
    param
    (
        [Parameter(ParameterSetName = 'default'         , Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'FilterDirectory' , Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'FilterFile'      , Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        $Path = '.',

        [Parameter(ParameterSetName = 'default'         , Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'FilterDirectory' , Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'FilterFile'      , Position = 1, ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $Recurse,

        [Parameter(ParameterSetName = 'FilterDirectory' , ValueFromPipelineByPropertyName = $true, Position = 2)]
        [Switch]
        $Directory,

        [Parameter(ParameterSetName = 'FilterFile'      , ValueFromPipelineByPropertyName = $true, Position = 2)]
        [Switch]
        $File
    )

    begin
    {
        $lsParams  = @('-Al','--full-time','--group-directories-first')

        if ($PSBoundParameters.ContainsKey('Recurse') -and $PSboundParameters['Recurse'])
        {
            $lsParams += '-R' # Alpine linux does not support --recursive
        }
    }

    process
    {
        foreach ($pathItem in $Path.Where{$_})
        {
            $pathItem = [System.IO.Path]::GetFullPath($pathItem, $PWD.Path)
            $unfilteredListCommand = {
                Invoke-NativeCommand -Executable 'ls' -Parameters ($lsParams + @($pathItem)) | Convert-nxLsEntryToFileSystemInfo -InitialPath $pathItem
            }

            if ($PSCmdlet.ParameterSetName -eq 'FilterFile' -and $PSBoundParameters['File'])
            {
                &$unfilteredListCommand | Where-Object -FilterScript { $_.nxFileSystemItemType -eq [nxFileSystemItemType]::File }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'FilterDirectory' -and $PSBoundParameters['Directory'])
            {
                &$unfilteredListCommand | Where-Object -FilterScript { $_.nxFileSystemItemType -eq [nxFileSystemItemType]::Directory }
            }
            else
            {
                &$unfilteredListCommand
            }
        }
    }
}
