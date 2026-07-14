Describe "Assert-nxValidPackageName" {
    Context "When the package name is valid" {
        It "Should not throw for a simple package name: <_>" -ForEach @(
            'openssl'
            'libssl3'
            'lib32z1'
            'gcc-12'
            'python3.11'
            'g++'
            'libssl:amd64'
            'ca-certificates'
        ) {
            InModuleScope -ModuleName 'nxtools' -Parameters @{ PackageName = $_ } -ScriptBlock {
                param ($PackageName)
                { Assert-nxValidPackageName -Name $PackageName } | Should -Not -Throw
            }
        }

        It "Should not throw for a collection of valid names" {
            InModuleScope -ModuleName 'nxtools' -ScriptBlock {
                { Assert-nxValidPackageName -Name @('openssl', 'libssl3', 'gcc-12') } | Should -Not -Throw
            }
        }

        It "Should not throw for an empty collection" {
            InModuleScope -ModuleName 'nxtools' -ScriptBlock {
                { Assert-nxValidPackageName -Name @() } | Should -Not -Throw
            }
        }
    }

    Context "When the package name is invalid it must be rejected" {
        It "Should throw for a name containing shell/PowerShell metacharacters: <_>" -ForEach @(
            'openssl; touch /tmp/x'
            '$(touch /tmp/x)'
            'openssl && touch /tmp/x'
            'openssl | touch /tmp/x'
            "openssl`ntouch /tmp/x"
            'openssl `touch /tmp/x`'
            "openssl'; touch /tmp/x #"
            'openssl" ; touch /tmp/x'
            '-W'
            '../../etc/passwd'
            'open ssl'
            ''
            '   '
        ) {
            InModuleScope -ModuleName 'nxtools' -Parameters @{ PackageName = $_ } -ScriptBlock {
                param ($PackageName)
                { Assert-nxValidPackageName -Name $PackageName } | Should -Throw
            }
        }

        It "Should throw when any name in a collection is invalid" {
            InModuleScope -ModuleName 'nxtools' -ScriptBlock {
                { Assert-nxValidPackageName -Name @('openssl', 'openssl; touch /tmp/x') } | Should -Throw
            }
        }
    }
}
