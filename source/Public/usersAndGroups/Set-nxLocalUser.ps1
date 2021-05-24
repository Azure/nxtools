function Set-nxLocalUser
{
    [CmdletBinding(DefaultParameterSetName = 'ParameterizedGECOSAddGroupExpireOn', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    param
    (

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.String]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [System.String]
        # compose with Description and build for -c
        $FullName,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [System.String]
        # same as above
        $Office,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [System.String]
        # same as above
        $OfficePhone,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [System.String]
        # same as above
        $HomePhone,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [System.String]
        # same as above
        $Description,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias('Password')]
        # -p
        $EncryptedPassword,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.Management.Automation.SwitchParameter]
        # -L
        $Locked,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [ValidateNotNullOrEmpty()]
        [datetime]
        # The date on which the user account will be disabled. The date is specified in the format YYYY-MM-DD.
        # If not specified, useradd will use the default expiry date specified by the EXPIRE variable in /etc/default/useradd,
        # or an empty string (no expiry) by default.
        $ExpireOn,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.Management.Automation.SwitchParameter]
        $RequirePasswordChange,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [int]
        # -u
        $UserID,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [int]
        # -g
        $PrimaryGroup,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.String[]]
        # -a  -G
        $GroupToSet,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.String[]]
        # -a  -G
        $GroupToAdd,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.String]
        [Alias('GECOS')]
        # Set new value for GECOS field
        $UserInfo,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.String]
        # -d
        $HomeDirectory,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.Management.Automation.SwitchParameter]
        # -m only when -HomeDirectory is used
        $MoveHomeToNewHomeDirectory,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParameterizedGECOSSetGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSAddGroupRequirePwdChange')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupExpireOn')]
        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'GECOSSetGroupRequirePwdChange')]
        [System.String]
        # -s
        $ShellCommand
    )

    begin
    {
        $verbose = $VerbosePreference -or ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose'])
    }

    process
    {
        $usermodParams = @()

        # Do we need to set the GECOS field?
        $compareObjectParams = @{
            ReferenceObject  = $PSBoundParameters.Keys
            DifferenceObject = @(
                'FullName'
                'Office'
                'OfficePhone'
                'HomePhone'
                'Description'
            )
            IncludeEqual     = $true
            ExcludeDifferent = $true
        }

        $ShouldChangeGECOS = $null -ne (Compare-Object @compareObjectParams)

        if (
            $PSCmdlet.ParameterSetName -match 'ParameterizedGECOS' -and
            $ShouldChangeGECOS
        )
        {
            $existingUser = Get-nxLocalUser -UserName $UserName -ErrorAction 'SilentlyContinue'
            $FullNameToSet = $existingUser.FullName
            $OfficeToSet = $existingUser.Office
            $OfficePhoneToSet = $existingUser.OfficePhone
            $HomePhoneToSet = $existingUser.HomePhone
            $DescriptionToSet = $existingUser.Description

            switch ($PSBoundParameters.keys)
            {
                'FullName'
                {
                    $FullNameToSet = $FullName
                }

                'Office'
                {
                    $OfficeToSet = $Office
                }

                'OfficePhone'
                {
                    $OfficePhoneToSet = $OfficePhone
                }

                'HomePhone'
                {
                    $HomePhoneToSet = $HomePhone
                }

                'Description'
                {
                    $DescriptionToSet = $Description
                }
            }

            $gecosField = '{0},{1},{2},{3},{4}' -f $FullNameToSet, $OfficeToSet, $OfficePhoneToSet, $HomePhoneToSet, $DescriptionToSet
            $usermodParams += @('-c', ($gecosField | Get-nxEscapedString))
        }
        elseif ($PSBoundParameters.ContainsKey('UserInfo'))
        {
            $usermodParams += @('-c', ($UserInfo | Get-nxEscapedString))
        }

        if ($PSBoundParameters.ContainsKey('EncryptedPassword'))
        {
            $usermodParams += @('-p', ($EncryptedPassword | Get-nxEscapedString))
        }

        if ($Locked.IsPresent)
        {
            $usermodParams += @('-L')
        }

        if ($PSBoundParameters.ContainsKey('ExpireOn') -and $PSBoundParameters['ExpireOn'])
        {
            $userAddParams += @('-e', $ExpireOn.ToString('yyyy-MM-dd'))
        }
        elseif ($RequirePasswordChange.IsPresent)
        {
            # Set the password as Expired
            $yesterday = ([DateTime]::Now).AddDays(-1)

            $usermodParams = @('-e', $yesterday.ToString('yyyy-MM-dd'))
        }

        if ($PSBoundParameters.ContainsKey('UserID'))
        {
            $usermodParams += @('-u', $UserID)
        }

        if ($PSBoundParameters.ContainsKey('PrimaryGroup'))
        {
            $usermodParams += @('-g', $PrimaryGroup)
        }

        if ($PSBoundParameters.ContainsKey('GroupToSet'))
        {
            $usermodParams += @('-G', $GroupToSet)
        }
        elseif ($PSBoundParameters.ContainsKey('GroupToAdd'))
        {
            $usermodParams += @('-a','-G', $($GroupToAdd -join ','))
        }

        if ($PSBoundParameters.ContainsKey('HomeDirectory'))
        {
            $usermodParams += @('-d', ($HomeDirectory | Get-nxEscapedPath))

            if ($MoveHomeToNewHomeDirectory.IsPresent)
            {
                $usermodParams += @('-m')
            }
        }

        if ($PSBoundParameters.ContainsKey('ShellCommand'))
        {
            $usermodParams += @('-s', ($ShellCommand | Get-nxEscapedPath))
        }

        $usermodParams += @($UserName)

        if ($PSCmdlet.ShouldProcess(
                "Performing the unix command 'usermod $(($usermodParams -join ' '))'.",
                $UserName,
                "Setting LocalUser $UserName"
            )
        )
        {
            Invoke-NativeCommand -Executable 'usermod' -Parameters $usermodParams -Verbose:$verbose | ForEach-Object -Process {
                if ($_ -match '^usermod:')
                {
                    Write-Error $_
                }
                else
                {
                    Write-Verbose -Message "$_"
                }
            }
        }
    }
}
