<#
    .DESCRIPTION
        This example shows how to create a file with [nxScript].

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxScript]@{
            GetScript = {
                # Implementation...
            }
            TestScript = {
                # Implementation...
            }
            SetScript = {
                # Implementation...
            }
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

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
            $Reason = [Reason]::new()
            $Reason.Code = "Script:Script:FileMissing"
            $Reason.Phrase = "File does not exist"

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
        SetScript = {
            $null = Set-Content -Path $using:FilePath -Value $using:FileContent
        }
    }
}
