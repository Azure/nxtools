using namespace System.Collections

[DscResource()]
class nxService
{
    [DscProperty(Key)]
    [string] $Name

    [DscProperty()]
    [System.Nullable[bool]] $Enabled # enabled, disabled, masked

    [DscProperty()]
    [string] $State

    [DscProperty()] # Write Only
    [nxInitSystem] $Controller = (Get-nxInitSystem)

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    hidden [void] SetNxServiceProperties([IDictionary] $Definition)
    {
        if ($Definition.keys -notcontains 'Name')
        {
            throw 'You must provide the  name of the service you want to manage.'
        }

        foreach ($property in $Definition.Keys.Where{$_ -in $this.PSObject.Properties.Where{$_.IsSettable}.Name})
        {
            $this.($property) = $Definition[$property]
        }
    }

    [nxService] Get()
    {
        $nxService = Get-nxService -Name $this.Name
        if ($null -eq $nxService.Name)
        {
            # Silently return if the service does not exist
            Write-Warning -Message ('Service ''{0}'' could not be found.' -f $this.Name)
            return [nxService]::new()
        }

        $currentState = [nxService]::new()
        $currentState.Name = $nxService.Name
        $currentState.Enabled = $nxService.Enabled
        $currentState.State = $nxService.State
        $currentState.Controller = $this.Controller

        $valuesToCheck = @(
            'Enabled'
            'State'
        ).Where({ $null -ne $this.$_ }) #remove properties not set from comparison

        $compareStateParams = @{
            CurrentValues       = ($currentState | Convert-ObjectToHashtable)
            DesiredValues       = ($this | Convert-ObjectToHashtable)
            ValuesToCheck       = $valuesToCheck
            TurnOffTypeChecking = $true
            ErrorAction         = 'Ignore'
        }

        $compareState = Compare-DscParameterState @compareStateParams

        Write-Debug -Message 'Adding reasons to the current state to explain discrepancies...'

        $currentState.reasons = switch ($compareState.Property)
        {
            'Enabled'
            {
                if ($null -ne $this.enabled -and $this.Enabled -ne $currentState.Enabled)
                {
                    $enabledReference = @{
                        $true = 'enabled'
                        $false = 'disabled'
                    }

                    [Reason]@{
                        Code = '{0}:{0}:Enabled' -f 'nxService'
                        Phrase = 'The service ''{0}'' is present but we''re expecting it to be {1} instead of {2}.' -f $this.Name, $enabledReference[$this.Enabled], $enabledReference[$currentState.Enabled]
                    }
                }
            }

            'State'
            {
                if ($null -ne $this.State -and $this.State -ne $currentState.State)
                {
                    [Reason]@{
                        Code = '{0}:{0}:State' -f 'nxService'
                        Phrase = 'The service ''{0}'' is present but we''re expecting it to be ''{1}'' instead of ''{2}''' -f $this.Name, $this.State, $currentState.State
                    }
                }
            }
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()

        if ($currentState.Reasons.Count -gt 0)
        {
            return $false
        }
        else
        {
            return $true
        }
    }

    [void] Set()
    {
        $currentState = $this.Get()

        switch -Regex ($currentState.Reasons.Code)
        {
            'State$'
            {
                if ($currentState.State -eq 'running')
                {
                    $this.Stop()
                }
                else
                {
                    $this.Start()
                }
            }

            'Enabled$'
            {
                if ($currentState.Enabled)
                {
                    $this.Disable()
                }
                else
                {
                    $this.Enable()
                }
            }
        }
    }

    [void] Disable()
    {
        # Disable the service
        Write-Debug -Message ('Disabling service ''{0}''.' -f $this.Name)
        Disable-nxService -Name $this.Name -Controller $this.Controller
    }

    [void] Enable()
    {
        # Enable the service now or at next machine start
        Write-Debug -Message ('Enabling service ''{0}''.' -f $this.Name)
        Enable-nxService -Name $this.Name -Controller $this.Controller
    }

    [void] Start()
    {
        # Start the service
        Write-Debug -Message ('Starting service ''{0}''.' -f $this.Name)
        Start-nxService -Name $this.Name -Controller $this.Controller
    }

    [void] Stop()
    {
        # Stop the service
        Write-Debug -Message ('Stopping service ''{0}''.' -f $this.Name)
        Stop-nxService -Name $this.Name -Controller $this.Controller
    }

    [void] Restart()
    {
        # Restart the service
        Write-Debug -Message ('Restarting service ''{0}''.' -f $this.Name)
        Restart-nxService -Name $this.Name -Controller $this.Controller
    }

    [bool] IsEnabled()
    {
        # Message when the method is not overridden by the controller-specific class
        throw 'The [nxService] method IsEnabled() is not yet supported for this Controller.'
    }

    [bool] IsRunning()
    {
        # Message when the method is not overridden by the controller-specific class
        throw 'The [nxService] method IsRunning() is not yet supported for this Controller.'
    }
}
