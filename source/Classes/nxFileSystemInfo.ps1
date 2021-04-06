
class nxFileSystemInfo : System.IO.FileSystemInfo
{
    [nxFileSystemMode] $Mode
    [nxFileSystemItemType] $nxFileSystemItemType
    [int] $nxLinkCount
    [System.String] $nxOwner
    [System.String] $nxGroup
    [long] $Length

    [string] $Name
    [datetime] $LastWriteTime

    nxFileSystemInfo ([System.Collections.IDictionary]$properties)
    {
        Write-Verbose -Message "Creating [nxFileSystemInfo] with path '$($properties.FullPath)'."
        $this.OriginalPath = $properties.FullPath
        $this.FullPath = $properties.FullPath
        $this.SetPropertiesFromIDictionary($properties)
        $this.Name = [System.Io.Path]::GetFileName($this.FullPath)
    }

    hidden [void] SetPropertiesFromIDictionary ([System.Collections.IDictionary]$properties)
    {
        Write-Verbose -Message "Setting Propeties from Dictionary."

        $properties.keys.Foreach{
            if ($this.psobject.Properties.name -contains $_)
            {
                try
                {
                    Write-Debug -Message "`tAdding '$_' with value '$($properties[$_])'."
                    $this.($_) = $properties[$_]
                }
                catch
                {
                    Write-Warning -Message $_.Exception.Message
                }
            }
            else
            {
                Write-Verbose -Message "The key '$_' is not a property."
            }
        }
    }

    nxFileSystemInfo([string]$Path)
    {
        # ctor
        $this.OriginalPath = $Path
        $this.FullPath = [System.IO.Path]::GetFullPath($Path)
        $this.Name = [System.Io.Path]::GetFileName($this.FullPath)
    }

    [void] Delete()
    {
        Remove-Item -Path $this.FullName -ErrorAction Stop
        $this.Dispose()
    }

    hidden [string] GetModeWithItemType()
    {
        $modeSymbol = $this.Mode.ToString()
        $typeSymbol = switch ($this.nxFileSystemItemType)
        {
            ([nxFileSystemItemType]::File) { '-' }
            ([nxFileSystemItemType]::Directory) { 'd' }
            ([nxFileSystemItemType]::Link) { 'l' }
            ([nxFileSystemItemType]::Socket) { 's' }
            ([nxFileSystemItemType]::Pipe) { 'p' }
        }

        return ('{0}{1}' -f $typeSymbol,$modeSymbol)
    }
}
