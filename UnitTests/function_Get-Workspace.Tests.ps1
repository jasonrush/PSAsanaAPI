Import-Module "$(Split-Path -parent $MyInvocation.MyCommand.Path)/../PSAsanaAPI/PSAsanaAPI.psm1" -Prefix "PSAAPI"

Describe 'Get-Workspace Tests' {
    Context 'Verify proper result counts' {
        It 'Returns one or more results' {
            (Get-PSAAPIWorkspace).count | Should -BeGreaterThan 0
        }
        It 'Returns a single result when "-Limit 1" is specified' {
            Get-PSAAPIWorkspace -Limit 1 | Should -HaveCount 1
        }
        It 'Returns no results when gibberish is specified' {
            Get-PSAAPIWorkspace -Name asdfasdfasdfasdfasdf | Should -HaveCount 0
        }
    }

    Context "Workspace has the correct properties" {
        $object = Get-PSAAPIWorkspace -Limit 1

        # Load an array with the properties we need to look for
        $properties = ('gid', 'name', 'resource_type')

        foreach ($property in $properties){
            It "Workspace object should have a property of $property" {
                [bool]($object.PSObject.Properties.Name -match $property) | Should -BeTrue
            }
        }

        It "Workspace object should have resource_type of 'workspace'" {
            $object.resource_type -eq 'workspace' | Should -BeTrue
        }

        It "Workspace object should not have a gibberish property" {
            [bool]($object.PSObject.Properties.Name -match 'qwertyqwertyqwerty') | Should -not -BeTrue
        }
    } # Context correct properties

    Context "Get-Workspace -ReturnRaw has the correct properties" {
        $object = Get-PSAAPIWorkspace -Limit 1 -ReturnRaw

        # Load an array with the properties we need to look for
        $properties = ('data', 'next_page')

        foreach ($property in $properties){
            It "Get-Workspace -ReturnRaw should have a property of $property" {
                [bool]($object.PSObject.Properties.Name -match $property) | Should -BeTrue
            }
        }

        It "Get-Workspace -ReturnRaw object should not have a gibberish property" {
            [bool]($object.PSObject.Properties.Name -match 'qwertyqwertyqwerty') | Should -not -BeTrue
        }

        # Get the subdata
        $object = $object.data[0]

        # Load an array with the properties we need to look for
        $properties = ('gid', 'name', 'resource_type')

        foreach ($property in $properties){
            It "(Get-Workspace -ReturnRaw).data[0] should have a property of $property" {
                [bool]($object.PSObject.Properties.Name -match $property) | Should -BeTrue
            }
        }

        It "(Get-Workspace -ReturnRaw).data[0] should not have a gibberish property" {
            [bool]($object.PSObject.Properties.Name -match 'qwertyqwertyqwerty') | Should -not -BeTrue
        }
    } # Context correct properties
}
