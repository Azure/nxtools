
# This will be a DSC Resource, eventually
class nxPackage
{
    [Ensure] $Ensure
    [String] $Name
    [String] $Version
    [String] $PackageType

    [bool] IsInstalled()
    {
        return $false
    }
}
