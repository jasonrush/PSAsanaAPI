# PSAsanaAPI
Another PowerShell module to interact with the Asana API. This is still *very* alpha, but I hope to make it a much more feature-rich and thorough implementation than any others I've found to date (as time allows, that is).

# Usage
The module is currently designed to authenticate by using a copy of your Asana Personal Access Token stored in an environment variable. Once the token is stored in the variable, all PSAsanaAPI functions should be usable.

Instructions on how to generate a Personal Access Token within Asana can be found here: https://asana.com/guide/help/api/api#gl-access-tokens
```
PS> $env:AsanaPersonalAccessToken = '1/97912xxxxxxxxxx:xxxxxxxxxx287ebe7fc6b5xxxxxxxxxx'
PS> Get-Workspace


gid              name                resource_type
---              ----                -------------
97913xxxxxxxxxx  JasonRush           workspace
110795xxxxxxxxxx JasonsPersonalStuff workspace


PS>
```