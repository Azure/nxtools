<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource nxGroup.
#>

ConvertFrom-StringData @'
    RetrieveGroup = Retrieving nxLocalGroup with GroupName '{0}'.
    nxGroupFound = Found nxLocalGroup with GroupName '{0}'.
    nxLocalGroupShouldBeAbsent = The nxLocalGroup with GroupName '{0}' is expected to be absent but is present on the system.
    MembersMismatch = The members for Group '{0}' do not match. It's missing '{1}' and has the extra '{2}'.
    MembersToIncludeMismatch = The group '{0}' is missing the following members: {1}.
    MembersToExcludeMismatch = The following members should be excluded from group '{0}': {1}.
    PreferredGroupIDMismatch = The GroupID preferred for group '{0}' is '{1}' but got '{2}.
    nxLocalGroupNotFound = The nxLocalGroup with name '{0}' was not found but was expected to be present on this system.
    CreateGroup = Creating nxLocalGroup with GroupName '{0}'.
    SettingProperties = Setting the properties for GroupName '{0}'.
    EvaluateProperties = Evaluating Property '{0}'.
    RemoveNxLocalGroup = Removing nxLocalGroup with GroupName '{0}'.
'@
