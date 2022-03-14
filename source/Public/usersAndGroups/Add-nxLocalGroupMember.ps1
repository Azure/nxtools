function Add-nxLocalGroupMember
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'medium')]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        $GroupName,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String[]]
        [Alias('Member')]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $PassThru
    )

    begin
    {
        $verbose = $VerbosePreference -or ($PSBoundParameters.ContainsKey('verbose') -and $PSBoundParameters['verbose'])
        $hasGroupChanged = $false
    }

    process
    {
        foreach ($UserNameItem in $UserName)
        {
            $gpasswdParams = @('-a', $UserNameItem, $GroupName)

            if ($PSCmdlet.ShouldProcess(
                "Performing the unix command 'gpasswd $($gpasswdParams -join ' ')'.",
                $UserNameItem,
                "Removing $userNameItem grom group '$GroupName'.")
            )
            {
                Invoke-NativeCommand -Executable 'gpasswd' -Parameters $gpasswdParams -Verbose:$verbose |
                    ForEach-Object -Process {
                        if ($_ -match '^gpasswd:')
                        {
                            throw $_
                        }
                        else
                        {
                            Write-Verbose -Message $_
                        }
                    }

                $hasGroupChanged = $true
            }
        }

        if ($hasGroupChanged -and $PassThru)
        {
            Get-nxLocalGroup -GroupName $GroupName
        }
    }
}
