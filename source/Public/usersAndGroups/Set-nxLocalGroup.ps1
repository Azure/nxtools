function Set-nxLocalGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'removePassword')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'restrict')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'setMemberOrAdmin')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'setMember')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'setAdmin')]
        [String]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'removePassword')]
        [Switch]
        $RemovePassword,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'restrict')]
        [Switch]
        $Restrict,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'setMemberOrAdmin')]
        [String[]]
        $Member,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'setMemberOrAdmin')]
        [String[]]
        $Administrators,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'removePassword')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'restrict')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'setMemberOrAdmin')]
        [switch]
        $PassThru
    )

    begin
    {
        $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) -or $VerbosePreference -ne 'SilentlyContinue'
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'setMemberOrAdmin' -and -not ($PSBoundParameters.ContainsKey('Administrators') -or $PSBoundParameters.ContainsKey('Member')))
        {
            throw "Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an insufficient number of parameters were provided."
            return
        }

        $gpasswdParams = @()

        if ($PSBoundParameters.ContainsKey('RemovePassword') -and $PSBoundParameters['RemovePassword'])
        {
            $gpasswdParams += @('-r')
        }

        if ($PSBoundParameters.ContainsKey('Restrict') -and $PSBoundParameters['Restrict'])
        {
            $gpasswdParams += @('-R')
        }

        if ($PSBoundParameters.ContainsKey('Member') -and $PSBoundParameters['Member'])
        {
            $gpasswdParams += @('-M', ($Member -join ','))
        }

        if ($PSBoundParameters.ContainsKey('Administrators') -and $PSBoundParameters['Administrators'])
        {
            $gpasswdParams += @('-A', ($Administrators -join ','))
        }

        $gpasswdParams += @($GroupName)

        if ($PSCmdlet.ShouldProcess(
                "Performing the unix command 'gpasswd $(($gpasswdParams -join ' '))'.",
                "$GroupName",
                "Setting LocalGroup $GroupName"
            )
        )
        {
            Invoke-NativeCommand -Executable 'gpasswd' -Parameters $gpasswdParams -Verbose:$verbose -ErrorAction 'Stop' | ForEach-Object -Process {
                if ($_ -match '^gpasswd:')
                {
                    throw $_
                }
                else
                {
                    Write-Verbose -Message "$_"
                }
            }

            if ($PSBoundParameters.ContainsKey('PassThru') -and $PSBoundParameters['PassThru'])
            {
                # return the group
                Get-nxLocalGroup -GroupName $GroupName -ErrorAction Stop
            }
        }
    }
}
