function Set-nxOwner
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'Default')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [System.String[]]
        $Path,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias('UserName')]
        $Owner,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Group,

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

            $chownParams = @()

            if ($PSBoundParameters.ContainsKey('NoDereference') -and $PSBoundParameters['NoDereference'])
            {
                $chownParams += '-h'
            }

            if ($PSBoundParameters.ContainsKey('RecursivelyTraverseSymLink') -and $PSBoundParameters['RecursivelyTraverseSymLink'])
            {
                $chownParams += '-L'
            }

            if ($PSBoundParameters.ContainsKey('OnlyTraversePathIfSymLink') -and $PSBoundParameters['OnlyTraversePathIfSymLink'])
            {
                $chownParams += '-H'
            }

            if ($PSBoundParameters.ContainsKey('Recurse') -and $PSBoundParameters['Recurse'])
            {
                $chownParams += '-R'
            }

            if ($PSBoundParameters.ContainsKey('Group'))
            {
                $Owner = '{0}:{1}' -f $Owner,$Group
            }

            $chownParams = ($chownParams + @($Owner, $pathItem))

            if (
                $PSCmdlet.ShouldProcess("Performing the unix command 'chown $($chownParams -join ' ')'.", $PathItem, "chown $($chownParams -join ' ')")
            )
            {
                if ($pathItem -eq '/' -and -not ($PSBoundParameters.ContainsKey('Force') -and $Force))
                {
                    # can't use the built-in --preserve-root because it's not available on Alpine linux
                    Write-Warning "You are about to chown your root. Please use -Force."
                    return
                }

                Write-Verbose -Message ('chown {0}' -f ($chownParams -join ' '))
                Invoke-NativeCommand -Executable 'chown' -Parameters $chownParams -Verbose:$verbose | Foreach-Object -Process {
                    Write-Error -Message $_
                }
            }
        }
    }
}
