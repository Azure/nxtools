class nxAptPackage : nxDebPackage
{
    #Extends nxDebPackage
    $FileName
    $Descriptionmd5
    $Size
    $MD5sum
    $Origin
    $License
    $SHA512
    $SHA256
    $SHA1
    $Descriptionen

    nxAptPackage()
    {
        #Default ctor
    }

    nxAptPackage([hashtable]$Properties)
    {
        $this.SetProperties($Properties)
    }
}
