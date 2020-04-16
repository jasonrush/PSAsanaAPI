Write-Output 'Starting Script Analyzer (standard scan)'
if( $null -eq (Get-Module psscriptanalyzer -ListAvailable) ){
    Write-Error -Message "PSScriptAnalyzer not found. Install PSScriptAnalyzer with 'install-module psscriptanalyzer' or for non-admins 'install-module psscriptanalyzer -scope CurrentUser'"
    exit 1
}
try {
    $results = Invoke-ScriptAnalyzer -Path . -Recurse -ExcludeRule 'PSAlignAssignmentStatement','PSUseConsistentWhitespace'
    $results
}
catch {
    Write-Error -Message $_
    exit 1
}
if ($results.Count -gt 0) {
    Write-Error -Message "Analysis of your code threw   $($results.Count) warnings or errors. Please go back and check your code."
    exit 1
}
Write-Output "`tNo warnings or errors found."


Write-Output 'Starting Script Analyzer (code formatting)'
if( $null -eq (Get-Module psscriptanalyzer -ListAvailable) ){
    Write-Error -Message "PSScriptAnalyzer not found. Install PSScriptAnalyzer with 'install-module psscriptanalyzer' or for non-admins 'install-module psscriptanalyzer -scope CurrentUser'"
    exit 1
}
try {
    $results = Invoke-ScriptAnalyzer -Path . -Recurse -Settings CodeFormatting -ExcludeRule 'PSAlignAssignmentStatement','PSUseConsistentWhitespace'
    $results
}
catch {
    Write-Error -Message $_
    exit 1
}
if ($results.Count -gt 0) {
    Write-Error -Message "Analysis of your code threw $($results.Count) code formatting warnings or errors. Please go back and check your code."
    exit 1
}
Write-Output "`tNo warnings or errors found."


Write-Output 'Starting Pester tests'
$Results = Invoke-Pester -Show Failed, describe -PassThru ./UnitTests/*

if ( $Results.FailedCount -gt 0 ) {
    Write-Error -Message "Pester threw $($Results.FailedCount) failure(s). Please go back and check your code."
    exit 1
}

