class nxEtcShadowEntry
{
    hidden static [regex] $EtcShadowLineParser = @(
        '^(?<username>[a-zA-Z_\.@]([a-zA-Z0-9_\.@-]{0,31}|[a-zA-Z0-9_\.@-]{0,30}\$))'
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
    [Nullable[datetime]] $PasswordLastChanged
    [Nullable[int]] $MinimumPasswordAgeInDays
    [Nullable[int]] $MaximumPasswordAgeInDays
    [Nullable[int]] $PasswordAgeWarningPeriodInDays
    [Nullable[int]] $PasswordInactivityPeriodInDays
    [Nullable[datetime]] $AccountExipreOn
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
        $this.PasswordLastChanged = $this.ParseDateTime($Matches.lastchanged)
        $this.MinimumPasswordAgeInDays = $this.ParseInt($Matches.min)
        $this.MaximumPasswordAgeInDays = $this.ParseInt($Matches.max)
        $this.PasswordAgeWarningPeriodInDays = $this.ParseInt($Matches.warn)
        $this.PasswordInactivityPeriodInDays = $this.ParseInt($Matches.inactive)
        $this.AccountExipreOn = $this.ParseDateTime($Matches.expire)
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

    [Nullable[int]] ParseInt([string] $value)
    {
        if ([string]::IsNullOrEmpty($value))
        {
            return $null
        }

        # Throws if the value is not a valid integer
        return [int]::Parse($value)
    }

    [Nullable[datetime]] ParseDateTime([string] $value)
    {
        if ([string]::IsNullOrEmpty($value))
        {
            return $null
        }

        # Throws if the value is not a valid integer
        return ([datetime]'1/1/1970').AddDays([int]::Parse($value))
    }
}
