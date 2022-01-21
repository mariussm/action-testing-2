[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=1)]
    [String] $Folder
)

Process {
    Set-Location $Folder

    #
    # PowerShell script analyzer
    # 

    Write-Host "::group::PowerShell script analyzer"
    $AnalyzeResult = Get-ChildItem -Recurse |
        Where-Object extension -in ".psm1",".ps1" |
        Invoke-ScriptAnalyzer -ExcludeRule PSAvoidUsingWriteHost, PSAvoidUsingPlainTextForPassword, PSAvoidUsingUsernameAndPasswordParams, PSAvoidUsingConvertToSecureStringWithPlainText, PSAvoidTrailingWhitespace, PSUseApprovedVerbs, PSUseShouldProcessForStateChangingFunctions, PSAvoidGlobalVars, PSReviewUnusedParameter, PSUseSingularNouns

    $ErrorCounter = 0
    $AnalyzeResult |
        ForEach-Object {
            if($_.Severity -eq "Warning") {
                Write-Host "::warning file=$($_.ScriptPath),line=$($_.Line)::$($_.RuleName) - $($_.Message)"
            } else {
                Write-Host "::error file=$($_.ScriptPath),line=$($_.Line)::$($_.RuleName) - $($_.Message)"
                $ErrorCounter += 1
            }
        }

    if($ErrorCounter -gt 0) {
        exit 1
    }
    
    Write-Host "::endgroup::"
}