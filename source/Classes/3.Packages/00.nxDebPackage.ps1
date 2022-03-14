#using module Package
class nxDebPackage : nxPackage
{
    # https://www.debian.org/doc/debian-policy/ch-controlfields.html

    # This field identifies the source package name.
    $Source

    # The package maintainer’s name and email address.
    # The name must come first, then the email address inside angle brackets <> (in RFC822 format).
    $Maintainer

    # List of the names and email addresses of co-maintainers of the package, if any.
    $Uploaders

    # The name and email address of the person who prepared this version of the package,
    # usually a maintainer. The syntax is the same as for the Maintainer field.
    $ChangedBy

    # This field specifies an application area into which the package has been classified.
    # See Sections.
    $Section

    # This field represents how important it is that the user have the package installed.
    # See Priorities.
    $Priority

    # The name of the binary package.
    # Binary package names must follow the same syntax and restrictions as source package names.
    # See Source for the details.
    # This also populates the Name property of the [Package] parent class
    $Package

    # Depending on context and the control file used, the Architecture field can include the following sets of values:
    #  - A unique single word identifying a Debian machine architecture as described in Architecture specification strings.
    #    (https://www.debian.org/doc/debian-policy/ch-customized-programs.html#s-arch-spec)
    #  - An architecture wildcard identifying a set of Debian machine architectures, see Architecture wildcards.
    #    (https://www.debian.org/doc/debian-policy/ch-customized-programs.html#s-arch-wildcard-spec)
    #    `any` matches all Debian machine architectures and is the most frequently used.
    #  - all, which indicates an architecture-independent package.
    #  - source, which indicates a source package.
    $Architecture

    # This is a boolean field which may occur only in the control file of a binary package or
    # in a per-package fields paragraph of a source package control file.
    # If set to yes then the package management system will refuse to remove the package
    # (upgrading and replacing it is still possible).
    # The other possible value is no, which is the same as not having the field at all.
    $Essential

    #region Package interrelationship fields
    # These fields describe the package’s relationships with other packages.
    # Their syntax and semantics are described in Declaring relationships between packages.
    # (https://www.debian.org/doc/debian-policy/ch-relationships.html)

    $Depends
    $PreDepends
    $Recommends
    $Suggests
    $Breaks
    $Conflicts
    $Provides
    $Replaces
    $Enhances

    #endregion Package interrelationship fields

    $StandardsVersion

    # $Version # defined in Parent Class [Package]
    $Description

    $Distribution
    $Date
    $Format
    $Urgency
    $Changes
    $Binary
    $InstalledSize
    $Files
    $Closes
    $Homepage
    $ChecksumsSha1
    $ChecksumsSha256
    $DMUploadAllowed # obsolete
    $PackageList
    $PackageType
    $Dgit
    $TestSuite
    $RulesRequiresRoot

    # Additional Fields
    $Status
    $OriginalMaintainer
    $MultiArch
    $Conffiles
    $AdditionalFields = @{}

    $Vendor

    nxDebPackage()
    {
        # Default constructor
    }

    nxDebPackage([hashtable]$Properties)
    {
        $this.SetProperties($Properties)
    }

    hidden [void] SetProperties([hashtable]$Properties)
    {
        foreach ($propertyName in $properties.keys)
        {
            $this.($propertyName) = $properties[$propertyName]
        }

        if ($properties.keys -contains 'package' -and $properties.keys -notcontains 'name')
        {
            $this.Name = $properties['package']
        }
    }
}
