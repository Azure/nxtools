function Enable-nxLocalUser
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [System.String[]]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet([ValidShell],ErrorMessage="Value '{0}' is invalid. Try one of: {1}")]
        [String]
        $ShellCommand,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [datetime]
        $ExpireOn,

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
            $usermodParams += @('-U')

            if ($PSBoundParameters.ContainsKey('ShellCommand'))
            {
                $usermodParams += @('-s', $ShellCommand)
            }

            if ($PSBoundParameters.ContainsKey('ExpireOn') -and $PSBoundParameters['ExpireOn'])
            {
                $usermodParams += @('-e', $ExpireOn.ToString('yyyy-MM-dd'))
            }

            $usermodParams += @($UserNameItem)

            if ($PSCmdlet.ShouldProcess(
                    "Performing the unix command 'usermod $(($usermodParams -join ' '))'.",
                    "$UserNameItem",
                    "Enabling account '$UserNameItem'."
                )
            )
            {
                Invoke-NativeCommand -Executable 'usermod' -Parameters $usermodParams -Verbose:$verbose -ErrorAction 'Stop' |
                    ForEach-Object -Process {
                        throw $_
                    }

                if ($PassThru.IsPresent)
                {
                    Get-nxLocalUser -UserName $UserName
                }
            }
        }
    }
}
