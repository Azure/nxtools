function Add-nxLocalGroupMember
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]
        [ValidateNotNullOrEmpty()]
        $GroupName,

        [Parameter()]
        [String]
        [ValidateNotNullOrEmpty()]
        $PrimaryGroupName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        [ValidateNotNullOrEmpty()]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $PassThru
    )

    begin
    {
        $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) -or $VerbosePreference -ne 'SilentlyContinue'
    }

    process
    {
        $userModParams = @('-a', '-G')

        $userModParams += @($GroupName -join ',')


        if ($PSBoundParameters.ContainsKey('PrimaryGroupName'))
        {
            $userModParams += @('-g', $PrimaryGroupName)
        }

        $userModParams += @($UserName)

        if (
            $PScmdlet.ShouldProcess(
                "Performing the unix command 'usermod $(($userModParams -join ' '))'.",
                $UserName,
                "adding $userName to groups: '$($groupName -join ',')."
            )
        )
        {
            Invoke-NativeCommand -Executable 'usermod' -Parameters $userModParams -Verbose:$verbose -ErrorAction 'Stop' | ForEach-Object -Process {
                throw $_
            }

            if ($PSBoundParameters.ContainsKey('PassThru') -and $PSBoundParameters['PassThru'])
            {
                # return the created user
                Get-nxLocalUser -UserName $Username -ErrorAction Stop -Verbose:$verbose
            }
        }
    }
}
