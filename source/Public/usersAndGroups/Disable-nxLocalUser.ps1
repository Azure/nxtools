function Disable-nxLocalUser
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [outputType([nxLocalUser])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [System.String[]]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $LockOnly,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $SkipNologinShell,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $DoNotExpireAccount,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $PassThru
    )

    begin
    {
        $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) -or $VerbosePreference -ne 'SilentlyContinue'
    }

    process
    {
        foreach ($UserNameItem in $UserName)
        {
            $usermodParams = @()

            # at the very least, we lock the account (does not impact ssh pub keys or PAM except pam_unix)
            $usermodParams += @('-L')

            if (-not $SkipNologinShell)
            {
                $usermodParams += @('-s','/sbin/nologin')
            }

            $usermodParams += @($UserNameItem)

            if (-not $LockOnly.IsPresent -and -not $DoNotExpireAccount.IsPresent)
            {
                $chageParams = @('-E0',$UserNameItem)
                $ShouldProcessMessage = "Disabling account '$UserNameItem': 'usermod $(($usermodParams -join ' ')) && chage $(($chageParams -join ' '))'."
            }
            else
            {
                $ShouldProcessMessage = "Locking account '$UserNameItem': 'usermod $(($usermodParams -join ' '))'."
            }

            if ($PSCmdlet.ShouldProcess(
                    $ShouldProcessMessage,
                    "$UserNameItem",
                    "Disabling account '$UserNameItem'."
                )
            )
            {

                Invoke-NativeCommand -Executable 'usermod' -Parameters $usermodParams -Verbose:$verbose -ErrorAction 'Stop' |
                    ForEach-Object -Process {
                        throw $_
                    }

                if (-not $LockOnly.IsPresent -and -not $DoNotExpireAccount.IsPresent)
                {
                    Invoke-NativeCommand -Executable 'chage' -Parameters $chageParams -Verbose:$verbose -ErrorAction 'Stop' |
                        ForEach-Object -Process {
                            throw $_
                        }
                }


                if ($PassThru.IsPresent)
                {
                    Get-nxLocalUser -UserName $UserName
                }
            }
        }
    }
}
