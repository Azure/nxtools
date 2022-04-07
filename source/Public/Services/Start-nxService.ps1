function Start-nxService
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]
        $Name,

        [Parameter()]
        [nxInitSystem]
        $Controller = (Get-nxInitSystem)
    )

    if ($PSBoundParameters.ContainsKey('Controller'))
    {
        $null = $PSBoundParameters.Remove('Controller')
    }

    foreach ($serviceName in $Name)
    {
        switch ($Controller)
        {
            'systemd' { Start-nxSystemdService @PSboundParameters }

            default
            {
                throw ('The controller {0} is not yet supported with ''Start-nxService''.' -f $Controller)
            }
        }
    }
}
