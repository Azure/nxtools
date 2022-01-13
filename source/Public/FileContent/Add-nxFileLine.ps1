function Add-nxFileLine
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
        [string]
        $Line,

        [Parameter()]
        [nxFileLineAddMode]
        $AddLineMode = [nxFileLineAddMode]::Append,

        [Parameter()]
        [regex]
        $LinePattern,

        [Parameter()]
        [switch]
        $CaseSensitive,

        [Parameter()]
        [String]
        $Encoding = 'UTF8'
    )

    Write-Debug -Message "Adding Line to file '$Path'."
    if ($AddLineMode -eq [nxFileLineAddMode]::Append)
    {
        Add-Content -Path $Path -Value $Line -ErrorAction Stop -Encoding $Encoding
        return
    }

    # Else, Insert the line either before or after the first line matching the pattern
    $firstMatch = Select-String -Path $Path -Pattern $LinePattern -CaseSensitive:$CaseSensitive.IsPresent

    if ($null -eq $firstMatch)
    {
        Write-Debug -Message "Could not find pattern '$LinePattern' for insert mode ''."
        Write-Debug -Message "The line '$Line' was not added. Aborting."
        return
    }
    else
    {
        Write-Debug -Message "LinePattern '$LinePattern' was found line $($firstMatch.LineNumber)."
    }

    $indexToInsertLineAt = if ($AddLineMode -eq [nxFileLineAddMode]::BeforeLinePatternMatch)
    {
        $firstMatch.LineNumber - 1
    }
    elseif ($AddLineMode -eq [nxFileLineAddMode]::AfterLinePatternMatch)
    {
        $firstMatch.LineNumber
    }

    Write-Debug -Message "Will insert the line in line $indexToInsertLineAt."

    # Read through the file, inserting the edits and adding all lines to them file.
    $getContentsParams = @{
        Path     = $Path
        Encoding = $Encoding
    }

    $tempFile = [System.IO.Path]::GetTempFileName()
    $setContentParams = $getContentsParams.Clone()
    $setContentParams['Path'] = $tempFile
    [int]$lineNumber = -1 #start at -1 so that as soon as you increment it goes to 0 (the first line).

    Get-Content @getContentsParams | ForEach-Object -Process { # Stream
        $lineNumber++
        if ($lineNumber -eq $indexToInsertLineAt)
        {
            Write-Verbose -Message "Inserting at line $lineNumber."
            $Line # Insert the line at this index
            $_    # Continue with the file content
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
