# Examples

This will help to understand how to setup certain scenarios with nxtools
resource module.

## Guest Configuration Resources Examples

The GC Resources are DSC Resources that only supports String, Int, bool as properties because of how they are interepreted in Azure ARM.

To emulate arrays of strings or int, the GC Resource author should use a value separator, such as `;`.

- [GC_LinuxGroup](../GCPackages/LinuxGroupsMustExclude)
- [GC_InstalledApplicationLinux](../GCPackages/InstalledApplicationLinux)
- [GC_NotInstalledApplicationLinux](../GCPackages/NotInstalledApplicationLinux)

## Resource examples

These are the links to the examples for each individual resource.

- [nxFile](./Resources/nxFile/)
- [nxGroup](./Resources/nxGroup/)
- [nxUser](./Resources/nxUser/)
- [nxFileLine](./Resources/nxFileLine/)
- [nxFileContentReplace](./Resources/nxFileContentReplace/)
source\Examples\Resources\nxUser
