#using module Package
class nxDpkgPackage : nxDebPackage
{
    # Same fields as Deb packages

    nxDpkgPackage()
    {
        #Default ctor
    }

    nxDpkgPackage([hashtable]$Properties)
    {
        $this.SetProperties($Properties)
    }
}
