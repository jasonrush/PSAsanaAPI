function Get-User {
    <#
    .SYNOPSIS
        Returns all users, a specified user, or users in a task/team/workspace.
    .DESCRIPTION
        Returns all users, a specified user, or users in a task/team/workspace.
    .PARAMETER UserID
        The User ID of the user to return.
    .PARAMETER TeamID
        The Team ID to return users for.
    .PARAMETER WorkspaceID
        The Workspace ID to return users for.
    .PARAMETER Name
        The name of the user to return.
    .OUTPUTS
        User object(s).
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
        HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-User.md',
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

        [Parameter(Mandatory = $false, ParameterSetName = 'UserID')]
        [ValidateNotNullOrEmpty()]
        [String] $UserID,

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
    $Endpoint = "users"

    if ( ('UserID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $UserID) ) {
        Write-Verbose "Filtering by User ID: $UserID"
        $Endpoint = "users/$UserID"
    }

    if ( ('TeamID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $TeamID) ) {
        Write-Verbose "Filtering by Team ID: $TeamID"
        $Endpoint = "teams/$TeamID/users"
    }

    if ( ('WorkspaceID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $WorkspaceID) ) {
        Write-Verbose "Filtering by Workspace ID: $WorkspaceID"
        $Endpoint = "workspaces/$WorkspaceID/users"
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
$body | fl -prop * | Out-String | Write-Verbose
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
