class nxEtcShadowEntry
{
    hidden static [regex] $EtcShadowLineParser = @(
        '^(?<username>[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$))'
        '(?<password>[^:]*)'
        '(?<lastchanged>[^:]*)'
        '(?<min>[^:]*)'
        '(?<max>[^:]*)'
        '(?<warn>[^:]*)'
        '(?<inactive>[^:]*)'
        '(?<expire>[^:]*)'
        '(?<other>[^:]*)'
    ) -join ':'

    hidden [string] $ShadowEntry
    [string] $Username
    [string] $EncryptedPassword # as in the Shadow file
    [datetime] $PasswordLastChanged
    [int] $MinimumPasswordAgeInDays
    [int] $MaximumPasswordAgeInDays
    [int] $PasswordAgeWarningPeriodInDays
    [int] $PasswordInactivityPeriodInDays
    [System.Nullable[datetime]] $AccountExipreOn
    [string] $ReservedField

    nxEtcShadowEntry()
    {
        # default ctor
    }

    nxEtcShadowEntry([string] $EtcShadowEntry)
    {
        Write-Debug -Message "[nxEtcShadowEntry] Parsing '$_'."
        if ($EtcShadowEntry -notmatch [nxEtcShadowEntry]::EtcShadowLineParser)
        {
            throw "Unrecognised passwd entry: '$EtcShadowEntry'."
        }

        $this.ShadowEntry = $EtcShadowEntry
        $this.Username = $Matches.username
        $this.EncryptedPassword = $Matches.password
        $this.PasswordLastChanged = ([datetime]'1/1/1970').AddDays($Matches.lastchanged)
        $this.MinimumPasswordAgeInDays = $Matches.min
        $this.MaximumPasswordAgeInDays = $Matches.max
        $this.PasswordAgeWarningPeriodInDays = $Matches.warn
        $this.PasswordInactivityPeriodInDays = $Matches.inactive
        if ($Matches.expire)
        {
            $this.AccountExipreOn = ([datetime]'1/1/1970').AddDays($Matches.expire)
        }

        $this.ReservedField = $Matches.other

        $this | Add-Member -MemberType ScriptProperty -Name 'PasswordLocked' -Value {
            $this.IsPasswordLocked()
        }
    }

    [System.String] ToString()
    {
        return ($this.ShadowEntry)
    }

    [bool] IsPasswordLocked()
    {
        if ($this.EncryptedPassword -match '^!')
        {
            return $true
        }
        else
        {
            return $false
        }
    }
}
