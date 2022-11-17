using namespace System.Collections

class nxSystemdService : nxService
{
    # [string] $Name # Defined in Parent class
    [string] $Load
    [string] $Active
    # [nxServiceState] $State # Defined in parent class
    [string] $Status # Specific to Systemctl
    [string] $Description

    [Reason[]] $Reasons

    nxSystemdService()
    {
        # default ctor
    }

    nxSystemdService([IDictionary] $Definition)
    {
        if (-not [string]::IsNullOrEmpty($Definition.name) -and $Definition['name'] -notmatch '\.service')
        {
            # Systemctl version 219 and prior do not support short names.
            $Definition['name'] = '{0}.service' -f $Definition['name']
        }

        $this.SetNxServiceProperties($Definition)
    }

    hidden [void] SetNxServiceProperties([IDictionary] $Definition)
    {
        foreach ($property in $Definition.Keys.Where{$_ -in $this.PSObject.Properties.Where{$_.IsSettable}.Name})
        {
            $this.($property) = $Definition[$property]
        }

        if (-not $Definition.ContainsKey('enabled'))
        {
            $this.Enabled = $this.isEnabled()
        }
    }

    [bool] IsEnabled()
    {
        [bool] $result = $false
        switch -regex (Invoke-NativeCommand -Executable 'systemctl' -Parameters @('is-enabled',$this.Name))
        {
            '^enabled$'
            {
                $result = $true
                $this.Status = $_
            }

            default
            {
                $result = $false
                $this.Status = $_
            }
        }

        $this.Enabled = $result
        return $result
    }

    [bool] IsRunning()
    {
        [bool] $result = $false
        switch -regex (Invoke-NativeCommand -Executable 'systemctl' -Parameters @('is-active', $this.Name))
        {
            '^active$'
            {
                $result = $true
                $this.Active = 'active'
                $this.State = [nxServiceState]::Running
            }

            default
            {
                Write-Verbose -Message ('The service ''{1}'' is ''{0}''.' -f $_, $this.Name)
                $this.Active = $_
                $this.State = [nxServiceState]::Stopped
                $result = $false
            }
        }

        return $result
    }
}
