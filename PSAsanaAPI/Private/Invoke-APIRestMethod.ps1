function Invoke-APIRestMethod {
    <#
    .SYNOPSIS
        Makes a REST call to the Asana API
    .DESCRIPTION
        Connects to the Asana API via REST and returns results as object(s).
        This function is used internally by most other calls to the Asana API through this module.
    .PARAMETER Method
        'GET', 'POST', 'PUT', or 'DELETE'. Defaults to 'GET'.
    .PARAMETER Endpoint
        The API endpoint to access (after the API base URL, ie. after 'https://app.asana.com/api/1.0/').
    .PARAMETER Body
        HTTP request body, if required.
    .OUTPUTS
        PowerShell objects based on the JSON data returned by the API call.
    .NOTES
        Version:        1.0
        Author:         Jason Rush
        Creation Date:  2020-04-10
        Purpose/Change: Initial script development

    .EXAMPLE
        Invoke-APIRestMethod -Endpoint 'organizations'
    #>
    param (
        [CmdletBinding(
            HelpURI = 'https://github.com/jasonrush/PSAsanaAPI/blob/master/Docs/Invoke-APIRestMethod.md',
            SupportsPaging = $false,
            PositionalBinding = $true)]

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Endpoint,

        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
        [String] $Method = "GET",

        [Parameter()]
        $Body,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $personalAccessToken = '',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String] $BaseURI = ''
        #>
    )

    # If no Personal Access Token specified, try pulling from Environment variable.
    if ( ('' -eq $personalAccessToken) -and ( Test-Path env:AsanaPersonalAccessToken) ) {
        Write-Verbose "Importing Personal Access Token from environmental variable."
        $personalAccessToken = $env:AsanaPersonalAccessToken
    }

    # If BaseURI was not specified, try pulling from Environment variable.
    if ( ('' -eq $BaseURI) -and ( Test-Path env:AsanaApiBaseURI) ) {
        Write-Verbose "Importing Base URI from environmental variable."
        $BaseURI = $env:AsanaApiBaseURI
    }

    # If we still haven't figured out a better base URI, use the default.
    if ( ('' -eq $BaseURI) ) {
        $BaseURI = 'https://app.asana.com/api/1.0'
    }

    # Create headers array to specify Asana Personal Access Token key
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    if ( $null -eq $personalAccessToken ) {
        # ERROR
    }

    Write-Verbose "Method: $Method"

    $FullURI = "$BaseURI/$Endpoint"
    Write-Verbose "Path: $FullURI"

    Write-Verbose "Personal Access Token: $personalAccessToken"
    $headers.Add( "Authorization", "Bearer $personalAccessToken" )

    Write-Verbose "Headers:"
    foreach ( $key in $headers.Keys ) {
        Write-Verbose "`t`t$($key): $($headers[$key])"
    }

    $response = Invoke-RestMethod $FullURI -Method $Method -Headers $Headers -Body $Body -ErrorAction Stop

    if( [bool]($response.PSobject.Properties.name -match "data") ) {
        $response.data
    }else{
        $response
    }
}
