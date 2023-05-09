[DscResource()]
class nxFileLine
{
    [DscProperty(Key)]
    # The full path to the file to manage lines in on the target node.
    [string] $FilePath

    [DscProperty(Key)]
    # A line to ensure exists in the file.
    # By default, this line will be appended to the file if it does not exist in the file.
    # ContainsLine is mandatory, but can be set to an empty string (ContainsLine = "") if it is not needed.
    [string] $ContainsLine

    [DscProperty()] #WriteOnly
    # A regular expression pattern for lines that should not exist in the file.
    # For any lines that exist in the file that match this regular expression, the line will be removed from the file.
    [string] $DoesNotContainPattern

    [DscProperty()] #WriteOnly
    [bool] $CaseSensitive = $false

    [DscProperty()]
    # Append, AfterLinePatternMatch, BeforeLinePatternMatch
    [nxFileLineAddMode] $AddLineMode = [nxFileLineAddMode]::Append

    [DscProperty()]
    [string] $LinePattern

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [nxFileLine] Get()
    {
        #
        $currentState = [nxFileLine]::new()
        $currentState.ContainsLine = $this.ContainsLine
        $currentState.DoesNotContainPattern = $this.DoesNotContainPattern
        $currentState.FilePath = $this.FilePath
        $currentState.LinePattern = $this.LinePattern
        $currentState.CaseSensitive = $this.CaseSensitive
        $currentState.AddLineMode = $this.AddLineMode

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
                Code   = '{0}:{0}:ResolvedToMultipleFiles' -f $this.GetType()
                Phrase = "The Path '$($this.FilePath)' resolved to multiple paths: ['$($allFiles -join "','")']."
            }

            return $currentState
        }

        if (-not [string]::IsNullOrEmpty($this.ContainsLine))
        {
            $foundLines = Select-String -Path $this.FilePath -Pattern $this.ContainsLine -SimpleMatch -AllMatches -CaseSensitive:$this.CaseSensitive
            if ($foundLines.Count -gt 0)
            {
                Write-Verbose -Message "The line '$($this.ContainsLine)' was found $($foundLines.count) times."
                $currentState.Reasons = $foundLines.Foreach{
                    [Reason]@{
                        Code   = '{0}:{0}:LineFound' -f $this.GetType()
                        Phrase = "[Compliant]The expected line '$($_.Pattern)' was found at line number '$($_.LineNumber)'."
                    }
                }
            }
            else
            {
                Write-Verbose -Message "The line '$($this.ContainsLine)' was not found."
                $currentState.Reasons = [Reason]@{
                    Code   = '{0}:{0}:LineNotFound' -f $this.GetType()
                    Phrase = "Can't find the expected line '$($this.ContainsLine)'."
                }
            }
        }

        if (-not [string]::IsNullOrEmpty($this.DoesNotContainPattern))
        {
            $shouldNotFindPattern = Select-String -Path $this.FilePath -Pattern $this.DoesNotContainPattern -AllMatches -CaseSensitive:$this.CaseSensitive
            $currentState.Reasons += $shouldNotFindPattern.Foreach{
                [Reason]@{
                    Code   = '{0}:{0}:LineUnexpected' -f $this.GetType()
                    Phrase = "The pattern '$($_.Pattern)' was found at line '$($_.LineNumber)' but is expeced to be absent."
                }
            }
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()
        $testTargetResourceResult = ($currentState.Reasons.Where({
            $_.Code -notmatch 'LineFound'
        })).count -eq 0

        return $testTargetResourceResult
    }

    [void] Set()
    {
        $file = Get-nxChildItem -Path $this.FilePath -File

        if (-not $file)
        {
            Write-Warning -Message "The file '$($this.FilePath)' was not found. Please create the file with [nxFile] to manage its content with [nxFileLine]."
        }

        if (-not ([string]::IsNullOrEmpty($this.ContainsLine)))
        {
            $foundLines = Select-String -Path $this.FilePath -Pattern $this.ContainsLine -SimpleMatch -AllMatches -CaseSensitive:$this.CaseSensitive

            if ($foundLines.Count -eq 0)
            {
                Add-nxFileLine -Path $this.FilePath -Line $this.ContainsLine -AddLineMode $this.AddLineMode -LinePattern $this.LinePattern
            }
        }

        if (-not [string]::IsNullOrEmpty($this.DoesNotContainPattern))
        {
            $shouldNotFindPattern = Select-String -Path $this.FilePath -Pattern $this.DoesNotContainPattern -AllMatches -CaseSensitive:$this.CaseSensitive

            if ($shouldNotFindPattern.count -gt 0)
            {
                Remove-nxFileLine -Path $this.FilePath -LineNumber $shouldNotFindPattern.LineNumber
            }
        }
    }
}
