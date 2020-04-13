Import-Module "$(Split-Path -parent $MyInvocation.MyCommand.Path)/../PSAsanaAPI/PSAsanaAPI.psm1" -Prefix "PSAAPI"

Describe 'Get-Team Tests' {
    $workspaceID = (Get-PSAAPIWorkspace -Limit 1).gid
    Context 'Verify proper result counts' {
        It 'Returns one or more results' {
            (Get-PSAAPITeam -WorkspaceID $workspaceID | Measure-Object).Count | Should -BeGreaterThan 0
        }
        It 'Returns a single result when "-Limit 1" is specified' {
            Get-PSAAPITeam -WorkspaceID $workspaceID | Should -HaveCount 1
        }
        It 'Returns no results when gibberish is specified' {
            Get-PSAAPITeam -WorkspaceID $workspaceID -Name asdfasdfasdfasdfasdf | Should -HaveCount 0
        }
    }

    Context "Team has the correct properties" {
        $object = Get-PSAAPITeam -WorkspaceID $workspaceID -Limit 1

        # Load an array with the properties we need to look for
        $properties = ('gid', 'name', 'resource_type')

        foreach ($property in $properties){
            It "Team object should have a property of $property" {
                [bool]($object.PSObject.Properties.Name -match $property) | Should -BeTrue
            }
        }

        It "Team object should have resource_type of 'team'" {
            $object.resource_type -eq 'team' | Should -BeTrue
        }

        It "Team object should not have a gibberish property" {
            [bool]($object.PSObject.Properties.Name -match 'qwertyqwertyqwerty') | Should -not -BeTrue
        }
    } # Context correct properties

    Context "Get-Team -ReturnRaw has the correct properties" {
        $object = Get-PSAAPITeam -WorkspaceID $workspaceID -Limit 1 -ReturnRaw

        # Load an array with the properties we need to look for
        $properties = ('data', 'next_page')

        foreach ($property in $properties){
            It "Get-Team -ReturnRaw should have a property of $property" {
                [bool]($object.PSObject.Properties.Name -match $property) | Should -BeTrue
            }
        }

        It "Get-Team -ReturnRaw object should not have a gibberish property" {
            [bool]($object.PSObject.Properties.Name -match 'qwertyqwertyqwerty') | Should -not -BeTrue
        }

        # Get the subdata
        $object = $object.data[0]

        # Load an array with the properties we need to look for
        $properties = ('gid', 'name', 'resource_type')

        foreach ($property in $properties){
            It "(Get-Team -ReturnRaw).data[0] should have a property of $property" {
                [bool]($object.PSObject.Properties.Name -match $property) | Should -BeTrue
            }
        }

        It "(Get-Team -ReturnRaw).data[0] should not have a gibberish property" {
            [bool]($object.PSObject.Properties.Name -match 'qwertyqwertyqwerty') | Should -not -BeTrue
        }
    } # Context correct properties
}
