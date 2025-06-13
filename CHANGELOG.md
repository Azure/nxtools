# Changelog for nxtools

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Improved /etc/shadow file parsing for the nxUser resource.
- Fixed a validation error related to an 'AccessRight' parameter when a file has empty permissions for one or more categories.

## [1.5.0] - 2025-01-28

### Fixed

- Fixed module not working in PowerShell v7.4.x due to nxFileSystemInfo not implementing the abstract property Exists from the base type FileSystemInfo.
- Fixed nxService reporting wrong status on Ubuntu Server 22.04 LTS due to incorrect parsing.
- Fixed nxGroup not removing group members when specifying that the group should be empty.

### Removed

- configuration examples for password policies

## [1.4.0] - 2024-02-08

### Fixed

- Fixed nxPackage crashing when yum is picked as the package manager.
- Fixed nxPackage crashing when dpkg is picked as the package manager and the package is not installed.
- Fixed nxPackage not handling packages with status deinstall.

## [1.3.0] - 2023-10-12

### Fixed

- Fixed nxFile not able to delete files.
- Fixed nxService crashing when auditing a service that does not exist.
- Fixed nxUser failing if any users in /etc/passwd have uppercase letters in their username.

## [1.2.0] - 2023-09-08

### Fixed

- Fixed nxService causing an unknown propertyName error.

## [1.1.0] - 2023-07-18

### Added

- DscResource:
    - `nxScript`: Simple resource for executing scripts in PowerShell 7.

### Fixed

- Fixed nxUser Set function failure when FullName and Description are populated.

## [1.0.0] - 2023-05-25

### Added

- Added PS DSC module dependency and release notes to README.md, including Microsoft copyright.

### Fixed

- Fixed HQRM style non-compliance.
- Fixed issue with nxTools when reporting compliance but package version issue (thanks to Jan Egil Ring).
- Fixed an issue with the nxFile Test function where it was always returning False.
- Fixed nxFileLine causing an unknown propertyName error.

## [0.4.0-preview0001] - 2023-03-16

### Added

- Added KitchenCI tests for the packages on ubuntu-18.04, debian-10, and centos-7.5.
- Added the `Functions` test suite for Kitchen-Pester.
- Added `[nxFileLine]` and `[nxFileContentReplace]` DSC Resources to manage file content.
- Added examples for DSC Resources.
- Added GC Packages to the GitHub release publish step.
- Added cmdlets for Packages:
    - `Get-nxPackageInstalled`: Getting the installed package basic info, automatically finding the Package Manager.
    - `Get-nxYumPackageInstalled`: Getting the installed yum/rpm package basic info.
    - `Get-nxDpkgPackageInstalled`: Getting the installed dpkg/apt package basic info.
    - `Get-nxPackage`: Getting the installed package detailed info, automatically finding the Package Manager.
    - `Get-nxYumPackage`: Getting the installed yum/rpm package detailed info.
    - `Get-nxDpkgPackage`: Getting the installed dpkg/apt package detailed info.

- Added the DSC Resources classes
    - `nxUser`
    - `nxGroup`
    - `nxFile`
    - `nxArchive`
    - `nxPackage`
    - `nxFileLine`
    - `nxFileContentReplace`

- Added GC policy config for creating GC packages
    - InstalledApplicationLinux
    - NotInstalledApplicationLinux
    - linuxGroupsMustExclude
    - linuxGroupsMustInclude
    - msid110
    - msid121
    - msid232

### Fixed

- Fixed the issue on centos/red hat where the MODE contains a trailing `.`.
- Relying on ModuleVersion from Module manifest.

### Changed

- Setting up official pipeline.

### Removed

- Disabling changelog tests because of the way the private repo fetches and errors on the `git diff`.

## [0.2.0] - 2021-05-25

### Added

- Initial addition of commandd:
    - `Get-nxKernelInfo`: A simple wrapper around `uname -a`.
    - `Get-nxLSBRelease`: A quick wrap of `lsb_release -a` command (this `lsb_release` must be present on the system).
    - `Get-nxDistributionInfo`: Parsing information found in `/etc/*-release`.
    - `Get-nxItem`: Similar to Get-Item for file system provider but on Linux using `ls -d`.
    - `Get-nxChildItem`: Similar to Get-ChildItem for the FileSystem provider but on Linux, this will use the `ls` command.
    - `Compare-nxFileSystemMode`: An easy way to compare two sets of unix file system permissions.  
        You can use a Symbolic notation (`rwxrwxrwx`), or the numericla permission (`777` or `0777`).
    - `Get-nxLocalUser`: Read and parse local users from `/etc/passwd`.
    - `New-nxLocalUser`: Create a new Local User using `useradd`.
    - `Set-nxLocalUser`: Set the properties of a Local User using `usermod`.
    - `New-nxLocalGroup`: Create a new Local Group using `groupadd`.
    - `Get-nxLocalGroup`: Read and parse local groups from `/etc/group`.
    - `Set-nxLocalGroup`: Set the properties of an existing local group using `gpasswd`.
    - `Get-nxLocalUserMemberOf`: Get the groups (`[nxLocalGroup[]]`) a Local user is member of.
    - `Add-nxLocalGroupMember`: Add users to a group using `gpasswd`.
    - `Set-nxGroupOwnership`: Set the group owning the files and folders using `chgrp`.
    - `Add-nxLocalUserToGroup`: Add user to groups using `usermod`.
    - `Set-nxMode`: Set files and folder mode (permisisons) using `chmod`.
    - `Set-nxOwner`: Set the owner for files and folders (and optionally the group ownership) using `chown`.
    - `Set-nxLocalGroupMember`: Set (and replace) the members of an existing group using `gpasswd`.
    - `Remove-nxLocalUser`: Delete a Local user using `userdel`.
    - `Remove-nxLocalGroupMember`: Removes users from a local group using `gpasswd`.
    - `Remove-nxLocalGroup`: Delete a local group using `groupdel`.
    - `Get-nxEtcShadow`: Get a user's `/etc/shadow` entry if it exists.
    - `Disable-nxLocalUser`: Lock a user's password, Expire its account and replace its Shell to `/sbin/nologin`.
    - `Enable-nxLocalUser`: Unlock a user's password, can set the ExpireOn date and replace the Shell from a value from `/etc/shells`.
    - `Compress-nxArchive`: Compress files and folders using the `tar` command.
    - `Expand-nxArchive`: Uncompress or read files and folder from an archive using the `tar` command.

- Supporting Enums and Classes for File System permissions.
    - In order to make interpretation, Comparison, and manipulation of File system permissions easier,
      the module implements a few classes and enum to make that work.

- DscResource:
    - `nxUser`: Simple resource to manage [nxLocalUser] accounts.
    - `nxGroup`: Simple resource to manage [nxLocalGroup] and group members.
    - `nxFile`: Simple resource to manage [nxItem] (file or directory).

### Changed

- Moved source in subfolders per categories (File/Folders, User/Groups).
- Testing using Git Tools task (the new GitVersion).

### Fixed

- Fixed the main branch to release from to be `main` instead of `master`.
- Removing the 'Configure winrm' tasks (as we're only running on linux).
- Added the DocGenerator tasks to build.yaml.
- Fixed casing to `nxtools` because I can't change PSGallery package casing.
- Removing dupplicate files.
