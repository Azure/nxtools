[DscResource()]
class nxScript
{
    [DscProperty()]
    [System.String] $GetScript

    [DscProperty(Key)]
    [System.String] $TestScript

    [DscProperty()]
    [System.String] $SetScript

    [DscProperty()]
    [Reason[]] $Reasons

    [nxScript] Get()
    {
        if (-not $this.GetScript)
        {
            # The GetScript script block was not defined
            return $this
        }

        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($this.GetScript)
        $invokeScriptResult = $this.InvokeScript($scriptBlock)
        if ($invokeScriptResult -is [System.Management.Automation.ErrorRecord])
        {
            throw "The GetScript script block returned an error: $invokeScriptResult."
        }

        $isValid = $this.TestGetScriptOutput($invokeScriptResult)
        if (-not $isValid)
        {
            throw "The GetScript script block must return a hashtable that contains a non-empty list of Reason objects under the Reasons key."
        }

        $this.Reasons = $invokeScriptResult.Reasons
        return $this
    }

    [bool] Test()
    {
        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($this.TestScript)
        $invokeScriptResult = $this.InvokeScript($scriptBlock)
        if ($invokeScriptResult -is [System.Management.Automation.ErrorRecord])
        {
            throw "The TestScript script block returned an error: $invokeScriptResult."
        }

        if ($null -eq $invokeScriptResult -or -not ($invokeScriptResult -is [System.Boolean]))
        {
            throw "The TestScript script block must return a Boolean."
        }

        return $invokeScriptResult
    }

    [void] Set()
    {
        if (-not $this.SetScript)
        {
            # The SetScript script block was not defined
            return
        }

        $scriptBlock = [System.Management.Automation.ScriptBlock]::Create($this.SetScript)
        $null = $this.InvokeScript($scriptBlock)
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
        if ($GetScriptOutput -isnot [System.Collections.Hashtable])
        {
            Write-Verbose -Message "The GetScript script block must return a hashtable"
            return $false
        }

        if (-not $GetScriptOutput.ContainsKey("Reasons"))
        {
            Write-Verbose -Message "The hashtable does not have a Reasons key"
            return $false
        }

        $outputReasons = $GetScriptOutput["Reasons"]
        if ($outputReasons.Count -eq 0)
        {
            Write-Verbose -Message "The Reasons list is empty"
            return $false
        }

        foreach ($outputReason in $outputReasons)
        {
            if ($outputReason -isnot [Reason])
            {
                Write-Verbose -Message "One of the Reasons is not a Reason object"
                return $false
            }
        }

        return $true
    }
}
