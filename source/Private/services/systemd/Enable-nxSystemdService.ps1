function Enable-nxSystemdService
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Name,

        [Parameter()]
        [switch]
        $Now
    )

    process
    {
        foreach ($serviceName in $Name)
        {
            Write-Verbose -Message ('Enabling service ''{0}''.' -f $serviceName)
            $systemctlEnableParams = @('enable',$serviceName)
            if ($Now.IsPresent)
            {
                $systemctlEnableParams += '--now'
            }

            Invoke-NativeCommand -Executable 'systemctl' -Parameters $systemctlEnableParams | ForEach-Object -Process {
                if ($_ -is [System.Management.Automation.ErrorRecord])
                {
                    Write-Error -Exception $_
                }
                elseif (-not [string]::isnullorempty($_))
                {
                    Write-Verbose -Message $_
                }
            }
        }
    }
}
