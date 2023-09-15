class nxLocalUser
{
    # gcolas:x:1000:1000:,,,:/home/gcolas:/bin/bash
    static [regex] $PasswordLineParser = @(
        '^(?<username>[a-zA-Z_\.@]([a-zA-Z0-9_\.@-]{0,31}|[a-zA-Z0-9_\.@-]{0,30}\$))'
        '(?<password>[^:]+)'
        '(?<userid>[\d]+)'
        '(?<groupid>[\d]+)'
        '(?<userinfo>[^:]*)'
        '(?<homedir>[^:]*)'
        '(?<shellcmd>[^:]*)'
    ) -join ':'

    hidden [bool] $HasChanged = $false

    [string] $UserName
    [string] $Password
    [int]    $UserId
    [int]    $GroupId

    hidden [string] $UserInfo # GECOS field
    [string] $FullName
    [string] $Office
    [string] $OfficePhone
    [string] $HomePhone
    [string] $Description

    [string] $HomeDirectory
    [string] $ShellCommand

    nxLocalUser()
    {
        # default ctor
    }

    nxLocalUser([System.String]$passwdEntry)
    {
        Write-Debug -Message "[nxLocalUser] Parsing '$_'."
        if ($passwdEntry -notmatch [nxLocalUser]::PasswordLineParser)
        {
            throw "Unrecognised passwd entry: '$passwdEntry'."
        }

        $this.UserName = $Matches.username
        $this.Password = $Matches.password
        $this.UserId = [int]::Parse($Matches.userid)
        $this.GroupId = [int]::Parse($Matches.groupid)
        $this.UserInfo = $Matches.userinfo

        if (-not [string]::IsNullOrEmpty($this.UserInfo))
        {
            $this.LoadGecosFields()
        }

        $this.HomeDirectory = $Matches.homedir
        $this.ShellCommand = $Matches.shellcmd

        # the below script properties should probably go in the type format
        $this |
            Add-Member -PassThru -MemberType ScriptProperty -Name 'MemberOf' -Value {
                # only calling the method when needed to avoid unecessary calls
                $this.GetMemberOf()
            }|
            Add-Member -PassThru -MemberType ScriptProperty -Name 'EtcShadow' -Value {
                $this.GetEtcShadow()
            }
    }

    [void] LoadGecosFields()
    {
        $gecosFields = [nxLocalUser]::GetGecosFieldsFromUserInfo($this.UserInfo)
        $this.FullName      = $gecosFields['FullName']
        $this.Office        = $gecosFields['Office']
        $this.OfficePhone   = $gecosFields['OfficePhone']
        $this.HomePhone     = $gecosFields['HomePhone']
        $this.Description   = $gecosFields['Description']
    }

    static [hashtable] GetGecosFieldsFromUserInfo([String] $UserInfoString)
    {
        $gecosFields = $UserInfoString -split ',',5

        return @{
            FullName    = $gecosFields[0]
            Office      = $gecosFields[1]
            OfficePhone = $gecosFields[2]
            HomePhone   = $gecosFields[3]
            Description = $gecosFields[4]
        }
    }

    static [bool] Exists([string]$UserName)
    {
        try
        {
            $result = Invoke-NativeCommand -Executable 'id' -Parameters @('-u', $UserName) -ErrorAction 'Stop'
        }
        catch
        {
            Write-Debug -Message "The command 'id' returned '$_'."
            $result = $false
        }

        [int]$ParsedUserID = -1

        if ([int]::TryParse($result, [ref]$ParsedUserID))
        {
            Write-Debug -Message "User id for '$UserName' is '$result'."
            return $true
        }
        else
        {
            return $false
        }
    }

    [string] ToString()
    {
        return $this.UserName
    }

    [string] ToPasswdString()
    {
        return ('{0}:{1}:{2}:{3}:{4}:{5}:{6}:{7}' -f
            $this.UserName,
            $this.Password,
            $this.UserId,
            $this.GroupId,
            $this.UserInfo,
            $this.HomeDirectory,
            $this.ShellCommand
        )
    }

    [void] Save()
    {
        if ([nxLocalUser]::Exists($this.Username))
        {
            $this.Update()
        }
        else
        {
            $this.SaveAsNewNxLocalAccount()
        }
    }

    [void] Update()
    {
        $this | Set-nxLocalUser
    }

    [void] SaveAsNewNxLocalAccount()
    {
        $null = $this | Add-nxLocalUser -ErrorAction 'Stop'
    }

    [nxLocalGroup[]] GetMemberOf()
    {
        return (Get-nxLocalUserMemberOf -User $this.UserName).MemberOf
    }

    [nxEtcShadowEntry] GetEtcShadow()
    {
        return (Get-nxEtcShadow -UserName $this.UserName)
    }

    [bool] IsDisabled()
    {
        $shadowEntry = $this.GetEtcShadow()
        return ($shadowEntry.IsPasswordLocked() -and $shadowEntry.AccountExipreOn -le [dateTime]::Now)
    }
}
