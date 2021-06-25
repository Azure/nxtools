<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource nxFile.
#>

ConvertFrom-StringData @'
    nxFileShouldBeAbsent = The item '{0}' was found but should be 'Absent'.
    TypeMismatch = The Type for item '{0}' was expected to be '{1} but was '{2}' instead.
    ContentsMismatch = The Content of '{0}' was not as expected. {2}
    ChecksumMismatch = The DestinationPath '{0}' with checksum, '{2}' did not match the expected checksum of '{1}'.
    ModeMismatch = The mode of '{0}' did not match the expected value '{1}'. The Mode is '{2}'.
    OwnerMismatch = The expected Owner for '{0}' is '{1}' but was '{2}' instead.
    GroupMismatch = The expected Group for '{0}' is '{1}' but was '{2}' instead.
    nxItemNotFound = The Item '{0}' was not found.
    nxFileInDesiredState = The item '{0}' is in the Desired State.
    SourcePathNotFound = Source item not found at '{0}'.
    CompareChecksum = Comparing file checksum '{0}' with desired checksum '{1}'.
    CreateFile = Creating the item '{0}' as per the desired state.
    SetFile = Setting the item '{0}' as per the desired state.
    SetTypeError = The item '{0}' of type '{2}' while we desire type '{1}'. We have no way of correcting this at the moment.
    SetFileContent = Setting file content for '{0}'.
    CopySourceToDestination = Copying Source file '{0}' to Destination '{1}'.
    GetFileContent = Getting the raw content of '{0}'.
    CompareCtime = Comparing current item '{0}' ctime of '{1}' against the source '{2}'.
    CompareMtime = Comparing current item '{0}' mtime of '{1}' against the source '{2}'.
'@
