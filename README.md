---
ArtifactType: nupkg, executable, azure-web-app, azure-cloud-service, etc. More requirements for artifact type standardization may come later.
Documentation: URL
Language: typescript, csharp, java, js, python, golang, powershell, markdown, etc. More requirements for language names standardization may come later.
Platform: windows, node, linux, ubuntu16, azure-function, etc. More requirements for platform standardization may come later.
Stackoverflow: URL
Tags: comma,separated,list,of,tags
---

# nxtools [![Azure DevOps builds](https://img.shields.io/azure-devops/build/Synedgy/nxtools/10)](https://synedgy.visualstudio.com/nxtools/_build?definitionId=10&_a=summary)

[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/nxtools?label=nxtools%20Preview)](https://www.powershellgallery.com/packages/nxtools/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/nxtools?label=nxtools)](https://www.powershellgallery.com/packages/nxtools/)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/SynEdgy/nxtools/10)](https://synedgy.visualstudio.com/nxtools/_test/analytics?definitionId=10&contextType=build)
![Azure DevOps coverage](https://img.shields.io/azure-devops/coverage/Synedgy/nxtools/10)
![PowerShell Gallery](https://img.shields.io/powershellgallery/p/nxtools)


Collection of Posix tools wrappers.

This module intend to make managing Linux or Unix systems easier for PowerShell users.
It does so by:
- Providing PowerShell wrappers around well known commands.
- Leveraging PowerShell's idosyncratic value-add such as Pipeline, streams and more.
- Passing through objects such as `[nxLocalUser]`, `[nxLocalGroup]`, `[nxFile]`, removing the need for parsing.
- Offering cmdlets for imperative invocation.
- DSC Resources for declarative state representation to use with Azure Policy Guest Configuration.
- Pre-built Guest Configuration Package to be used in Policies.

---

## Getting Started

On a fresh clone, you should be able to get by after installing GitVersion by building like so:  
```
build.ps1 -Tasks build
```  
This will build the nxtools module in your `output/module` folder.

Should you want to build the GuestConfiguration packge, run the following instead:  
```powershell
build.ps1 -Tasks gcpol
```

### Prerequisites

PowerShell must be installed on your system.  
To build this project, GitVersion is recommended to build the right version according to your git status.

### Installing

You can install `nxtools` module from the PowerShell Gallery:  
```powershell
Install-Module -Name nxtools
```

---
## Usage

## Introduction

The goal is to help handle the most common tasks:
- User and group management
- File system operations (changing mode, owner, listing, set/replace content)
- Service management (start, stop, restart, remove, add)
- Archive operations (compress, extract)
- Package Management (list, search, install, uninstall packages)

## Commands

Here are the public commands available.

### Archive

- `Compress-nxArchive`: Create an archive and add files and folders to it.
- `Expand-nxArchive`: Expand the file and folders out of an archive.

### File Content

- `Add-nxFileLine`: Append or insert a line if it's not present. The line can be inserted before or after a pattern is found in the file.
- `Invoke-nxFileContentReplace`: Edit a file by searching for a pattern, and replacing it by an expression or script block. This can also be done over multiple line to replace several lines in one run.
- `Remove-nxFileLine`: Remove specific lines from a file by line number. You can use this with `Select-String` to know which line to remove.  

### File System

- `Get-nxItem`: Similar to Get-Item for file system provider but on Linux using `ls -d`.
- `Get-nxChildItem`: Similar to Get-ChildItem for the FileSystem provider but on Linux, this will use the `ls` command.
- `Compare-nxFileSystemMode`: An easy way to compare two sets of unix file system permissions.  
    You can use a Symbolic notation (`rwxrwxrwx`), or the numericla permission (`777` or `0777`).
- `Set-nxMode`: Set files and folder mode (permisisons) using `chmod`.
- `Set-nxOwner`: Set the owner for files and folders (and optionally the group ownership) using `chown`.
- `Set-nxGroupOwnership`: Set the group owning the files and folders using `chgrp`.

### User And Groups

- `Get-nxLocalUser`: Read and parse local users from `/etc/passwd`.
- `Get-nxLocalGroup`: Read and parse local groups from `/etc/group`.
- `Get-nxLocalUserMemberOf`: Get the groups (`[nxLocalGroup[]]`) a Local user is member of.
- `New-nxLocalUser`: Creates a new Local User using `useradd`.
- `Add-nxLocalGroupMember`: Add users to a group using `gpasswd`.
- `Add-nxLocalUserToGroup`: Add user to groups using `usermod`.
- `New-nxLocalGroup`: Create a new Local Group using `groupadd`.
- `Set-nxLocalGroup`: Set the properties of an existing local group using `gpasswd`.
- `Set-nxLocalGroupMember`: Set (and replace) the members of an existing group using `gpasswd`.
- `Remove-nxLocalUser`: Delete a Local user using `userdel`.
- `Remove-nxLocalGroupMember`: Removes users from a local group using `gpasswd`.
- `Remove-nxLocalGroup`: Deletes a local group using `groupdel`.
- `Get-nxEtcShadow`: Gets a user's `/etc/shadow` entry if it exists.
- `Disable-nxLocalUser`: Lock a user's password, Expire its account and replace its Shell to `/sbin/nologin`.

### System

- `Get-nxKernelInfo`: A simple wrapper around `uname -a`.
- `Get-nxLinuxStandardBaseRelease`: A quick wrap of `lsb_release -a` command (this `lsb_release` must be present on the system).
- `Get-nxDistributionInfo`: Parsing information found in `/etc/*-release`.

## DSC Resources

- `nxFile`: Manage a file or a folder to make sure it's present/absent, its content, mode, owner group.
- `nxGroup`: Simple resource to manage [nxLocalGroup] and group members.
- `nxUser`: Simple resource to manage [nxLocalUser] accounts.
- `nxPackage`: Audit (for now) whether a package is installed or not in a system (currently supports apt only).
- `nxFileLine`: Ensure an exact line is present/absent in a file, and remediate by appending, inserting, deleting as needed.
- `nxFileContentReplace`: Replace the content in a file if a pattern is found.

## Guest Configuration Packages

- `No90CloudInitUserAllowdNoPasswdInSudoers`: Ensure no user are granted NOPASSWD in sudoers file `/etc/sudoers.d/90-cloud-init-users`.
- `InstalledApplicationLinux` [`Audit`]: Ensure the list of packages is installed (dpkg only)
- `LinuxGroupsMustExclude`  [`AuditAndSet`]: List of users that must be excluded from a group.
- `LinuxGroupsMustInclude` [`AuditAndSet`]: List of users that must be included in a group.
- `NotInstalledApplicationLinux` [`Audit`]: Ensure the list of packages is not installed (dpkg only)
- `PasswordPolicy_msid110` [`Audit`]: Remote connections from accounts with empty passwords should be disabled.
- `PasswordPolicy_msid121` [`Audit`]: file `/etc/passwd` permissions should be 0644
- `PasswordPolicy_msid232` [`Audit`]: Ensure there are no accounts without passwords.

## Example

```powershell

Get-nxKernelInfo # uname -a

Get-nxDistributionInfo  # cat /etc/*-release

Get-nxLinuxStandardBaseRelease # lsb_release -a (not available by default on some Debian 10, Alpine and others)

Get-nxLocalUser # cat /etc/passwd
Get-nxLocalUser -UserName (whoami)
Get-nxLocalUser -Pattern '^gcolas$'

Get-nxLocalGroup # cat /etc/group
Get-nxLocalGroup tape | Get-nxLocalUser

Get-nxItem /tmp/testdir
(Get-nxItem /tmp/testdir).Mode
(Get-nxItem /tmp/testdir).Mode.ToString()
(Get-nxItem /tmp/testdir).Mode.ToOctal()

# using module output/nxtools
# using module nxtools
[nxFileSystemMode]'rwxr--r--'
[nxFileSystemMode]'ugo=rwx'
[nxFileSystemMode]'1777'
[nxFileSystemMode]'u=rwx g=r o=r'

# Proper handling of symbolic links not yet implemented
Compare-nxMode -ReferenceMode 'r--r--r--' -DifferenceMode 1777 | FT -a
Get-nxChildItem -Path /tmp/testdir | Compare-nxMode -ReferenceMode 'r--r--r--' | FT -a

Get-nxChildItem /tmp/testdir/ -File | FT -a
Get-nxChildItem /tmp/testdir/ -Directory | FT -a
Get-nxChildItem /tmp/testdir/ | FT -a
Get-nxChildItem /tmp/testdir/ -File | Move-Item -Destination /tmp/testdir/otherdir/ -Verbose
Get-nxChildItem /tmp/testdir/ -File | FT -a
Get-nxChildItem /tmp/testdir/ -File -recurse | FT -a

Set-nxMode -Path /tmp/tmpjBneMD.tmp -Mode 'rwxr--r--' -Recurse -WhatIf  # chmod -R 0744
Set-nxMode -Path /tmp/tmpjBneMD.tmp -Mode '0744' -Recurse -WhatIf       # chmod -R 0744
Set-nxMode -Path /tmp/tmpjBneMD.tmp -Mode 744 -Recurse -Whatif          # chmod -R 0744

# Get the other groups the members of the tape group are member of
Get-nxLocalGroup tape | Get-nxLocalUser | Get-nxLocalUserMemberOf

Set-nxOwner -Path /tmp/tmpjBneMD.tmp  -Owner (whoami) # chown gcolas /tmp/tmpjBnedMD.tmp

Set-nxGroupOwnership -Path /tmp/testdir -Recurse -Group users -RecursivelyTraverseSymLink


```

---
## Running the tests

Integration tests can be run on Azure VMs using Test-Kitchen with the [kitchen yaml](./kitchen.yml) provided.
More details will be added.

HQRM tests can be run like so:
```powershell
build.ps1 -Tasks build,hqrmtest
```

### End-to-end tests

N/A: End to end tests integrated with Guest Config are not yet implemented.

### Unit tests

Integration tests using Test-Kitchen

---
## Deployment

Deployment is privately done after QA checks.

## Contributing

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) which outlines all of our policies, procedures, and requirements for contributing to this project.  
Currently, we cannot accept contributions.

## Versioning and changelog

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [PSGallery](https://powershellgallery.com/packages/nxtools).

It is a good practice to keep `CHANGELOG.md` file in repository that can be updated as part of a pull request.

## Authors

- [gaelcolas](https://github.com/gaelcolas)

## License

This project is licensed under the MIT - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

* Hat tip to FX Cat, who's donated the `nxtools` PSGallery package.
* Thank you to the [DSC Community](https://dsccommunity.org) for building, maintaining and improving all the build and testing tools.
