<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DSC_CLassFolder.
#>

ConvertFrom-StringData @'
    RetrieveUser = Retrieving nxLocalUser with UserName '{0}'.
    nxUserFound = The nxLocalUser with UserName '{0}' was found.
    nxLocalUserShouldBeAbsent = The nxLocalUser with UserName '{0}' is present but is expected to be absent from the System.
    FullNameMismatch = The nxLocalUser with UserName '{0}' has a Full name of '{1}' while we expected '{2}'.
    DescriptionMismatch = The nxLocalUser with UserName '{0}' has an unexpected Description: '{1}'.
    PasswordMismatch = The nxLocalUser with UserName '{0}' has an unexpected Password.
    DisabledMismatch = The nxLocalUser with UserName '{0}' has the Disabled flag set to '{1}'.
    PasswordChangeRequiredMismatch = The nxLocalUser with UserName '{0}' has the PasswordChangeRequired flag set to '{1}' instead of '{2}'.
    HomeDirectoryMismatch = The nxLocalUser with UserName '{0}' has the HomeDirectory set to '{1}' instead of '{2}'.
    GroupIDMismatch = The nxLocalUser with UserName '{0}' has a GroupID set to '{1}' instead of '{2}'.
    nxLocalUserNotFound = The nxLocalUser with UserName '{0}' was not found but is expected to be present.
    CreateUser = Creating the nxLocalUser with UserName '{0}'.
    SettingProperties = Setting the properties for the nxLocalUser with UserName '{0}'.
    EvaluateProperties = Evaluating property '{0}' for nxLocalUser with UserName {1}'.
    RemoveNxLocalUser = Removing the nxLocalUser with UserName '{0}'.
'@
