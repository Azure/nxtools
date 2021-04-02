
[Flags()]
enum nxFileSystemSpecialMode
{
    SetUserId  = 4 # S_ISUID: Set user ID on execution
    SetGroupId = 2 # S_ISVTX: Set group ID on execution
    StickyBit  = 1 # S_ISVTX: Sticky bit
    None       = 0
}
