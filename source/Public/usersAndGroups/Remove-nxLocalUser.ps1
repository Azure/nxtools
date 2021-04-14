function Remove-nxLocalUser
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param
    (

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string[]]
        [Alias('User','Name')]
        $UserName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $RemoveHomeDirAndMailSpool,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Force
    )

    begin
    {
        $verbose = $PSBoundParameters.ContainsKey('verbose') -and $PSBoundParameters['Verbose']
        $userDelParams += @()
    }

    process
    {
        if ($PSBoundParameters.ContainsKey('RemoveHomeDirAndMailSpool') -and $PSBoundParameters['RemoveHomeDirAndMailSpool'])
        {
            $userDelParams += @('-r')
        }

        if ($PSBoundParameters.ContainsKey('Force') -and $PSBoundParameters['Force'])
        {
            $userDelParams += @('-f')
        }

        foreach ($UserNameItem in $UserName)
        {
            if ($PScmdlet.ShouldProcess("Performing the unix command 'userdel $(($userDelParams + @($userNameItem)) -join ' ')'.", $UserNameItem, "Removing local user '$UserNameItem' from '$(hostname)'."))
            {
                Invoke-NativeCommand -Executable 'userdel' -Parameter ($userDelParams + @($userNameItem)) -Verbose:$verbose -ErrorAction 'Stop' | Foreach-Object {
                    throw $_
                }
            }
        }
    }




}
