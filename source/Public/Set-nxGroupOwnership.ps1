function Set-nxGroupOwnership
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

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursiveAll')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'RecursivePath')]
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

    process {
        foreach ($pathItem in $Path)
        {
            $pathItem = [System.Io.Path]::GetFullPath($pathItem, $PWD.Path)

            $chgrpParams = @()

            if ($PSBoundParameters.ContainsKey('NoDereference') -and $PSBoundParameters['NoDereference'])
            {
                $chgrpParams += '-h'
            }

            if ($PSBoundParameters.ContainsKey('RecursivelyTraverseSymLink') -and $PSBoundParameters['RecursivelyTraverseSymLink'])
            {
                $chgrpParams += '-L'
            }

            if ($PSBoundParameters.ContainsKey('OnlyTraversePathIfSymLink') -and $PSBoundParameters['OnlyTraversePathIfSymLink'])
            {
                $chgrpParams += '-H'
            }

            if ($PSBoundParameters.ContainsKey('Recurse') -and $PSBoundParameters['Recurse'])
            {
                $chgrpParams += '-R'
            }

            $chgrpParams = ($chgrpParams + @($Group, $pathItem))

            if (
                $PSCmdlet.ShouldProcess("Performing the unix command 'chgrp $($chgrpParams -join ' ')'.", $PathItem, "chgrp $($chgrpParams -join ' ')")
            )
            {
                if ($pathItem -eq '/' -and -not ($PSBoundParameters.ContainsKey('Force') -and $Force))
                {
                    # can't use the built-in --preserve-root because it's not available on Alpine linux
                    Write-Warning "You are about to chgrp your root. Please use -Force."
                    return
                }

                Write-Verbose -Message ('chgrp {0}' -f ($chgrpParams -join ' '))
                Invoke-NativeCommand -Executable 'chgrp' -Parameters $chgrpParams | Foreach-Object -Process {
                    Write-Error -Message $_
                }
            }
        }
    }
}
