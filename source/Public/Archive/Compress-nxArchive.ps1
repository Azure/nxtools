
<#
.SYNOPSIS
Command to tar or archive files and folders using the GNU 'tar' command.

.DESCRIPTION
This command saves files and folders together in a single archive, with optional compression.
The command is a wrapper for the command 'tar' that ought to be availble on the system to
be able to use the command.

.PARAMETER Path
Array of Path to the files and folder to add to the archive.

.PARAMETER Destination
Destination of the archive to create or to add the file and folders to.

.PARAMETER Compression
Specify the type of compression to use for the archive: auto, bzip2, xz, lzma, gzip.
By default, the compression is set to 'auto' where the tar command will try to discover what
to use based on the file's extension.

.PARAMETER Exclude
Array of Patterns used to exclude any file matching any of those patterns.

.PARAMETER FollowSymLinks
Follow symlinks to archive the files they refer to.

.PARAMETER Force
Force create the Destination folder if it does not exist.

.EXAMPLE
Compress-nxArchive -Path .\home -Destination ./bkp/homedirs.bzip

.NOTES
If you use the -Verbose parameter, you can see what command is invoked and its parameters.
#>

function Compress-nxArchive
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        [Alias('FullName')]
        $Path,

        [Parameter(Mandatory = $true)]
        [String]
        $Destination,

        [Parameter()]
        [nxArchiveAlgorithm[]]
        $Compression = 'Auto',

        [Parameter()]
        [String[]]
        $Exclude,

        [Parameter()]
        [switch]
        $FollowSymLinks,

        [Parameter()]
        [Switch]
        $Force
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])

        $tarVerbose = ''
        if ($verbose)
        {
            $tarVerbose = 'v'
        }

        $tarParams = @('-c{0}' -f $tarVerbose)

        $compressWith = @()

        switch ($Compression)
        {
            'auto'
            {
                Write-Debug -Message 'Skipping algo. Letting Tar discover using the file extension.'
                break
            }

            'bzip2'
            {
                $compressWith += @('j')
            }

            'xz'
            {
                $compressWith += @('J')
            }

            'lzma'
            {
                $compressWith += @('a')
            }

            'gzip'
            {
                $compressWith += @('z')
            }
        }

        if ($compressWith.Count -gt 0)
        {
            $tarParams += @(('-{0}' -f ($compressWith -join '')))
        }
        else
        {
            Write-Debug -Message "Auto compression detection for '$Destination'."
        }

        if ($PSBoundParameters.ContainsKey('Destination'))
        {
            $tarParams += @('-f', (Get-nxEscapedString -String $Destination))
            $destinationParent = Split-Path -Parent -Path ([io.Path]::GetFullPath($Destination))
            if ($Force.IsPresent -and -not (Test-Path -Path $destinationParent))
            {
                $null = New-Item -Path $destinationParent -Force
            }
        }

        if ($FollowSymLinks.IsPresent)
        {
            $tarParams += @('-h')
        }

        foreach ($excludePattern in $Exclude)
        {
            $tarParams += @('--exclude', (Get-nxEscapedString -String $excludePattern))
        }
    }

    process
    {
        foreach ($PathItem in $Path)
        {
            Write-Debug -Message "Preparing to compress $PathItem..."
            $tarParams += @($PathItem)
        }
    }

    end
    {
        if ($PSCmdlet.ShouldProcess(
            "Compressing using the unix command 'tar $($tarParams -join ' ')'.",
            $UserNameItem,
            "Compressing [$($Path -join ',')] to '$Destination'.")
        )
        {
            Invoke-NativeCommand -Executable 'tar' -Parameters $tarParams -Verbose:$verbose |
                ForEach-Object -Process {
                    if ($_ -match '^tar:')
                    {
                        Write-Error $_
                    }
                    else
                    {
                        Write-Verbose -Message $_
                    }
                }

            $destinationFullName = [io.Path]::GetFullPath($Destination)
            if (Test-Path -Path $destinationFullName)
            {
                $destinationFullName
            }
        }
    }
}
