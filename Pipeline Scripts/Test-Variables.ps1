[CmdletBinding()]
Param()

# Change to script directory
$ScriptPath = $MyInvocation.MyCommand.Path
$CurrentWorkingDirectory = Split-Path $ScriptPath
Set-Location $CurrentWorkingDirectory

Write-Host "::group::environment variables"
Get-ChildItem ENV: | Out-String | Write-Host 
Write-Host "::endgroup::"

Write-Host "::group::Validating parameter values"

$tenantid = $ENV:TENANTID
if($tenantid -notmatch "^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})$") {
    Write-Host "::error::Variable 'tenantid' is not a valid guid: $tenantid"
    exit 1
} else {
    Write-Host "Variable 'tenantid' is valid: $tenantid"
}

$clientid = $ENV:CLIENTID
if($clientid -notmatch "^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})$") {
    Write-Host "::error::Variable 'clientid' is not a valid guid: $clientid"
    exit 1
} else {
    Write-Host "Variable 'clientid' is valid: $clientid"
}

$clientsecret = $ENV:CLIENTSECRET
if([String]::IsNullOrEmpty($clientsecret)) {
    Write-Host "::error::Variable 'clientsecret' is not present"
    exit 1
} else {
    Write-Host "Variable 'clientsecret' is present"
}

Write-Host "::endgroup::"


Write-Host "::group::Validating username and password by getting an access token from Azure AD"
$uri = "https://login.microsoftonline.com/{0}/oauth2/v2.0/token" -f $tenantid
$body = "client_id={0}&scope=https://graph.microsoft.com/.default&grant_type=client_credentials&client_secret={1}" -f $clientid, [System.Net.WebUtility]::UrlEncode($clientsecret)
try {
    Invoke-RestMethod $uri -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction SilentlyContinue -Method Post | Out-Null
} catch {
    Write-Host "::error::Unable to validate clientid, clientsecret and tenantid by getting an access token: $($_)"
    exit 1
}
Write-Host "Successfully got access token"
Write-Host "::endgroup::"