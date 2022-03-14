function Remove-nxLocalGroupMember
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $UserName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]
        $PassThru
    )

    begin
    {
        $verbose = ($PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters['Verbose']) -or $VerbosePreference -ne 'SilentlyContinue'
        $hasGroupChanged = $false
    }

    process
    {

        foreach ($UserNameItem in $UserName)
        {
            $gpasswdParams = @('-d', $UserNameItem, $GroupName)
            if ($PSCmdlet.ShouldProcess(
                    "Performing the unix command 'gpasswd $($gpasswdParams -join ' ')'.",
                    $UserNameItem,
                    "Removing $userNameItem grom group '$GroupName'."
                )
            )
            {
                Invoke-NativeCommand -Executable 'gpasswd' -Parameters $gpasswdParams -Verbose:$verbose -ErrorAction 'Stop' |
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
