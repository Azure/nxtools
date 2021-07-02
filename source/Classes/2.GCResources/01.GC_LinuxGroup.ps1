[DscResource()]
class GC_LinuxGroup : nxGroup
{
    [DscProperty()]
    [System.String] $MembersAsString

    [DscProperty()]
    [System.String] $MembersToIncludeAsString

    [DscProperty()]
    [System.String] $MembersToExcludeAsString

    GC_LinuxGroup()
    {
        # default ctor
    }

    GC_LinuxGroup ([nxGroup] $nxGroup)
    {
        $this.GroupName = $nxGroup.GroupName
        $this.Members = $nxGroup.Members
        $this.MembersToInclude = $nxGroup.MembersToInclude
        $this.MembersToExclude = $nxGroup.MembersToExclude
        $this.Reasons = $nxGroup.Reasons
        $this.Ensure = $nxGroup.Ensure
        $this.PreferredGroupID = $nxGroup.PreferredGroupID

        $this.MembersAsString = $nxGroup.Members -join ';'
        $this.MembersToExcludeAsString = $nxGroup.MembersToExclude -join ';'
        $this.MembersToIncludeAsString = $nxGroup.MembersToInclude -join ';'
    }

    [void] ConvertAsStringToBaseClass()
    {
        if ($null -ne $this.MembersToIncludeAsString)
        {
            $this.MembersToInclude = $this.MembersToIncludeAsString -split ';'
        }

        if ($null -ne $this.MembersToExcludeAsString)
        {
            $this.MembersToExclude = $this.MembersToExcludeAsString -split ';'
        }

        if ($null -ne $this.MembersAsString)
        {
            $this.Members = $this.MembersAsString -split ';'
        }
    }

    [GC_LinuxGroup] Get()
    {
        $this.ConvertAsStringToBaseClass()

        return ([GC_LinuxGroup]([nxGroup]$this).Get())
    }

    [bool] Test()
    {
        $currentState = $this.Get()
        $testTargetResourceResult = $currentState.Reasons.Where({$_.Code -notmatch ':PreferredGroupID$'}).count -eq 0

        return $testTargetResourceResult
    }

    [void] Set()
    {
        $this.ConvertAsStringToBaseClass()
        ([nxGroup]$this).Set()
    }
}
