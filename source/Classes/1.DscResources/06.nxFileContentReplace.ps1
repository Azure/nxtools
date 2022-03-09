[DscResource()]
class nxFileContentReplace
{
    [DscProperty()]
    [Ensure] $Ensure

    [DscProperty(Key)]
    [string] $FilePath

    [DscProperty(Key)]
    [string] $EnsureExpectedPattern

    [DscProperty()] # WriteOnly
    [bool] $Multiline = $false  # Will read the whole file and -match/-replace the whole content

    [DscProperty()] # WriteOnly
    [string] $SearchPattern

    [DscProperty()] # WriteOnly
    [bool] $SimpleMatch

    [DscProperty()] # WriteOnly
    [string] $ReplacementString

    [DscProperty()] # WriteOnly
    [bool] $CaseSensitive = $false

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [nxFileContentReplace] Get()
    {
        # Copy all properties except Ensure
        $currentState = [nxFileContentReplace]::new()
        $currentState.FilePath = $this.FilePath
        $currentState.EnsureExpectedPattern = $this.EnsureExpectedPattern
        $currentState.SearchPattern = $this.SearchPattern
        $currentState.SimpleMatch = $this.SimpleMatch
        $currentState.ReplacementString = $this.ReplacementString
        $currentState.CaseSensitive = $this.CaseSensitive
        $currentState.Multiline = $this.Multiline

        if (-not (Test-Path -Path $this.FilePath -ErrorAction Ignore))
        {
            $currentState.Reasons = [Reason]@{
                Code    = '{0}:{0}:FileNotFound' -f $this.GetType()
                Phrase  = "The file '$this.filePath' was not found."
            }

            return $currentState
        }
        elseif ((Get-Item -Path $this.FilePath).count -gt 1)
        {
            $allFiles = Get-Item -Path $this.FilePath
            $currentState.Reasons = [Reason]@{
                Code   = '{0}:{0}:ResolvedToMultipledFiles' -f $this.GetType()
                Phrase = "The Path '$($this.filePath)' resolved to multiple paths: ['$($allFiles -join "','")']."
            }

            return $currentState
        }

        if ($this.SimpleMatch)
        {
            $ExpectedPattern = [regex]::Escape($this.EnsureExpectedPattern)
        }
        else
        {
            $ExpectedPattern = $this.EnsureExpectedPattern
        }

        if ($this.Multiline)
        {
            $selectStringParams = @{
                Pattern = $ExpectedPattern
                AllMatches = $true
                CaseSensitive = $this.CaseSensitive
            }

            $foundMatches = Get-Content -Raw -Path $this.FilePath | Select-String @selectStringParams
        }
        else
        {
            $selectStringParams = @{
                Path = $this.FilePath
                Pattern = $ExpectedPattern
                AllMatches = $true
                CaseSensitive = $this.CaseSensitive
            }

            $foundMatches = Select-String @selectStringParams
        }

        if ($foundMatches.count -gt 0)
        {
            $currentState.Ensure = [Ensure]::Present
        }
        else
        {
            $currentState.Ensure = [Ensure]::Absent
        }

        if ($this.Ensure -ne $currentState.Ensure) # non compliant
        {
            if ($this.Ensure -eq [Ensure]::Present) # We expected it to be Present but it's not
            {
                Write-Debug -Message "We expected the pattern '$($this.EnsureExpectedPattern)' to be Present but it was not found in '$($this.FilePath)'."
                $CurrentState.Reasons += [Reason]@{
                    Code    = '{0}:{0}:ExpectedPatternNotFound' -f $this.GetType()
                    Phrase  = "We expected the pattern '$($this.EnsureExpectedPattern)' to be Present but it was not found in '$($this.FilePath)'."
                }
            }
            elseif ($this.Ensure -eq [Ensure]::Absent) # We expected it to be Absent but it's not
            {
                Write-Debug -Message "The undesired pattern '$($this.EnsureExpectedPattern)' was found to be Present in '$($this.FilePath)'."
                $CurrentState.Reasons += [Reason]@{
                    Code    = '{0}:{0}:UndesiredPatternFound' -f $this.GetType()
                    Phrase  = "The undesired pattern '$($this.EnsureExpectedPattern)' was found to be Present $($foundMatches.Count) times in '$($this.FilePath)'."
                }
            }

            if (-not $this.Multiline)
            {
                # List all of the transforms that we want to happen.
                # Re-use the sls params but now use the SearchPattern for pattern.
                $selectStringParams['Pattern'] = $this.SearchPattern
                $foundReplace = Select-String @selectStringParams
                $foundReplace.Foreach{
                    $currentState.Reasons += [Reason]@{
                        Code   = '{0}:{0}:SubstitubtionRequired' -f $this.GetType()
                        Phrase = 'Pattern ''{0}'' found at line {1} to be replaced with ''{2}'' of file ''{3}'' resulting in: ''.' -f $_.Pattern, $_.LineNumber, $this.ReplacementString, $CurrentState.FilePath
                    }
                }
            }
            else
            {
                # List all of the transforms that we want to happen on the whole file.
                # Re-use the sls params but now use the SearchPattern for pattern.
                $selectStringParams['Pattern'] = $this.SearchPattern
                $foundReplace = Get-Content -Raw -Path $this.FilePath | Select-String @selectStringParams
                $foundReplace.Matches.Foreach{
                    $currentState.Reasons += [Reason]@{
                        Code   = '{0}:{0}:MultilineSubstitubtionRequired' -f $this.GetType()
                        Phrase = 'Pattern ''{0}'' found at index {1} of length ''{2}'' to be replaced with ''{3}'' of file ''{4}'' resulting in: ''.' -f $foundReplace.Pattern, $_.Index, $_.Length, $this.ReplacementString, $CurrentState.FilePath
                    }
                }
            }
        }
        else # Compliant, nothing to do.
        {
            Write-Verbose -Message "The resource is compliant with the expectation."
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()

        return ($currentState.Reasons.Count -eq 0)
    }

    [void] Set()
    {
        $currentState = $this.Get()

        if ($this.Ensure -ne $currentState.Ensure)
        {
            # Do the substitutions
            Invoke-nxFileContentReplace -Path $this.FilePath -SearchPattern $this.SearchPattern -ReplaceWith $this.ReplacementString -Multiline:$this.Multiline
        }
    }
}
