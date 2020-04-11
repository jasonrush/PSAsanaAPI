function Get-Section {
    <#
    .SYNOPSIS
        Returns a specified section or sections in a workspace.
    .DESCRIPTION
        Returns a specified section or sections in a workspace.
    .PARAMETER SectionID
        The section ID of the section to return.
    .PARAMETER ProjectID
        The Project ID to return sections for.
    .PARAMETER Name
        The section name to return (within the project specified by ProjectID).
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
        Section object(s).
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
        Get-team -TeamID 12345
    .EXAMPLE
        Get-team -WorkspaceID 177987220357060
    #>
    [CmdletBinding(
        HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Get-Section.md',
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

        [Parameter(Mandatory = $true, ParameterSetName = 'SectionID')]
        [ValidateNotNullOrEmpty()]
        [String] $SectionID,

        [Parameter(Mandatory = $true, ParameterSetName = 'ProjectID')]
        [ValidateNotNullOrEmpty()]
        [String] $ProjectID,

        [Parameter(ParameterSetName = 'ProjectID')]
        [ValidateNotNullOrEmpty()]
        [String] $Name = ''
    )

    #region Endpoints
    if ( ('SectionID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $SectionID) ) {
        Write-Verbose "Filtering by Section ID: $SectionID"
        $Endpoint = "sections/$SectionID"
    }

    if ( ('ProjectID' -eq $PSCmdlet.ParameterSetName) -and ( '' -ne $ProjectID) ) {
        Write-Verbose "Filtering by Project ID: $ProjectID"
        $Endpoint = "projects/$ProjectID/sections"
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
