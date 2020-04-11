function Get-Project {
    <#
    .SYNOPSIS
        Returns all Projects, a specified Project, or a specified Project in a task/team/workspace.
    .DESCRIPTION
        Returns all Projects, a specified Project, or a specified Project in a task/team/workspace.
    .PARAMETER ProjectID
        The Project ID of the Project to return.
    .PARAMETER TaskID
        The Task ID to return Projects for.
    .PARAMETER TeamID
        The Team ID to return Projects for.
    .PARAMETER WorkspaceID
        The Workspace ID to return Projects for.
    .PARAMETER Name
        The Project name to return.
    .OUTPUTS
        Project object(s).
    .NOTES
        Version:        0.1
        Author:         Jason Rush
        Creation Date:  2020-04-10
        Purpose/Change: Initial script development
    .EXAMPLE
        Get-Project -ProjectID 12345
    .EXAMPLE
        Get-Project -WorkspaceID 177987220357060
    #>
    [CmdletBinding(
        DefaultParametersetname="ProjectID",
        HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-Project.md',
        SupportsPaging = $false,
        PositionalBinding = $false)]

    param (
        #region Common Parameters
        [ValidateRange(0, 100)]
        [int] $Limit = 0,

        [String] $Offset = '',

        [string[]] $OptFields,

        [switch] $ReturnRaw,
        #endregion Common Parameters

        [Parameter(Mandatory = $false, ParameterSetName = 'ProjectID')]
        [ValidateNotNullOrEmpty()]
        [String] $ProjectID,

        [Parameter(Mandatory = $false, ParameterSetName = 'TaskID')]
        [ValidateNotNullOrEmpty()]
        [String] $TaskID,

        [Parameter(Mandatory = $false, ParameterSetName = 'TeamID')]
        [ValidateNotNullOrEmpty()]
        [String] $TeamID,

        [Parameter(Mandatory = $false, ParameterSetName = 'WorkspaceID')]
        [ValidateNotNullOrEmpty()]
        [String] $WorkspaceID,

#        [Parameter]
#        [ValidateNotNullOrEmpty()]
        [String] $Name = ''
    )

    #region Endpoints
    $Endpoint = "projects"

    if ( ('ProjectID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $ProjectID) ) {
        Write-Verbose "Filtering by Project ID: $ID"
        $Endpoint = "projects/$ProjectID"
    }

    if ( ('TaskID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $TaskID) ) {
        Write-Verbose "Filtering by Task ID: $ID"
        $Endpoint = "tasks/$TaskID/projects"
    }

    if ( ('TeamID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $TeamID) ) {
        Write-Verbose "Filtering by Team ID: $ID"
        $Endpoint = "teams/$TeamID/projects"
    }

    if ( ('WorkspaceID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $WorkspaceID) ) {
        Write-Verbose "Filtering by Workspace ID: $ID"
        $Endpoint = "workspaces/$WorkspaceID/projects"
    }
    #endregion Endpoints

    #region Common Parameters processing
    $body = @{}
    if( 0 -ne $Limit ){
        $body['limit'] = $Limit
    }
    if( '' -ne $Offset ){
        $body['offset'] = $Offset
    }
    if( $null -ne $OptFields ){
        $body['fields'] = $OptFields
    }
    #endregion Common Parameters processing

    $results = Invoke-APIRestMethod -Endpoint $Endpoint -Body $body

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
