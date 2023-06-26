[DscResource()]
class nxScript
{
    [DscProperty(Key)]
    [System.String] $GetScript

    [DscProperty(Key)]
    [System.String] $TestScript

    [DscProperty(Key)]
    [System.String] $SetScript

    [DscProperty()]
    [Reason[]] $Reasons

    [nxScript] Get()
    {
        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($this.GetScript)
        $invokeScriptResult = $this.InvokeScript($scriptBlock)
        $isValid = $this.TestGetScriptOutput($invokeScriptResult)

        $currentState = [nxScript]::new()
        $currentState.GetScript = $this.GetScript
        $currentState.TestScript = $this.TestScript
        $currentState.SetScript = $this.SetScript
        $currentState.Reasons = @([Reason]::new())
        if ($isValid)
        {
            $currentState.Reasons = $invokeScriptResult.Reasons
        }

        return $currentState
    }

    [bool] Test()
    {
        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($this.TestScript)
        $invokeScriptResult = $this.InvokeScript($scriptBlock)

        if ($invokeScriptResult -is [System.Management.Automation.ErrorRecord])
        {
            return $false
        }

        if ($null -eq $invokeScriptResult -or -not ($invokeScriptResult -is [System.Boolean]))
        {
            return $false
        }

        return $invokeScriptResult
    }

    [void] Set()
    {
        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($this.SetScript)
        $this.InvokeScript($scriptBlock)
    }

    [System.Object] InvokeScript([System.Management.Automation.ScriptBlock] $ScriptBlock)
    {
        $scriptResult = $null
        try
        {
            $scriptResult = & $ScriptBlock
        }
        catch
        {
            # Surfacing the error thrown by the execution of the script
            $scriptResult = $_
        }

        return $scriptResult
    }

    [bool] TestGetScriptOutput([System.Object] $GetScriptOutput)
    {
        if ($GetScriptOutput -is [System.Management.Automation.ErrorRecord])
        {
            return $false
        }

        if ($GetScriptOutput -isnot [System.Collections.Hashtable])
        {
            return $false
        }

        if (-not $GetScriptOutput.ContainsKey('Reasons'))
        {
            return $false
        }

        $outputReasons = $GetScriptOutput['Reasons']
        if ($outputReasons.Count -eq 0)
        {
            return $false
        }

        foreach ($outputReason in $outputReasons)
        {
            if ($outputReason -isnot [System.Collections.Hashtable])
            {
                return $false
            }

            if (-not $outputReason.ContainsKey('Code') -or -not $outputReason.ContainsKey('Phrase'))
            {
                return $false
            }
        }

        return $true
    }
}
