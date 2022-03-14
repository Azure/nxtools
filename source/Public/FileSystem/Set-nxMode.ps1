function Set-nxMode
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default', Position = 0)]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll', Position = 0)]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath', Position = 0)]
        [System.String[]]
        $Path,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default', Position = 1)]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll', Position = 1)]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath', Position = 1)]
        [nxFileSystemMode]
        $Mode,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [System.Management.Automation.SwitchParameter]
        # affect each symbolic link instead of any referenced file (useful only on systems that can change the ownership of a symlink)
        # -h
        $NoDereference,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [System.Management.Automation.SwitchParameter]
        # Do not traverse any symbolic links  by default
        $Recurse,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [System.Management.Automation.SwitchParameter]
        # Traverse every symbolic link to a directory encountered
        # -L
        $RecursivelyTraverseSymLink,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [System.Management.Automation.SwitchParameter]
        # If $Path is a symbolic link to a directory, traverse it.
        # -H
        $OnlyTraversePathIfSymLink,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [System.Management.Automation.SwitchParameter]
        # Disable root preservation security.
        $Force
    )

    begin {
        $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose) -or $VerbosePreference -ne 'SilentlyContinue'
    }

    process {
        foreach ($pathItem in $Path)
        {
            $pathItem = [System.Io.Path]::GetFullPath($pathItem, $PWD.Path)

            $chmodParams = @()

            if ($PSBoundParameters.ContainsKey('NoDereference') -and $PSBoundParameters['NoDereference'])
            {
                $chmodParams += '-h'
            }

            if ($PSBoundParameters.ContainsKey('RecursivelyTraverseSymLink') -and $PSBoundParameters['RecursivelyTraverseSymLink'])
            {
                $chmodParams += '-L'
            }

            if ($PSBoundParameters.ContainsKey('OnlyTraversePathIfSymLink') -and $PSBoundParameters['OnlyTraversePathIfSymLink'])
            {
                $chmodParams += '-H'
            }

            if ($PSBoundParameters.ContainsKey('Recurse') -and $PSBoundParameters['Recurse'])
            {
                $chmodParams += '-R'
            }

            $OctalMode = $Mode.ToOctal()
            $chmodParams = ($chmodParams + @($OctalMode, $pathItem))

            Write-Debug "Parameter Set Name: '$($PSCmdlet.ParameterSetName)'."

            if (
                $PSCmdlet.ShouldProcess("Performing the unix command 'chmod $($chmodParams -join ' ')'.", $PathItem, "chmod $($chmodParams -join ' ')")
            )
            {
                if ($pathItem -eq '/' -and -not ($PSBoundParameters.ContainsKey('Force') -and $Force))
                {
                    # can't use the built-in --preserve-root because it's not available on Alpine linux
                    Write-Warning "You are about to chmod your root. Please use -Force."
                    return
                }

                Write-Verbose -Message ('chmod {0}' -f ($chmodParams -join ' '))
                Invoke-NativeCommand -Executable 'chmod' -Parameters $chmodParams -Verbose:$verbose -ErrorAction 'Stop'  | Foreach-Object -Process {
                    Write-Error -Message $_
                }
            }
        }
    }
}
