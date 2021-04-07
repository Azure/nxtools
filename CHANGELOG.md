# Changelog for nxtools

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial addition of commandd:
    - `Get-nxKernelInfo`: A simple wrapper around `uname -a`.
    - `Get-nxLinuxStandardBaseRelease`: A quick wrap of `lsb_release -a` command (this `lsb_release` must be present on the system).
    - `Get-nxDistributionInfo`: Parsing information found in `/etc/*-release`.
    - `Get-nxItem`: Similar to Get-Item for file system provider but on Linux using `ls -d`.
    - `Get-nxChildItem`: Similar to Get-ChildItem for the FileSystem provider but on Linux, this will use the `ls` command.
    - `Compare-nxFileSystemMode`: An easy way to compare two sets of unix file system permissions.  
        You can use a Symbolic notation (`rwxrwxrwx`), or the numericla permission (`777` or `0777`).
    - `Get-nxLocalUser`: Read and parse local users from `/etc/passwd`.
    - `Get-nxLocalGroup`: Read and parse local groups from `/etc/group`.
    - `Set-nxMode`: Set files and folder mode (permisisons) using `chmod`.
    - `Set-nxOwner`: Set the owner for files and folders (and optionally the group ownership) using `chown`.
    - `Set-nxGroupOwnership`: Set the group owning the files and folders using `chgrp`.
    - `Get-nxLocalUserMemberOf`: Get the groups (`[nxLocalGroup[]]`) a Local user is member of.

- Supporting Enums and Classes for File System permissions.
    - In order to make interpretation, Comparison, and manipulation of File system permissions easier,
      the module implements a few classes and enum to make that work.

### Changed

- Moved source in subfolders per categories (File/Folders, User/Groups).

### Fixed

- Fixed the main branch to release from to be `main` instead of `master`.
- Removing the 'Configure winrm' tasks (as we're only running on linux).
- Added the DocGenerator tasks to build.yaml.
- Fixed casing to `nxtools` because I can't change PSGallery package casing.
