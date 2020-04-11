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
    .PARAMETER ReturnRaw
        Returns the raw parent object (which includes metadata like the Offset field used for pagination) instead of just the objects of the specified type.

        Standard result example:
          {
          "id": 1000,
          "name": "Task 1",
          ...
          },
          ...
        ReturnRaw result example:
          {
            "data": [
              {
              "id": 1000,
              "name": "Task 1",
              ...
              },
              ...
            ],
            "next_page": {
              "offset": "yJ0eXAiOiJKV1QiLCJhbGciOiJIRzI1NiJ9",
              "path": "/tasks?project=1337&limit=5&offset=yJ0eXAiOiJKV1QiLCJhbGciOiJIRzI1NiJ9",
              "uri": "https://app.asana.com/api/1.0/tasks?project=1337&limit=5&offset=yJ0eXAiOiJKV1QiLCJhbGciOiJIRzI1NiJ9"
            }
          }
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
    [CmdletBinding(
        HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-Team.md',
        SupportsPaging = $false,
        PositionalBinding = $false)]

    param (
        [switch] $ReturnRaw,

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

    # If -ReturnRaw parameter is passed, return raw data instead of just objects
    if( [bool]($results.PSobject.Properties.name -match "data") -and -not $ReturnRaw ) {
        $results = $results.data
    }

    if ( '' -ne $Name ) {
        Write-Verbose "Filtering by name: $Name"
        $results = $results | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    }

    $results
}
