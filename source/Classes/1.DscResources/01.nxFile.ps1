$script:localizedDataNxFile = Get-LocalizedData -DefaultUICulture 'en-US' -FileName 'nxFile'

[DscResource()]
class nxFile
{
    [DscProperty()]
    [Ensure] $Ensure

    [DscProperty(key)]
    [System.String] $DestinationPath

    [DscProperty()]
    [System.String] $SourcePath # Write Only

    [DscProperty()]
    [System.String] $Type = 'File' # directory | file | link

    [DscProperty()]
    [System.String] $Contents

    [DscProperty()]
    [System.String] $Checksum #  ctime | mtime | md5 | Value

    [DscProperty()]
    [System.string] $Mode

    [DscProperty()]
    [bool] $Force   # Write Only

    [DscProperty()]
    [bool] $Recurse # Write Only

    [DscProperty()]
    [System.String] $Owner

    [DscProperty()]
    [System.String] $Group

    #Links (follow | manage | ignore)

    [DscProperty()]
    [Reason[]] $Reasons

    [nxFile] Get()
    {
        Write-Verbose -Message (
            $script:localizedDataNxFile.RetrieveFile -f $this.DestinationPath
        )

        $nxFileSystemInfo = Get-nxItem -Path $this.DestinationPath -ErrorAction SilentlyContinue
        $currentState = [nxFile]::new()
        $currentState.DestinationPath = $this.DestinationPath

        if ($nxFileSystemInfo) # The file/folder/link exists
        {
            $currentState.Ensure = [Ensure]::Present
            $currentState.Owner = $nxFileSystemInfo.nxOwner
            $currentState.Group = $nxFileSystemInfo.nxGroup
            $currentState.Type  = $nxFileSystemInfo.nxFileSystemItemType

            if ($this.Mode -match '^\d+$') # using octal notation (i.e. 0777)
            {
                $currentState.Mode = $nxFileSystemInfo.Mode.ToOctal()

                if ($this.Mode.Length -eq 3)
                {
                    # if the desired value omits special flags digit (assuming 0), re-add for comparison
                    $this.Mode = '0' + $this.Mode
                }
            }
            else    # Using Symbolic notation (i.e. rwxrwxrwx)
            {
                $currentState.Mode  = $nxFileSystemInfo.Mode.ToString()
            }

            $isSameFile = $false
            if ($this.Checksum -and $this.Type -eq 'File') # checksum checks has precedence over contents check
            {
                switch ($this.Checksum)
                {
                    'MD5'
                    {
                        # Compare Destination with source using MD5
                        if ($this.SourcePath -and (Test-Path -Path $this.SourcePath))
                        {
                            $sourceHash = (Get-FileHash -Path $this.SourcePath -Algorithm 'MD5').Hash
                            $destinationHash = (Get-FileHash -Path $currentState.DestinationPath -Algorithm 'MD5').Hash
                            $isSameFile = $sourceHash -eq $destinationHash

                            if ($this.Contents)
                            {
                                # Do not compare contents if the comparison is done by checksum
                                $currentState.Contents = $this.Contents
                            }
                        }
                        elseif (-not (Test-Path -Path $this.SourcePath))
                        {
                            throw ($script:localizedDataNxFile.SourcePathNotFound -f $this.SourcePath)
                        }
                    }

                    'ctime' # change time (metadata)
                    {
                        # Compare Destination with source using ctime
                        if ($this.SourcePath -and (Test-Path -Path $this.SourcePath))
                        {
                            $sourceCtime = (Get-nxItem -Path $this.SourcePath).CreationTimeUtc
                            $destinationCtime = $nxFileSystemInfo.CreationTimeUtc
                            $isSameFile = $sourceCtime -eq $destinationCtime
                            Write-Verbose -Message (
                                $script:localizedDataNxFile.CompareCtime -f $this.DestinationPath, $destinationCtime, $sourceCtime
                            )

                            if ($this.Contents)
                            {
                                # Do not compare contents if the comparison is done by checksum
                                $currentState.Contents = $this.Contents
                            }
                        }
                        elseif (-not (Test-Path -Path $this.SourcePath))
                        {
                            throw ($script:localizedDataNxFile.SourcePathNotFound -f $this.SourcePath)
                        }
                    }

                    'mtime' # Modify time (data)
                    {
                        # Compare Destination with Source using mtime
                        if ($this.SourcePath -and (Test-Path -Path $this.SourcePath))
                        {
                            $sourceMtime = (Get-nxItem -Path $this.SourcePath).LastWriteTimeUtc
                            $destinationMtime = $nxFileSystemInfo.LastWriteTimeUtc
                            $isSameFile = $sourceMtime -eq $destinationMtime

                            Write-Verbose -Message (
                                $script:localizedDataNxFile.CompareCtime -f $this.DestinationPath, $destinationMtime, $sourceMtime
                            )

                            if ($this.Contents)
                            {
                                # Do not compare contents if the comparison is done by checksum
                                $currentState.Contents = $this.Contents
                            }
                        }
                        elseif (-not (Test-Path -Path $this.SourcePath))
                        {
                            throw ($script:localizedDataNxFile.SourcePathNotFound -f $this.SourcePath)
                        }
                    }

                    default
                    {
                        # Compare Destination with the provided checksum (ignore source file for comparison)
                        $checksumHashAlgorithm = Get-FileHashAlgorithmFromHash -FileHash $this.Checksum -ErrorAction Stop
                        $currentDestinationFileChecksum = (Get-FileHash -Algorithm $checksumHashAlgorithm -Path $currentState.DestinationPath).Hash
                        Write-Verbose -Message (
                            $script:localizedDataNxFile.CompareChecksum -f $this.Checksum, $currentDestinationFileChecksum
                        )

                        $currentState.Checksum = $currentDestinationFileChecksum
                        $isSameFile = $currentDestinationFileChecksum -eq $this.Checksum

                        if ($this.Contents)
                        {
                            # Do not compare contents if the comparison is done by checksum
                            $currentState.Contents = $this.Contents
                        }
                    }
                }
            }
            elseif ($this.Contents) # no checksum but contents is set. use for comparison
            {

                if ($this.Type -eq 'File')
                {
                    Write-Verbose -Message (
                        $script:localizedDataNxFile.GetFileContent -f $currentState.DestinationPath
                    )

                    $currentState.Contents = Get-Content -Raw -Path $currentState.DestinationPath
                }
                else
                {
                    $currentState.Contents = $this.Contents # to make sure it does not flag in the comparison
                }

            }
            else
            {
                # if we don't check against the source, against a provided checksum, or against the provided content
                # assume it's the same file because the file already exists ([ensure]::Present)
                $isSameFile = $true
            }

            if ($isSameFile)
            {
                $currentState.Checksum = $this.Checksum
            }

            $valuesToCheck = @(
                # DestinationPath can be skipped because it's determined with Ensure absent/present
                # SourcePath is write-only property
                'Ensure'
                'Type'
                'Contents'
                'Checksum'
                'Mode'
                # Force is write-only property
                # Recurse is write-only property
                'Owner'
                'Group'

            ).Where({ $null -ne $this.$_ }) #remove properties not set from comparison

            $compareStateParams = @{
                CurrentValues = ($currentState | Convert-ObjectToHashtable)
                DesiredValues = ($this | Convert-ObjectToHashtable)
                ValuesToCheck = $valuesToCheck
                IncludeValue  = $true
            }

            $comparedState = Compare-DscParameterState @compareStateParams

            $currentState.reasons = switch ($comparedState.Property)
            {
                'Ensure'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Ensure' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.nxFileShouldBeAbsent -f $this.DestinationPath
                    }
                }

                'Type'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Type' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.TypeMismatch -f $this.DestinationPath, $this.Type, $currentState.Type
                    }
                    break # If the type is wrong, we can't recover from this.
                }

                'Contents'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Contents' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.ContentsMismatch -f $this.DestinationPath, $this.Contents, $currentState.Contents
                    }
                }

                'Checksum'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Checksum' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.ChecksumMismatch -f $this.DestinationPath, $this.Checksum, $currentState.Checksum
                    }
                }

                'Mode'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Mode' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.ModeMismatch -f $this.DestinationPath, $this.Mode, $currentState.Mode
                    }
                }

                'Owner'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Owner' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.OwnerMismatch -f $this.DestinationPath, $this.Owner, $currentState.Owner
                    }
                }

                'Group'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Group' -f $this.GetType()
                        Phrase = $script:localizedDataNxFile.GroupMismatch -f $this.DestinationPath, $this.Group, $currentState.Group
                    }
                }
            }
        }
        else
        {
            # No item found for this Destination path
            $currentState.Ensure = [Ensure]::Absent

            if ($this.Ensure -ne $currentState.Ensure)
            {
                # We expected the file to be Present
                $currentState.Reasons = [Reason]@{
                    Code = '{0}:{0}:Ensure' -f $this.GetType()
                    Phrase = $script:localizedDataNxFile.nxItemNotFound -f $this.DestinationPath
                }
            }
            else
            {
                Write-Verbose -Message ($script:localizedDataNxFile.nxFileInDesiredState -f  $this.DestinationPath)
            }
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()
        $testTargetResourceResult = $currentState.Reasons.count -eq 0

        return $testTargetResourceResult
    }

    [void] Set()
    {
        $currentState = $this.Get()

        if ($this.Ensure -eq [Ensure]::Present) # Desired State: Ensure present
        {
            if ($currentState.Ensure -ne $this.Ensure) # but is absent
            {
                Write-Verbose -Message (
                    $script:localizedDataNxFile.CreateFile -f $this.DestinationPath
                )

                # Copy from source or
                # Create new file [with content]
                New-Item -ItemType $this.Type -Path $this.DestinationPath -Value $this.Contents -Force:($this.Force)
                Set-nxMode -Path $this.DestinationPath -Mode $this.Mode
                Set-nxGroupOwnership -Path $this.DestinationPath -Group $this.Group
                Set-nxOwner -Path $this.DestinationPath -Owner $this.Owner

            }
            elseif ($currentState.Reasons.Count -gt 0)
            {
                # The file exists but is not properly configured
                Write-Verbose -Message (
                    $script:localizedDataNxFile.SetFile -f $this.DestinationPath
                )

                switch -Regex ($currentState.Reasons.Code)
                {
                    # DestinationPath can be skipped because it's determined with Ensure absent/present
                    # SourcePath is write-only property
                    # 'Ensure' is managed by the file being present or not (already covered)
                    'Type' # if an item of different type, throw... (we can't delete the item to create a new one)
                    {
                        throw ($script:localizedDataNxFile.SetTypeError -f $this.DestinationPath, $this.Type, $currentState.Type)
                    }

                    'Contents'
                    {
                        Write-Verbose -Message (
                            $script:localizedDataNxFile.SetFileContent -f $this.DestinationPath
                        )

                        [System.IO.File]::WriteAllText($currentState.DestinationPath, $this.Contents) # Set content adds a new line
                    }

                    'Checksum'
                    {
                        # either copy from source
                        if ($this.SourcePath -and (Test-Path -Path $this.SourcePath))
                        {
                            Write-Verbose -Message (
                                $script:localizedDataNxFile.CopySourceToDestination -f $this.SourcePath, $this.DestinationPath
                            )

                            Copy-Item -Confirm:$false -Path $this.SourcePath -Destination $this.DestinationPath -Force -Recurse:($this.Recurse)
                        }
                        elseif ($this.Contents -and $this.Type -eq 'File')
                        {
                            Write-Verbose -Message (
                                $script:localizedDataNxFile.SetFileContent -f $this.SourcePath
                            )

                            # or set content from $this.Contents
                            Set-Content -Path $this.DestinationPath -Value $this.Contents -Confirm:$false -Force
                        }
                    }

                    'Mode'
                    {
                        Set-nxMode -Path $this.DestinationPath -Mode $this.Mode -Recurse:($this.Force) -Confirm:$false -Force:($this.Force)
                    }

                    # Force is write-only property
                    # Recurse is write-only property
                    'Owner'
                    {
                        Set-nxOwner -Path $this.DestinationPath -Owner $this.Owner -Recurse:($this.Recurse) -Force:($this.Force) -Confirm:$false
                    }

                    'Group'
                    {
                        Set-nxGroupOwnership -Path $this.DestinationPath -Group $this.Group -Recurse:($this.Recurse) -Force:($this.Force) -Confirm:$false
                    }
                }
            }
            else
            {
                # Set has been invoked but the file is compliant with the desired state (no reasons found).
            }
        }
        else # Desired to be Absent
        {
            $nxFileSystemInfo = Get-nxItem -Path $this.DestinationPath -ErrorAction Stop | Where-Object -FilterScript { $this.Type -eq $_.nxFileSystemItemType}
            if ($nxFileSystemInfo -and $currentState.Ensure -eq [Ensure]::Present)
            {
                Remove-Item -Path $nxFileSystemInfo.FullName -Force:($this.Force) -Recurse:($this.Recurse) -Confirm:$false
            }
        }
    }
}
