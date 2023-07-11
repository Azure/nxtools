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
            Write-Verbose -Message "TestScript returned an error."
            return $false
        }

        if ($null -eq $invokeScriptResult -or -not ($invokeScriptResult -is [System.Boolean]))
        {
            Write-Verbose -Message "TestScript output is not a Boolean."
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
            Write-Verbose -Message "GetScript returned an error."
            return $false
        }

        if ($GetScriptOutput -isnot [System.Collections.Hashtable])
        {
            Write-Verbose -Message "GetScript output is not a hashtable."
            return $false
        }

        if (-not $GetScriptOutput.ContainsKey('Reasons'))
        {
            Write-Verbose -Message "GetScript output does not contain a 'Reasons' key."
            return $false
        }

        $outputReasons = $GetScriptOutput['Reasons']
        if ($outputReasons.Count -eq 0)
        {
            Write-Verbose -Message "GetScript output does not contain any 'Reasons'."
            return $false
        }

        foreach ($outputReason in $outputReasons)
        {
            if ($outputReason -isnot [System.Collections.Hashtable])
            {
                Write-Verbose -Message "GetScript reason is not a hashtable."
                return $false
            }

            if (-not $outputReason.ContainsKey('Code') -or -not $outputReason.ContainsKey('Phrase'))
            {
                Write-Verbose -Message "GetScript reason does not have a 'Code' key or a 'Phrase' key."
                return $false
            }
        }

        return $true
    }
}
