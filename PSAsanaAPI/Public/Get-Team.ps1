function Get-Team {
    <#
    .SYNOPSIS
        Returns all teams or a specified team in a workspace.
    .DESCRIPTION
        Returns all teams or a specified team in a workspace.
    .PARAMETER teamID
        The team ID of the team to return.
    .PARAMETER WorkspaceID
        The Workspace ID to return teams for.
    .PARAMETER Name
        The team name to return (within the workspace specified by WorkspaceID).
    .OUTPUTS
        Team object(s).
    .NOTES
        Version:        0.1
        Author:         Jason Rush
        Creation Date:  2020-04-10
        Purpose/Change: Initial script development
    .EXAMPLE
        Get-team -TeamID 12345
    .EXAMPLE
        Get-team -WorkspaceID 177987220357060
    #>
    param (
        [CmdletBinding(
            HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-Team.md',
            SupportsPaging = $false,
            PositionalBinding = $false)]

        [Parameter(Mandatory = $true, ParameterSetName = 'TeamID')]
        [ValidateNotNullOrEmpty()]
        [String] $TeamID,

        [Parameter(Mandatory = $true, ParameterSetName = 'WorkspaceID')]
        [ValidateNotNullOrEmpty()]
        [String] $WorkspaceID,

        [Parameter(ParameterSetName = 'WorkspaceID')]
        [ValidateNotNullOrEmpty()]
        [String] $Name = ''
    )

    if ( ('TeamID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $TeamID) ) {
        Write-Verbose "Filtering by Team ID: $ID"
        $Endpoint = "teams/$TeamID"
    }

    if ( ('WorkspaceID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $WorkspaceID) ) {
        Write-Verbose "Filtering by Workspace ID: $ID"
        $Endpoint = "organizations/$WorkspaceID/teams"
    }

    $results = Invoke-APIRestMethod -Endpoint $Endpoint

    if ( '' -ne $Name ) {
        Write-Verbose "Filtering by name: $Name"
        $results = $results | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    }

    $results
}
