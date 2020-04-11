function New-Task {
    <#
    .SYNOPSIS
        Creates a task within Asana.
    .DESCRIPTION
        Creates a tack within Azana.

        NOTE: Every task is required to be created in a specific workspace, and this workspace cannot be changed once set. The workspace need not be set explicitly if you specify projects or a parent task instead.
    .PARAMETER Name
        Name of the task. This is generally a short sentence fragment that fits on a line in the UI for maximum readability. However, it can be longer.
    .PARAMETER ApprovalStatus
        (Conditional) Reflects the approval status of this task. This field is kept in sync with completed, meaning pending translates to false while approved, rejected, and changes_requested translate to true. If you set completed to true, this field will be set to approved.
    .PARAMETER AssigneeStatus
        Scheduling status of this task for the user it is assigned to. This field can only be set if the assignee is non-null.
    .PARAMETER Completed
        True if the task is currently marked complete, false if not.
    .PARAMETER CompletedBy
        The name of the user who completed the task.
    .PARAMETER DueAt
        Date and time on which this task is due. This takes a UTC timestamp and should not be used together with due_on.
    .PARAMETER DueOn
        Date on which this task is due. This takes a date (based on UTC timestamp of datetime object) and should not be used together with due_at.
    .PARAMETER Notes
        More detailed, free-form textual information associated with the task.
    .PARAMETER HtmlNotes
        The notes of the text with formatting as HTML.
    .PARAMETER ResourceSubtype
        The subtype of this resource. Different subtypes retain many of the same fields and behavior, but may render differently in Asana or represent resources with different semantic meaning.
    .PARAMETER StartOn
        The day on which work begins for the task. This takes a date (based on UTC timestamp of datetime object).
    .PARAMETER Assignee
        GID of a user.
    .PARAMETER CustomFields
        An object/hashtable where each key is a Custom Field gid and each value is an enum gid, string, or number.
        Eg. -CustomFields @{ "5678904321" = "On Hold"; "4578152156"= "Not Started" }
    .PARAMETER Followers
        An array of strings identifying users. These can either be the string "me", an email, or the GID of a user.
    .PARAMETER ParentID
        GID of a task.
    .PARAMETER ProjectsID
        Array of project GIDs.
    .PARAMETER Membership
        An array of hashtables which specifies a Project ID and Section ID where the task should be a member.
        Eg. -Membership @{ "project" = 123456; "section"= 456789 }, @{...}, ...
    .PARAMETER Tags
        Array of tag GIDs.
    .PARAMETER WorkspaceID
        GID of a workspace.
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
        Organization object(s).
    .NOTES
        Version:        0.1
        Author:         Jason Rush
        Creation Date:  2020-04-10
        Purpose/Change: Initial script development
    .EXAMPLE
        Get-Organization
    .EXAMPLE
        Get-Organization -ID "537758"
    .EXAMPLE
        Get-Organization -Name "DevNet Sandbox"
    #>
    param (
        [CmdletBinding(
        HelpURI='https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/New-Task.md',
        SupportsPaging=$false,
        PositionalBinding=$false)]

        #region Common Parameters
        [string[]] $OptFields,

        [switch] $ReturnRaw,
        #endregion Common Parameters

        [string] $Name,

        [ValidateSet('pending', 'approved', 'rejected', 'changes_requested')]
        [string] $ApprovalStatus,

        [string] $AssigneeStatus,

        [switch] $Completed,

        [string] $CompletedBy,

        [datetime] $DueAt,

        [datetime] $DueOn,

        [string] $HtmlNotes,

        [string] $Notes,

        [string] $ResourceSubtype,

        [datetime] $StartOn,

        [string] $Assignee,

        $CustomFields,

        [string[]] $Followers,

        [string] $ParentID,

        [string[]] $ProjectsID,

        [hashtable[]] $Membership,

        [string[]] $Tags,

        [string] $WorkspaceID
    )

    #region Endpoints
    $Endpoint = 'tasks'
    #endregion Endpoints

    #region Common Parameters processing
    $body = @{}
    if( $null -ne $OptFields ){
        $body['fields'] = $OptFields
    }
    #endregion Common Parameters processing

    #region Additional parameter processing
    $bodyData = @{}

    if( '' -ne $Name ){
        $bodyData['name'] = $Name
    }

    if( '' -ne $ApprovalStatus ){
        $bodyData['approval_status'] = $ApprovalStatus
    }

    if( '' -ne $AssigneeStatus ){
        $bodyData['assignee_status'] = $AssigneeStatus
    }

    if( $Completed ){
        $bodyData['completed'] = $Completed
    }

    if( '' -ne $CompletedBy ){
        $bodyData['completed_by'] = @{
            'name' = $CompletedBy
        }
    }

    if( $DueAt ){
        $bodyData['due_at'] = $DueAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    }

    if( $DueOn ){
        $bodyData['due_on'] = $DueOn.ToUniversalTime().ToString("yyyy-MM-dd")
    }

    if( '' -ne $HtmlNotes ){
        $bodyData['html_notes'] = $HtmlNotes
    }

    if( '' -ne $Notes ){
        $bodyData['notes'] = $Notes
    }

    if( '' -ne $ResourceSubtype ){
        $bodyData['resource_subtype'] = $ResourceSubtype
    }

    if( $StartOn ){
        $bodyData['start_on'] = $StartOn.ToUniversalTime().ToString("yyyy-MM-dd")
    }

    if( '' -ne $Assignee ){
        $bodyData['assignee'] = $Assignee
    }

    if( $CustomFields ){
        $bodyData['custom_fields'] = $CustomFields
    }

    if( $Followers ){
        $bodyData['followers'] = $Followers
    }

    if( '' -ne $ParentID ){
        $bodyData['parent'] = $ParentID
    }else{
        $bodyData['parent'] = $null
    }

    if( $ProjectsID.Count ){
        $bodyData['projects'] = $ProjectsID
        if( $Membership.Count ){
            $bodyData['memberships'] = $Membership
        }
    }

    if( $Tags ){
        $bodyData['tags'] = $Tags
    }

    if( '' -ne $WorkspaceID ){
        $bodyData['workspace'] = $WorkspaceID
    }

    $body['data'] = $bodyData
    #endregion Additional parameter processing

    $body = $body | convertto-json -depth 10
    $results = Invoke-APIRestMethod -Endpoint $Endpoint -Body $body -Method POST

    # If -ReturnRaw parameter is passed, return raw data instead of just objects
    if( [bool]($results.PSobject.Properties.name -match "data") -and -not $ReturnRaw ) {
        $results = $results.data
    }

    if ( 'Name' -eq $PSCmdlet.ParameterSetName ) {
        Write-Verbose "Filtering by name: $Name"
        $results = $results | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    }

    $results
}
