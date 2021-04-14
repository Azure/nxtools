function New-nxLocalUser
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$')]
        [System.String]
        $UserName,

        [Parameter()]
        [System.String]
        [Alias('Password')]
        # The encrypted password, as returned by crypt(3).
        # Note: This option is not recommended because the password (or encrypted password) will be visible by users listing the processes.
        # You should make sure the password respects the system's password policy.
        $EncryptedPassword,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        # Any text string. It is generally a short description of the login, and is currently used as the field for the user's full name.
        [System.String]
        [Alias('Comment')]
        $UserInfo,

        [Parameter()]
        # The new user will be created using HOME_DIR as the value for the user's login directory.
        # The default is to append the LOGIN name to BASE_DIR and use that as the login directory name.
        # The directory HOME_DIR does not have to exist but will not be created if it is missing.
        [ValidateNotNullOrEmpty()]
        [System.String]
        $HomeDirectory,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias('shell')]
        # The name of the user's login shell.
        # The default is to leave this field blank, which causes the system to select the default login shell
        # specified by the SHELL variable in /etc/default/useradd, or an empty string by default.
        $ShellCommand,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [datetime]
        # The date on which the user account will be disabled. The date is specified in the format YYYY-MM-DD.
        # If not specified, useradd will use the default expiry date specified by the EXPIRE variable in /etc/default/useradd,
        # or an empty string (no expiry) by default.
        $ExpireOn,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        # The default base directory for the system if -d HOME_DIR is not specified. BASE_DIR is concatenated with the account name to define the home directory.
        # If the -m option is not used, BASE_DIR must exist.
        # If this option is not specified, useradd will use the base directory specified by the HOME variable in /etc/default/useradd, or /home by default.
        [System.String]
        $HomeDirectoryBase,

        [Parameter()]
        # The number of days after a password expires until the account is permanently disabled.
        # A value of 0 disables the account as soon as the password has expired,
        # and a value of -1 disables the feature.
        # If not specified, useradd will use the default inactivity period specified by the INACTIVE variable in /etc/default/useradd, or -1 by default.)
        [int]
        $DayPasswordExpiredBeforeAutoDisable,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        # The group name or number of the user's initial login group. The group name must exist.
        # A group number must refer to an already existing group.
        # If not specified, the bahavior of useradd will depend on the USERGROUPS_ENAB variable in /etc/login.defs.
        # If this variable is set to yes (or -U/--user-group is specified on the command line),
        # a group will be created for the user, with the same name as her loginname.
        # If the variable is set to no (or -N/--no-user-group is specified on the command line),
        # useradd will set the primary group of the new user to the value specified by the GROUP variable in /etc/default/useradd,
        # or 100 by default.
        [System.String]
        [Alias('GroupId')]
        $PrimaryGroup,

        [Parameter()]
        # A list of supplementary groups which the user is also a member of.
        # The groups are subject to the same restrictions as the group given with the -g option. The default is for the user to belong only to the initial group.
        [System.String[]]
        $SupplementaryGroup,

        [Parameter()]
        # Overrides /etc/login.defs defaults (UID_MIN, UID_MAX, UMASK, PASS_MAX_DAYS and others).
        # Example: -K PASS_MAX_DAYS=-1 can be used when creating system account to turn off password ageing, even though system account has no password at all.
        # Multiple -K options can be specified, e.g.: -K UID_MIN=100 -K UID_MAX=499
        # Note: -K UID_MIN=10,UID_MAX=499 doesn't work yet.
        [hashtable]
        $LoginDefsOverride,

        [Parameter()]
        # -M
        # Do not create the user's home directory, even if the system wide setting from /etc/login.defs (CREATE_HOME) is set to yes.
        [switch]
        $SkipCreateHomeDirectory,

        [Parameter()]
        [switch]
        # Do not add the user to the lastlog and faillog databases.
        # By default, the user's entries in the lastlog and faillog databases are resetted to avoid reusing the
        # entry from a previously deleted user.
        $NoLogInit,

        [Parameter()]
        # Do not create a group with the same name as the user, but add the user to the group specified
        # by the -g option or by the GROUP variable in /etc/default/useradd.
        # The default behavior (if the -g, -N, and -U options are not specified) is defined by the
        # USERGROUPS_ENAB variable in /etc/login.defs.
        [switch]
        $SkipCreateUserGroup,

        [Parameter()]
        # Allow the creation of a user account with a duplicate (non-unique) UID.
        # This option is only valid in combination with the -preferredUID option.
        [switch]
        $AllowNonUniqueUID,

        [Parameter()]
        # Create a system account.
        # System users will be created with no aging information in /etc/shadow,
        # and their numeric identifiers are choosen in the SYS_UID_MIN-SYS_UID_MAX range, defined in /etc/login.defs,
        # instead of UID_MIN-UID_MAX (and their GID counterparts for the creation of groups).
        # Note that useradd will not create a home directory for such an user,
        # regardless of the default setting in /etc/login.defs (CREATE_HOME).
        # You have to specify the -m options if you want a home directory for a system account to be created.
        [switch]
        $SystemAccount,

        [Parameter()]
        # The skeleton directory, which contains files and directories to be copied in the user's home directory,
        # when the home directory is created by useradd.
        # This option is only valid if the -m (or --create-home) option is specified.
        #
        # If this option is not set, the skeleton directory is defined by the SKEL variable in
        # /etc/default/useradd or, by default, /etc/skel.
        [String]
        $SkeletonDirectory,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # -R
        # Directory to chroot into
        $ChrootDirectory,

        [Parameter()]
        # Preferred UID if not already used (unless -AllowNonUniqueUID is used).
        [Int]
        [Alias('UserID', 'uid')]
        $preferredUID,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) -or $VerbosePreference -ne 'SilentlyContinue'
    }

    process {
        if ([nxLocalUser]::Exists($UserName))
        {
            throw ("A user account for '{0}' is already present." -f $UserName)
        }

        $userAddParams = @()

        if ($PSBoundParameters.ContainsKey('EncryptedPassword') -and $PSBoundParameters['EncryptedPassword'])
        {
            $userAddParams += @('-p', $EncryptedPassword)
        }

        if ($PSBoundParameters.ContainsKey('ShellCommand') -and $PSBoundParameters['ShellCommand'])
        {
            $userAddParams += @('-s', (Get-nxEscapedPath -Path $ShellCommand))
        }

        if ($PSBoundParameters.ContainsKey('HomeDirectory') -and $PSBoundParameters['HomeDirectory'])
        {
            $userAddParams += @('-d', (Get-nxEscapedPath -Path $HomeDirectory))
        }

        if ($PSBoundParameters.ContainsKey('UserInfo') -and $PSBoundParameters['UserInfo'])
        {
            $userAddParams += @('-c', $UserInfo)
        }

        if ($PSBoundParameters.ContainsKey('ExpireOn') -and $PSBoundParameters['ExpireOn'])
        {
            $userAddParams += @('-e', $ExpireOn.ToString('yyyy-MM-dd'))
        }

        if ($PSBoundParameters.ContainsKey('HomeDirectoryBase') -and $PSBoundParameters['HomeDirectoryBase'])
        {
            $userAddParams += @('-b', (Get-nxEscapedPath -Path $HomeDirectoryBase))
        }

        if ($PSBoundParameters.ContainsKey('DayPasswordExpiredBeforeAutoDisable') -and $PSBoundParameters['DayPasswordExpiredBeforeAutoDisable'])
        {
            $userAddParams += @('-f', $DayPasswordExpiredBeforeAutoDisable)
        }

        if ($PSBoundParameters.ContainsKey('PrimaryGroup') -and $PSBoundParameters['PrimaryGroup'])
        {
            $userAddParams += @('-f', $PrimaryGroup)
        }

        if ($PSBoundParameters.ContainsKey('NoLogInit') -and $PSBoundParameters['NoLogInit'])
        {
            $userAddParams += '-l'
        }

        if ($PSBoundParameters.ContainsKey('SkipCreateHomeDirectory') -and $PSBoundParameters['SkipCreateHomeDirectory'])
        {
            $userAddParams += '-M'
        }

        if ($PSBoundParameters.ContainsKey('SkipCreateUserGroup') -and $PSBoundParameters['SkipCreateUserGroup'])
        {
            $userAddParams += '-N'
        }
        else
        {
            # --user-group  create a group with the same name as the user (by default)
            $userAddParams += '-U'
        }

        if ($PSBoundParameters.ContainsKey('AllowNonUniqueUID') -and $PSBoundParameters['AllowNonUniqueUID'])
        {
            $userAddParams += '-o'
        }

        if ($PSBoundParameters.ContainsKey('SystemAccount') -and $PSBoundParameters['SystemAccount'])
        {
            $userAddParams += '-r'
        }

        if ($PSBoundParameters.ContainsKey('SkeletonDirectory') -and $PSBoundParameters['SkeletonDirectory'])
        {
            $userAddParams += @('-k', $SkeletonDirectory)
        }

        if ($PSBoundParameters.ContainsKey('ChrootDirectory') -and $PSBoundParameters['ChrootDirectory'])
        {
            $userAddParams += @('-R', $ChrootDirectory)
        }

        if ($PSBoundParameters.ContainsKey('SupplementaryGroup') -and $PSBoundParameters['SupplementaryGroup'])
        {
            $userAddParams += @('-G', ($SupplementaryGroup -join ','))
        }

        if ($PSBoundParameters.ContainsKey('preferredUID') -and $PSBoundParameters['preferredUID'])
        {
            $userAddParams += @('-u', $preferredUID)
        }

        # LoginDefsOverride
        if ($PSBoundParameters.ContainsKey('LoginDefsOverride') -and $PSBoundParameters['LoginDefsOverride'])
        {
            $LoginDefsOverride.Keys.ForEach({
                $userAddParams += ('-K {0}={1}' -f $_, $LoginDefsOverride[$_])
            })
        }

        if ($PScmdlet.ShouldProcess("Performing the unix command 'useradd $(($userAddParams + @($UserName)) -join ' ')'.", "$UserName", "Adding LocalUser to $(hostname)"))
        {
            Invoke-NativeCommand -Executable 'useradd' -Parameter ($userAddParams + @($UserName)) -Verbose:$verbose -ErrorAction 'Stop' | Foreach-Object {
                throw $_
            }

            if ($PSBoundParameters.ContainsKey('PassThru') -and $PSBoundParameters['PassThru'])
            {
                # return the created user
                Get-nxLocalUser -UserName $Username -ErrorAction Stop
            }
        }
    }
}
