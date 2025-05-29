using module nxtools

Describe "nxUser resource for managing local users on a Linux node" {
    Context "When the user exists" {
        It ("Should accept all valid usernames") {
            Mock -ModuleName 'nxtools' -CommandName 'Get-Content' -ParameterFilter {
                return $Path -eq '/etc/passwd'
            } -MockWith {
                return @(
                    "testuser:x:1000:1000::/home/testuser:/bin/bash",
                    "Testuser:x:1001:1001::/home/Testuser:/bin/bash",
                    "Testuser123:x:1002:1002::/home/Testuser123:/bin/bash",
                    "Testuser:x:1001:1001::/home/Testuser:/bin/bash",
                    "Testuser123:x:1002:1002::/home/Testuser123:/bin/bash",
                    ".Testuser:x:1003:1003::/home/.Testuser:/bin/bash",
                    ".Test.user:x:1004:1004::/home/.Test.user:/bin/bash",
                    "_.Test.user:x:1005:1005::/home/_.Test.user:/bin/bash",
                    "@_.Test.user:x:1006:1006::/home/@_.Test.user:/bin/bash",
                    "@@_.Test.user:x:1007:1007::/home/@@_.Test.user:/bin/bash",
                    "@@_.Test.user`$:x:1008:1008::/home/@@_.Test.user`$:/bin/bash",
                    "_.@`$:x:1009:1009::/home/_.@`$:/bin/bash"
                )
            }

            Mock -ModuleName 'nxtools' -CommandName 'Get-Content' -ParameterFilter {
                return $Path -eq '/etc/shadow'
            } -MockWith {
                return @(
                    "testuser:!:19613:0:99999:7:::",
                    "Testuser:!:19613:0:99999:7:::",
                    "Testuser123:!:19613:0:99999:7:::",
                    ".Testuser:!:19613:0:99999:7:::",
                    ".Test.user:!:19613:0:99999:7:::",
                    "_.Test.user:!:19613:0:99999:7:::",
                    "@_.Test.user:!:19613:0:99999:7:::",
                    "@@_.Test.user:!:19613:0:99999:7:::",
                    "@@_.Test.user`$:!:19613:0:99999:7:::",
                    "_.@`$:!:19613:0:99999:7:::"
                )
            }

            $nxUser = [nxUser]::new()
            $nxUser.Ensure = "Present"
            $nxUser.UserName = "testuser"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "Testuser"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "Testuser123"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = ".Testuser"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = ".Test.user"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "_.Test.user"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "@_.Test.user"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "@@_.Test.user"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "@@_.Test.user$"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
            $nxUser.UserName = "_.@$"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
        }

        It ("Should handle some invalid values in /etc/shadow") {
            Mock -ModuleName 'nxtools' -CommandName 'Get-Content' -ParameterFilter {
                return $Path -eq '/etc/passwd'
            } -MockWith {
                return @(
                    "testuser1:x:1000:1000::/home/testuser:/bin/bash",
                    "testuser2:x:1000:1000::/home/testuser:/bin/bash",
                    "testuser3:x:1000:1000::/home/testuser:/bin/bash",
                    "testuser4:x:1000:1000::/home/testuser:/bin/bash",
                    "testuser5:x:1000:1000::/home/testuser:/bin/bash",
                    "testuser6:x:1000:1000::/home/testuser:/bin/bash"
                )
            }

            Mock -ModuleName 'nxtools' -CommandName 'Get-Content' -ParameterFilter {
                return $Path -eq '/etc/shadow'
            } -MockWith {
                # The '!' character is not allowed in fields where a number is expected
                return @(
                    "testuser1:abc123:!:0:99999:7:::",
                    "testuser2:!:19613:!:99999:7:::",
                    "testuser3:!:19613:0:!:7:::",
                    "testuser4:!:19613:0:99999:!:::",
                    "testuser5:!:19613:0:99999:7:!::",
                    "testuser6:!:19613:0:99999:7::!:"
                )
            }

            $nxUser = [nxUser]::new()
            $nxUser.Ensure = "Present"
            $nxUser.UserName = "testuser1"
            { $nxUser.Get() } | Should -Throw
            $nxUser.UserName = "testuser2"
            { $nxUser.Get() } | Should -Throw
            $nxUser.UserName = "testuser3"
            { $nxUser.Get() } | Should -Throw
            $nxUser.UserName = "testuser4"
            { $nxUser.Get() } | Should -Throw
            $nxUser.UserName = "testuser5"
            { $nxUser.Get() } | Should -Throw
            $nxUser.UserName = "testuser6"
            { $nxUser.Get() } | Should -Throw
        }

        It ("Should handle some empty values in /etc/shadow") {
            Mock -ModuleName 'nxtools' -CommandName 'Get-Content' -ParameterFilter {
                return $Path -eq '/etc/passwd'
            } -MockWith {
                return @(
                    "testuser:x:1000:1000::/home/testuser:/bin/bash"
                )
            }

            Mock -ModuleName 'nxtools' -CommandName 'Get-Content' -ParameterFilter {
                return $Path -eq '/etc/shadow'
            } -MockWith {
                return @(
                    "testuser:abc123:::::::"
                )
            }

            $nxUser = [nxUser]::new()
            $nxUser.Ensure = "Present"
            $nxUser.UserName = "testuser"
            $result = $nxUser.Get()
            $result.Reasons.Count | Should -Be 0
        }
    }
}
