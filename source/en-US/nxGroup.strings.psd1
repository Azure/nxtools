<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource nxGroup.
#>

ConvertFrom-StringData @'
    RetrieveGroup = dummy
    nxGroupFound = dummy
    nxLocalGroupShouldBeAbsent = dummy
    MembersMismatch = The members for Group '{0}' do not match. It's missing '{1}' and has the extra '{2}'.
    MembersToIncludeMismatch = The group '{0}' is missing the following members: {1}.
    MembersToExcludeMismatch = The following members should be excluded from group '{0}': {1}.
    PreferredGroupIDMismatch = The GroupID preferred for group '{0}' is '{1}' but got '{2}.
    nxLocalGroupNotFound = dummy
    CreateGroup = dummy
    SettingProperties = dummy
    EvaluateProperties = dummy
    RemoveNxLocalGroup = dummy
'@
