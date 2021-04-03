<img align="right" width='128px' src="./source/assets/pstux.png" alt="Tux loves PS">

# nxtools [![Azure DevOps builds](https://img.shields.io/azure-devops/build/Synedgy/nxtools/10)](https://synedgy.visualstudio.com/nxtools/_build?definitionId=10&_a=summary)


[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/nxtools?label=nxtools%20Preview)](https://www.powershellgallery.com/packages/nxtools/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/nxtools?label=nxtools)](https://www.powershellgallery.com/packages/nxtools/)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/SynEdgy/nxtools/1)](https://synedgy.visualstudio.com/nxtools/_test/analytics?definitionId=10&contextType=build)
![Azure DevOps coverage](https://img.shields.io/azure-devops/coverage/Synedgy/nxtools/10)
![PowerShell Gallery](https://img.shields.io/powershellgallery/p/nxtools)


Collection of Posix tools wrappers.

## Introduction

- `Get-nxFileSystemChildItem`: Similar to Get-ChildItem for the FileSystem provider but on Linux, this will use the `ls` command.
- `Get-nxLinuxStandardBaseRelease`: A quick wrap of `lsb_release -a` command (this `lsb_release` must be present on the system).
- `Get-nxOSDistributionInfo`: Parsing information found in `/etc/*-release`.
- `Get-nxKernelInfo`: A simple wrapper around `uname -a`.
- `Compare-nxFileSystemPermission`: An easy way to compare two sets of unix file system permissions.  
    You can use a Symbolic notation (`rwxrwxrwx`), or the numericla permission (`777` or `0777`).

## Notes

Thanks [SoSplush](https://sosplush.com/) ([@SoSplush](https://twitter.com/SoSplush)) for the Tux design.
