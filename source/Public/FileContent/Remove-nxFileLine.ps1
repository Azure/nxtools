function Remove-nxFileLine
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [int[]]
        $LineNumber,

        [Parameter()]
        [String]
        $Encoding = 'UTF8'
    )

    Write-Debug -Message "Removing Lines to file '$Path'."

    # Read through the file, inserting the edits and adding all lines to them file.
    $getContentsParams = @{
        Path = $Path
        Encoding = $Encoding
    }

    $tempFile = [System.IO.Path]::GetTempFileName()
    $setContentParams = $getContentsParams.Clone()
    $setContentParams['Path'] = $tempFile
    [int]$CurrentLine = 0 #start at -1 so that as soon as you increment it goes to 0 (the first line).

    Get-Content @getContentsParams | ForEach-Object -Process { # Stream
        $CurrentLine++ # Lines starts at 1
        if ($CurrentLine -in $lineNumber)
        {
            Write-Verbose -Message "Removing line $CurrentLine : '$_'."
        }
        else
        {
            Write-Debug -Message "$($CurrentLine): '$_'."
            $_
        }
    } | Set-Content @setContentParams

    Write-Debug -Message "Content replaced into temp file: '$tempFile'."

    try
    {
        # Override the $Path with the content of $temFile. Use AsByteStream to abstract the encoding.
        Get-Content -Path $tempFile  -AsByteStream | Set-Content -Force -Path $Path -AsByteStream
        Write-Debug -Message "Updated '$Path'."
    }
    finally
    {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        Write-Debug -Message "Removed the temp file '$tempFile'."
    }
}
