function Get-Workspace {
    <#
    .SYNOPSIS
        Returns all workspaces or the specified workspace.
    .DESCRIPTION
        Returns all workspaces the specified personal access token has access to.
        If a workspace GID is specified, will instead return the individual workspace.
    .PARAMETER ID
        The workspace GID of the workspace to return.
    .PARAMETER Name
        The workspace GID of the workspace to return.
    .OUTPUTS
        Workspace object(s).
    .NOTES
        Version:        0.1
        Author:         Jason Rush
        Creation Date:  2020-04-10
        Purpose/Change: Initial script development
    .EXAMPLE
        Get-Workspace
    .EXAMPLE
        Get-Workspace -ID 177987220357060
    .EXAMPLE
        Get-Workspace -Name "Personal Projects"
    #>
    param (
        [CmdletBinding(
            HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-Organization.md',
            DefaultParameterSetName = 'ID',
            SupportsPaging = $false,
            PositionalBinding = $false)]

        [Parameter(ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [String] $ID,

        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    $Endpoint = 'workspaces'

    if ( ('ID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $ID) ) {
        Write-Verbose "Filtering by ID: $ID"
        $Endpoint += "/$ID"
    }

    $results = Invoke-APIRestMethod -Endpoint $Endpoint

    if ( 'Name' -eq $PSCmdlet.ParameterSetName ) {
        Write-Verbose "Filtering by name: $Name"
        $results = $results | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    }

    $results
}
