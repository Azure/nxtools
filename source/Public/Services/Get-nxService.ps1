
function Get-nxService
{
    [CmdletBinding()]
    [OutputType([nxService])]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
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

    if (-not $PSBoundParameters.ContainsKey('Name'))
    {
        switch ($Controller)
        {
            'systemd' { Get-nxSystemdService @PSBoundParameters}

            default
            {
                throw ('The controller {0} is not yet supported with ''Get-nxService''.' -f $Controller)
            }
        }
    }
    else
    {
        foreach ($serviceName in $Name)
        {
            switch ($Controller)
            {
                'systemd' { Get-nxSystemdService @PSboundParameters }

                default
                {
                    throw ('The controller {0} is not yet supported with ''Get-nxService''.' -f $Controller)
                }
            }
        }
    }
}
