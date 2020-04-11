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
    .PARAMETER Limit
        The number of objects to return. The value must be between 1 and 100 (defaults to 100).
    .PARAMETER Offset
        An offset to the next page returned by the API. A pagination request will return an offset token, which can be used as an input parameter to the next request. If an offset is not passed in, the API will return the first page of results.

        Note: You can only pass in an offset that was returned to you via a previously paginated request as this is a string generated internally by Asana and not a numeric offset.
    .PARAMETER OptFields
        Some requests return compact representations of objects, to conserve resources and complete the request more efficiently. Other times requests return more information than you may need. This option allows you to list the exact set of fields that the API should be sure to return for the objects. The field names should be provided as paths (described here: https://developers.asana.com/docs/input-output-options#paths ).

        NOTE: The gid of included objects will always be returned, regardless of the field options.
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
        Workspace object(s).
    .NOTES
        Version:        0.2
        Author:         Jason Rush
        Creation Date:  2020-04-10
        Purpose/Change: Added common parameters and ability to return raw results

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
    [CmdletBinding(
        HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-Organization.md',
        DefaultParameterSetName = 'ID',
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

        [Parameter(ParameterSetName = 'ID')]
        [ValidateNotNullOrEmpty()]
        [String] $ID,

        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    #region Endpoints
    $Endpoint = 'workspaces'

    if ( ('ID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $ID) ) {
        Write-Verbose "Filtering by ID: $ID"
        $Endpoint += "/$ID"
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

        if ( 'Name' -eq $PSCmdlet.ParameterSetName ) {
            Write-Verbose "Filtering by name: $Name"
            $results = $results | Where-Object { $_.name -eq $Name } | Select-Object -First 1
        }
    }


    $results
}
