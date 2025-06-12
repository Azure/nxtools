using module nxtools

$script:mockPath = "/my/mock/file.txt" # Mock path for testing

Describe "nxFile resource for managing a file or a folder" {
    Context "When the file already exists" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                $mockPathFound = $false
                foreach ($param in $Parameters)
                {
                    if ($param -match $mockPath -or $param -match $mockPath.Replace('/', '\\'))
                    {
                        $mockPathFound = $true
                    }
                }
                return $Executable -eq "ls" -and $mockPathFound
            } -MockWith { "-rw-r--r-- 1 root root 0 2023-09-11 17:05:28.084507110 +0000 $mockPath" }
        }

        It "Should delete the file on remediation if we are expecting the file to be absent" {
            $nxFile = [nxFile]::new()
            $nxFile.Ensure = "Absent"
            $nxFile.DestinationPath = $mockPath
            $nxFile.Type = "File"
            $nxFile.Mode = "0777"
            $nxFile.Owner = "root"
            $nxFile.Group = "root"

            # Fail if Remove-Item is not called on remediation
            Mock -ModuleName 'nxtools' -CommandName 'Remove-Item' -ParameterFilter {
                return $Path -match $mockPath -or $Path -match $mockPath.Replace('/', '\\')
            } -Verifiable
            $nxFile.Set()
            Should -InvokeVerifiable
        }
    }

    Context "When the file already exists but has empty permissions for the other category" {
        BeforeAll {
            Mock -ModuleName 'nxtools' -CommandName 'Invoke-NativeCommand' -ParameterFilter {
                $mockPathFound = $false
                foreach ($param in $Parameters)
                {
                    if ($param -match $mockPath -or $param -match $mockPath.Replace('/', '\\'))
                    {
                        $mockPathFound = $true
                    }
                }
                return $Executable -eq "ls" -and $mockPathFound
            } -MockWith { "-rw-r----- 1 root root 0 2023-09-11 17:05:28.084507110 +0000 $mockPath" }
        }

        It "Should be compliant if we are only expecting the file to exist" {
            $nxFile = [nxFile]::new()
            $nxFile.Ensure = "Present"
            $nxFile.DestinationPath = $mockPath
            $nxFile.Type = "File"
            $result = $nxFile.Get()
            $result.Reasons.Count | Should -Be 0
        }
    }
}
