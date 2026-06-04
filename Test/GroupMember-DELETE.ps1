# Usage: ./GroupMember-DELETE.ps1 -GroupId <guid> -UserPrincipalName <upn>
# Env:   FUNCTION_URL (default: http://localhost:7071)
#        FUNCTION_KEY (required for deployed function)
param(
    [Parameter(Mandatory)][string]$GroupId,
    [Parameter(Mandatory)][string]$UserPrincipalName
)

$BaseUrl  = $env:FUNCTION_URL ?? "<FUNCTION_URL>"
$Key      = $env:FUNCTION_KEY ?? "<FUNCTION_KEY>"
$Headers  = @{ "Content-Type" = "application/json"; "x-functions-key" = $Key }

$Body = @{ GroupId = $GroupId; UserPrincipalName = $UserPrincipalName } | ConvertTo-Json

Invoke-RestMethod -Method DELETE -Uri "$BaseUrl/api/GroupMember" -Headers $Headers -Body $Body
