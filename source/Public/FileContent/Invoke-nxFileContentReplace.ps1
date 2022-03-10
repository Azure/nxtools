function Invoke-nxFileContentReplace
{
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter(Position = 1, Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Position = 2, Mandatory = $true)]
        [string]
        $SearchPattern,

        [Parameter(Position = 3)]
        [string]
        $ReplaceWith,

        [Parameter()]
        [switch]
        $CaseSensitive,

        [Parameter()]
        [switch]
        $Multiline,

        [Parameter()]
        [String]
        $Encoding = 'UTF8'
    )


    # Read through the file, inserting the edits and adding all lines to them file.
    $getContentsParams = @{
        Path     = $Path
        Encoding = $Encoding
    }

    $tempFile = [System.IO.Path]::GetTempFileName()
    $setContentParams = $getContentsParams.Clone()
    $setContentParams['Path'] = $tempFile
    [int]$lineNumber = -1 #start at -1 so that as soon as you increment it goes to 0 (the first line).

    if ($Multiline.IsPresent)
    {
        $getContentsParams['Raw'] = $true
    }

    Get-Content @getContentsParams | ForEach-Object -Process { # Stream
        $lineNumber++
        $matchExpr = if ($CaseSensitive.IsPresent)
        {
            {$_ -cmatch $SearchPattern}
        }
        else
        {
            {$_ -imatch $SearchPattern}
        }

        if (&$matchExpr)
        {
            Write-Verbose -Message "The line $lineNumber matches '$SearchPattern'. running '$_' -replace '$SearchPattern','$ReplaceWith'."
            if ($CaseSensitive.IsPresent)
            {
                $_ -creplace $SearchPattern,$ReplaceWith
            }
            else
            {
                $_ -ireplace $SearchPattern,$ReplaceWith
            }
        }
        else
        {
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
