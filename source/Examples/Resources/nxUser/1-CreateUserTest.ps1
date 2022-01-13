<#
    .DESCRIPTION
        This example shows how to create a local User with [nxUser].

    .NOTES
        Because the resources are class based, you can also test the resource this way:

        using module nxtools # assuming it's available via $Env:PSModulePath.

        $rsrc = [nxUser]@{
            # the group must be present and have root as only member
            Ensure =  'Present'
            UserName =  'test'
            FullName = 'test user'
            HomeDirectory = '/home/test'
            Description = 'Some description'
        }

        $rsrc.Get().Reasons
        $rsrc.Set()
        $rsrc.Get()
#>

configuration CreateUserTest {
    Import-DscResource -ModuleName 'nxtools'

    node localhost {
        nxUser CreateUserTest {
            # the group must be present and have root as only member
            Ensure =  'Present'
            UserName =  'test'
            FullName = 'test user'
            HomeDirectory = '/home/test'
            Description = 'Some description'
        }
    }
}
