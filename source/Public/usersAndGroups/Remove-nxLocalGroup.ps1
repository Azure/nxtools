function Remove-nxLocalGroup
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([void])]
    param
    (

        [Parameter(ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string[]]
        [Alias('Group')]
        $GroupName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Force
    )

    begin
    {
        $verbose = $PSBoundParameters.ContainsKey('verbose') -and $PSBoundParameters['Verbose']
        $groupDelParams += @()
    }

    process
    {
        if ($PSBoundParameters.ContainsKey('RemoveHomeDirAndMailSpool') -and $PSBoundParameters['RemoveHomeDirAndMailSpool'])
        {
            $groupDelParams += @('-r')
        }

        if ($PSBoundParameters.ContainsKey('Force') -and $PSBoundParameters['Force'])
        {
            $groupDelParams += @('-f')
        }

        foreach ($GroupNameItem in $GroupName)
        {
            if ($PScmdlet.ShouldProcess("Performing the unix command 'groupdel $(($groupDelParams + @($GroupNameItem)) -join ' ')'.", $GroupNameItem, "Removing local group '$GroupNameItem' from '$(hostname)'."))
            {
                Invoke-NativeCommand -Executable 'groupdel' -Parameter ($groupDelParams + @($GroupNameItem)) -Verbose:$verbose -ErrorAction 'Stop' | Foreach-Object {
                    throw $_
                }
            }
        }
    }




}
