function Expand-nxArchive
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        $Path,

        [Parameter()]
        [String]
        [ValidateNotNullOrEmpty()]
        [Alias('ExtractTo')]
        $Destination,

        [Parameter()]
        [nxArchiveAlgorithm[]]
        $Compression = 'Auto',

        [Parameter()]
        [Switch]
        $ListOnly,

        [Parameter()]
        [Switch]
        $Force
    )

    begin
    {
        $verbose = $VerbosePreference -ne 'SilentlyContinue' -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
        $tarParams = @()

        $tarVerbose = ''
        if ($verbose)
        {
            $tarVerbose = 'v'
        }

        if ($ListOnly.IsPresent)
        {
            $tarParams += @('-t{0}' -f $tarVerbose)
        }
        else
        {
            $tarParams += @('-x{0}' -f $tarVerbose)
        }

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

        if ($decompressWith.Count -gt 0)
        {
            $tarParams += @(('-{0}' -f ($decompressWith -join '')))
        }
        else
        {
            Write-Debug -Message "Auto compression detection for $Destination."
        }

        if ($PSBoundParameters.ContainsKey('Destination'))
        {
            $tarParams += @('-C', $Destination)
            if ($Force.IsPresent -and -not (Test-Path -Path $Destination))
            {
                $null = New-Item -Path $Destination -ItemType Directory -Force
            }
        }
    }

    process
    {

        foreach ($pathItem in $Path)
        {
            $tarParams += @('-f', (Get-nxEscapedPath -Path $pathItem))

            if ($PSCmdlet.ShouldProcess(
                "Extracting using the unix command 'tar $($tarParams -join ' ')'.",
                $pathItem,
                "Extracting '$pathItem' to '$Destination'.")
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
                            if ($_ -is [String] -and $ListOnly.IsPresent)
                            {
                                $_
                            }
                            else
                            {
                                Write-Verbose -Message $_
                            }
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
}
