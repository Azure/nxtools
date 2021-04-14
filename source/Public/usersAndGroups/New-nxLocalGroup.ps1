function New-nxLocalGroup
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$')]
        [System.String]
        [Alias('Group','Name')]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.String]
        [Alias('Password')]
        # The encrypted password, as returned by crypt(3).
        # Note: This option is not recommended because the password (or encrypted password) will be visible by users listing the processes.
        # You should make sure the password respects the system's password policy.
        $EncryptedPassword,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        # Overrides /etc/login.defs defaults (UID_MIN, UID_MAX, UMASK, PASS_MAX_DAYS and others).
        # Example: -K PASS_MAX_DAYS=-1 can be used when creating system account to turn off password ageing, even though system account has no password at all.
        # Multiple -K options can be specified, e.g.: -K UID_MIN=100 -K UID_MAX=499
        # Note: -K UID_MIN=10,UID_MAX=499 doesn't work yet.
        [hashtable]
        $LoginDefsOverride,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        # Allow the creation of a group with a duplicate (non-unique) GID.
        # This option is only valid in combination with the -preferredGID option.
        [switch]
        $AllowNonUniqueGID,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        # Create a system group.
        [switch]
        $SystemAccount,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # -R
        # Directory to chroot into
        $ChrootDirectory,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        # Preferred GID if not already used (unless -AllowNonUniqueUID is used).
        [Int]
        [Alias('GroupID', 'GID')]
        $preferredGID,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Force,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $PassThru
    )

    begin
    {
        $verbose = $PSBoundParameters.ContainsKey('verbose') -and $PSBoundParameters['Verbose']
    }

    process
    {
        if ([nxLocalGroup]::Exists($GroupName))
        {
            throw ("A group account named '{0}' is already present." -f $GroupName)
        }

        $groupAddParams = @()

        if ($PSBoundParameters.ContainsKey('Force') -and $PSBoundParameters['Force'])
        {
            $groupAddParams += @('-f')
        }

        if ($PSBoundParameters.ContainsKey('EncryptedPassword') -and $PSBoundParameters['EncryptedPassword'])
        {
            $groupAddParams += @('-p', $EncryptedPassword)
        }

        if ($PSBoundParameters.ContainsKey('AllowNonUniqueGID') -and $PSBoundParameters['AllowNonUniqueGID'])
        {
            $groupAddParams += '-o'
        }

        if ($PSBoundParameters.ContainsKey('SystemAccount') -and $PSBoundParameters['SystemAccount'])
        {
            $groupAddParams += '-r'
        }

        if ($PSBoundParameters.ContainsKey('ChrootDirectory') -and $PSBoundParameters['ChrootDirectory'])
        {
            $groupAddParams += @('-R', $ChrootDirectory)
        }

        if ($PSBoundParameters.ContainsKey('preferredGID') -and $PSBoundParameters['preferredGID'])
        {
            $groupAddParams += @('-g', $preferredGID)
        }

        # LoginDefsOverride
        if ($PSBoundParameters.ContainsKey('LoginDefsOverride') -and $PSBoundParameters['LoginDefsOverride'])
        {
            $LoginDefsOverride.Keys.ForEach({
                $groupAddParams += ('-K {0}={1}' -f $_, $LoginDefsOverride[$_])
            })
        }

        if ($PScmdlet.ShouldProcess("Performing the unix command 'groupadd $(($groupAddParams + @($GroupName)) -join ' ')'.", "$GroupName", "Adding LocalUser to $(hostname)"))
        {
            Invoke-NativeCommand -Executable 'groupadd' -Parameter ($groupAddParams + @($GroupName)) -Verbose:$verbose -ErrorAction 'Stop' | Foreach-Object {
                throw $_
            }

            if ($PSBoundParameters.ContainsKey('PassThru') -and $PSBoundParameters['PassThru'])
            {
                # return the created group
                Get-nxLocalGroup -GroupName $GroupName -ErrorAction Stop
            }
        }
    }
}
