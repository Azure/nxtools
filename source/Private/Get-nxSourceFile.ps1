function Get-nxSourceFile
{
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateScript({$_ -as [uri] -or (Test-Path -Path $_ -PathType Leaf)})]
        [Alias('Uri')]
        $Path,

        [Parameter()]
        [System.String]
        $DestinationFile,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if (Test-Path -Path $DestinationFile)
    {
        if ($Force)
        {
            Remove-Item -Force -Recurse -Path $DestinationFile
        }
        else
        {
            throw ('File ''{0}'' already exists.' -f $DestinationFile)
        }
    }

    if ($Path -as [uri] -and ([uri]$Path).Scheme -match '^http|^ftp')
    {
        $null = Invoke-WebRequest -Uri $Path -OutFile $DestinationFile -ErrorAction 'Stop'
    }
    else
    {
        Copy-Item -Path $Path -Destination $DestinationFile -ErrorAction Stop -Force:$Force
    }
}
