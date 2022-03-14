function Get-nxSourceFile
{
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateScript({$null -ne ($_ -as [uri]).Scheme -or (Test-Path -Path $_ -PathType Leaf)})]
        [Alias('Uri')]
        $Path,

        [Parameter()]
        [System.String]
        $DestinationFile,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if (-not $PSBoundParameters.ContainsKey('DestinationFile'))
    {
        $fileName = [System.Io.FileInfo](Split-Path -Leaf $Path)
        if ($null -ne ($Path -as [uri]).Scheme -and -not [string]::IsNullOrEmpty($fileName.Extension))
        {
            $DestinationFile = $fileName
        }
    }

    if (Test-Path -Path $DestinationFile)
    {
        if ($Force.IsPresent)
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
