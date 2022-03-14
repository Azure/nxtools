function Convert-nxLsEntryToFileSystemInfo
{
    [CmdletBinding()]
    [OutputType([nxFileSystemInfo])]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]
        $lsLine,

        [Parameter()]
        [System.String]
        $InitialPath = '.',

        [Parameter()]
        [scriptblock]
        $ErrorHandler = {
            switch -Regex ($_)
            {
                default { Write-Error -Message $_ }
            }
        }
    )

    begin {
        $lastParent = $null
    }

    process {
        foreach ($lineToParse in $lsLine.Where{$_})
        {
            Write-Verbose -Message "Parsing ls line output: '$lineToParse'."

            if ($lineToParse -is [System.Management.Automation.ErrorRecord])
            {
                Write-Debug -Message 'Dispatching to ErrorHandler...'
                $lineToParse | &$ErrorHandler
            }
            elseif ($lineToParse -match '^/.*ls:\s(?<message>.*)')
            {
                Write-Error -Message $Matches.message
            }
            elseif ($lineToParse -match '^\s*total')
            {
                Write-Verbose -Message $lineToParse
            }
            elseif ($lineToParse -match '^(?<parent>/.*):$')
            {
                $lastParent = $Matches.parent
            }
            else
            {
                $Mode, $nxLinkCount, $nxOwner, $nxGroup, $Length, $lastModifyDate, $lastModifyTime, $lastModifyTimezone, $fileName = $lineToParse -split '\s+',9
                $nxFileSystemItemType = switch ($Mode[0])
                {
                    '-' { 'File' }
                    'd' { 'Directory' }
                    'l' { 'Link' }
                    'p' { 'Pipe' }
                    's' { 'socket' }
                }

                $lastWriteTime = Get-Date -Date ($lastModifyDate + " " + $lastModifyTime + $lastModifyTimezone)

                # Maybe there's no $lastParent yet (top folder from search Path)
                if ($null -eq $lastParent)
                {
                    if ($InitialPath -eq [io.Path]::GetFullPath($fileName, $PWD.Path))
                    {
                        Write-Debug -Message "No `$lastParent and Initial path is '$InitialPath' same as file name is '$fileName'."
                        # no Last parent and the InitialPath is the same as the file Name. (i.e. ./CHANGELOG.md or CHANGELOG.md)
                        $lastParent = [io.path]::GetFullPath("$InitialPath/..")
                    }
                    else
                    {
                        $lastParent = [io.Path]::GetFullPath($InitialPath)
                    }

                    $fullPath = [io.Path]::GetFullPath($fileName, $lastParent)
                }
                else
                {
                    Write-Debug -Message "`$lastParent is '$lastParent', Initial Path is '$InitialPath' and file name is '$fileName'."
                    $fullPath = [io.path]::GetFullPath($fileName, $lastParent)
                }

                [nxFileSystemInfo]::new(
                    @{
                        FullPath                = $fullPath
                        LastWriteTime           = $lastWriteTime
                        nxFileSystemItemType    = $nxFileSystemItemType
                        nxOwner                 = $nxOwner
                        nxGroup                 = $nxGroup
                        Length                  = [long]::Parse($Length)
                        nxLinkCount             = $nxLinkCount
                        Mode                    = $Mode
                    }
                )
            }
        }
    }
}
