class nxLocalUser
{
    # gcolas:x:1000:1000:,,,:/home/gcolas:/bin/bash
    static [regex] $PasswordLineParser = @(
        '^(?<username>[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$))'
        '(?<password>[^:]+)'
        '(?<userid>[\d]+)'
        '(?<groupid>[\d]+)'
        '(?<userinfo>[^:]*)'
        '(?<homedir>[^:]*)'
        '(?<shellcmd>[^:]*)'
    ) -join ':'

    hidden [bool] $HasBeenUpdated = $false

    [string] $UserName
    [string] $Password
    [int]    $UserId
    [int]    $GroupId
    [string] $UserInfo
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
        $this.HomeDirectory = $Matches.homedir
        $this.ShellCommand = $Matches.shellcmd

        $this | Add-Member -PassThru -MemberType ScriptProperty -Name MemberOf -Value {
            # only calling the method when needed to avoid unecessary calls
            $this.GetMemberOf()
        }
    }

    static [bool] Exists([string]$UserName)
    {
        $result = Invoke-NativeCommand -Executable 'id' -Parameters @('-u', $UserName) -ErrorAction 'Stop'
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
        $newUser = $this | Add-nxLocalUser
    }

    [nxLocalGroup[]] GetMemberOf()
    {
        return (Get-nxLocalUserMemberOf -User $this.UserName).MemberOf
    }
}
