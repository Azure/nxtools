configuration CreateFileNxScript
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $FileContent
    )

    Import-DscResource -ModuleName 'nxtools'

    nxScript MyScript
    {
        GetScript = {
            $Reason = @{
                Code = "Script:Script:FileMissing"
                Phrase = "File does not exist"
            }

            if (Test-Path -Path $using:FilePath)
            {
                $text = $(Get-Content -Path $using:FilePath -Raw).Trim()
                if ($text -eq $using:FileContent)
                {
                    $Reason.Code = "Script:Script:Success"
                    $Reason.Phrase = "File exists with correct content"
                }
                else
                {
                    $Reason.Code = "Script:Script:ContentMissing"
                    $Reason.Phrase = "File exists but has incorrect content"
                }
            }

            return @{
                Reasons = @($Reason)
            }
        }
        SetScript = {
            $streamWriter = New-Object -TypeName 'System.IO.StreamWriter' -ArgumentList @($using:FilePath)
            $streamWriter.WriteLine($using:FileContent)
            $streamWriter.Close()
        }
        TestScript = {
            if (Test-Path -Path $using:FilePath)
            {
                $text = $(Get-Content -Path $using:FilePath -Raw).Trim()
                return $text -eq $using:FileContent
            }
            else
            {
                return $false
            }
        }
    }
}
