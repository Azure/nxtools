$script:localizedDataNxGroup = Get-LocalizedData -DefaultUICulture 'en-US' -FileName 'nxGroup'

[DscResource()]
class nxGroup
{
    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [DscProperty(Key)]
    [System.String] $GroupName

    [DscProperty()]
    [System.String[]] $Members

    [DscProperty()]
    [System.String[]] $MembersToInclude

    [DscProperty()]
    [System.String[]] $MembersToExclude

    [DscProperty()]
    [System.String] $PreferredGroupID

    [DscProperty(NotConfigurable)]
    [Reason[]] $Reasons

    [nxGroup] Get()
    {
        Write-Verbose -Message (
            $script:localizedDataNxGroup.RetrieveGroup -f $this.GroupName
        )

        $nxLocalGroup = Get-nxLocalGroup -GroupName $this.GroupName
        $currentState = [nxGroup]::new()
        $currentState.GroupName = $this.GroupName

        if ($nxLocalGroup) # The group with this name exists
        {
            Write-Verbose -Message ($script:localizedDataNxGroup.nxGroupFound -f $this.GroupName)
            $currentState.Ensure = [Ensure]::Present
            $currentState.GroupName = $nxLocalGroup.GroupName # Make sure we get exactly what's in /etc/passwd
            $currentState.Members = $nxLocalGroup.GroupMember # Only compare during Exact match

            if ($this.MembersToInclude -and -not $this.Members) # Contains
            {
                $currentState.MembersToInclude = $nxLocalGroup.GroupMember.Where({$_ -in $this.MembersToInclude})
            }

            if ($this.MembersToExclude -and -not ($this.Members)) # Not Contains
            {
                # If it should be excluded but is present, remove it so the compare picks the difference on the right group.
                $currentState.MembersToExclude = $this.MembersToExclude.Where({$_ -notin $nxLocalGroup.GroupMember})
            }

            $currentState.PreferredGroupID = $nxLocalGroup.GroupID

            $valuesToCheck = @(
                # GroupName can be skipped because it's determined with Ensure absent/present
                'Ensure'
                'Members'
                'MembersToInclude'
                'MembersToExclude'
                'PreferredGroupID'
            ).Where({ $null -ne $this.$_ }) #remove properties not set from comparison

            $compareStateParams = @{
                CurrentValues   = ($currentState | Convert-ObjectToHashtable)
                DesiredValues   = ($this | Convert-ObjectToHashtable)
                ValuesToCheck   = $valuesToCheck
                IncludeValue    = $true
                SortArrayValues = $true
            }

            $comparedState = Compare-DscParameterState @compareStateParams

            $currentState.reasons = switch ($comparedState.Property)
            {
                'Ensure'
                {
                    [Reason]@{
                        Code = '{0}:{0}:Ensure' -f $this.GetType()
                        Phrase = $script:localizedDataNxGroup.nxLocalGroupShouldBeAbsent -f $this.GroupName
                    }
                }

                'Members'
                {
                    $Property = $comparedState.Where({$_.Property -eq 'Members'})
                    $missingMembers = $Property.ExpectedValue.Where({$_ -notin $Property.ActualValue})
                    $ExtraMembers = $Property.ActualValue.Where({$_ -notin $Property.ExpectedValue})

                    [Reason]@{
                        Code = '{0}:{0}:Members' -f $this.GetType()
                        Phrase = $script:localizedDataNxGroup.MembersMismatch -f $this.GroupName, ($missingMembers -join ', '), ($ExtraMembers -join ', ')
                    }
                }

                'MembersToInclude'
                {
                    $Property = $comparedState.Where({$_.Property -eq 'MembersToInclude'})
                    $missingMembers = $Property.ExpectedValue.Where({$_ -notin $Property.ActualValue})

                    [Reason]@{
                        Code = '{0}:{0}:MembersToInclude' -f $this.GetType()
                        Phrase = $script:localizedDataNxGroup.MembersToIncludeMismatch -f $this.GroupName, ($missingMembers -join ', '), ($missingMembers -join ',')
                    }
                }

                'MembersToExclude'
                {
                    $Property = $comparedState.Where({$_.Property -eq 'MembersToExclude'})
                    $UndesiredMembers = $this.MembersToExclude.Where({$_ -notin $Property.ActualValue})

                    [Reason]@{
                        Code = '{0}:{0}:MembersToExclude' -f $this.GetType()
                        Phrase = $script:localizedDataNxGroup.MembersToExcludeMismatch -f $this.GroupName,  ($UndesiredMembers -join ', ')
                    }
                }

                'PreferredGroupID'
                {
                    [Reason]@{
                        Code = '{0}:{0}:PreferredGroupID' -f $this.GetType()
                        Phrase = $script:localizedDataNxGroup.PreferredGroupIDMismatch -f $this.GroupName,  $this.PreferredGroupID, $currentState.PreferredGroupID
                    }
                }
            }
        }
        else # no matching group for 'Name'
        {
            $currentState.Ensure = [Ensure]::Absent
            $currentState.GroupName = $this.GroupName
            Write-Verbose -Message ($script:localizedDataNxGroup.nxLocalGroupNotFound -f $this.GroupName)
            if ($this.Ensure -ne $currentState.Ensure)
            {
                $currentState.reasons = [Reason]@{
                    Code = '{0}:{0}:Ensure' -f $this.GetType()
                    Phrase = $script:localizedDataNxGroup.nxLocalGroupNotFound -f $this.GroupName
                }
            }
            else
            {
                Write-Verbose -Message ('The group ''{0}'' is in the desired state' -f $this.GroupName)
            }
        }

        return $currentState
    }

    [bool] Test()
    {
        $currentState = $this.Get()
        $testTargetResourceResult = $currentState.Reasons.Where({$_.Code -notmatch ':PreferredGroupID$'}).count -eq 0

        return $testTargetResourceResult
    }

    [void] Set()
    {
        # Not implemented yet
        # throw 'Set not implemented yet'

        $currentState = $this.Get()

        if ($this.Ensure -eq [Ensure]::Present) # Desired State: Ensure present
        {
            if ($currentState.Ensure -eq [Ensure]::Absent) # but is absent
            {
                Write-Verbose -Message (
                    $script:localizedDataNxUser.CreateGroup -f $this.GroupName
                )

                $newNxLocalGroupParams = @{
                    GroupName = $this.GroupName
                    PassThru = $true
                    Confirm = $false
                }

                if ($this.PreferredGroupID)
                {
                    $newNxLocalGroupParams['GroupID'] = $this.PreferredGroupID
                }

                $nxLocalGroup = New-nxLocalGroup @newNxLocalGroupParams

                if ($this.Members)
                {
                    Set-nxLocalGroup -GroupName $this.GroupName -Member $this.Members
                }
                else
                {
                    if ($this.MembersToExclude)
                    {
                        $this.MembersToExclude.Where({
                            $_ -in $nxLocalGroup.GroupMember
                        }) | Remove-nxLocalGroupMember -UserName $_ -GroupName $this.GroupName -Confirm:$false
                    }

                    if ($this.MembersToInclude)
                    {
                        $this.MembersToInclude.Where({
                            $_ -notin $nxLocalGroup.GroupMember
                        }) | Add-nxLocalGroupMember -GroupName $this.GroupName -Confirm:$false
                    }
                }
            }
            elseif ($currentState.Reasons.Count -gt 0)
            {
                $nxLocalGroup = Get-nxLocalGroup -GroupName $this.GroupName
                # The Group exists but is not set properly
                switch -Regex ($currentState.Reasons.Code)
                {
                    ':PreferredGroupID$'
                    {
                        Write-Verbose -Message "Attempting to set the GroupID to '$($this.PreferredGroupID)'."
                        Set-nxLocalGroupGID -GroupName $nxLocalGroup.GroupName -GroupID $this.PreferredGroupID -Confirm:$false
                    }

                    ':Members$'
                    {
                        Write-Verbose -Message "Attempting to set the Members for group '$($nxLocalGroup.GroupName)' to '$($this.Members -join "', '")'."
                        Set-nxLocalGroup -GroupName $nxLocalGroup.GroupName -Member $this.Members -Confirm:$false
                    }

                    ':MembersToInclude$'
                    {
                        if (-not $this.Members)
                        {
                            Write-Verbose -Message "Attempting to add missing Members to Include for group '$($nxLocalGroup.GroupName)' to '$($this.MembersToInclude -join "', '")'."
                            $this.MembersToInclude.Where({
                                $_ -notin $nxLocalGroup.GroupMember
                            }) | Add-nxLocalGroupMember -GroupName $this.GroupName -Confirm:$false
                        }
                    }

                    ':MembersToExclude$'
                    {
                        if (-not $this.Members)
                        {
                            $usersToRemoveFromGroup = $this.MembersToExclude.Where({
                                $_ -in $nxLocalGroup.GroupMember
                            })

                            Write-Verbose -Message "Attempting to remove extra Members Excluded from group '$($nxLocalGroup.GroupName)' ('$($usersToRemoveFromGroup -join "', '")')."
                            $usersToRemoveFromGroup | Remove-nxLocalGroupMember -GroupName $this.GroupName -Confirm:$false
                        }
                    }
                }
            }
            else
            {
                # Set() invoked but no change needed.
            }
        }
        else
        {
            # Desired state: Ensure Absent
            if ($currentState.Ensure -eq [Ensure]::Present)
            {
                Remove-nxLocalGroup -GroupName $this.GroupName -Force -Confirm:$false
            }
        }
    }
}
