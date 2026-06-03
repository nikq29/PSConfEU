# Usage: ./GroupMember-POST.ps1 -GroupId <guid> -UserPrincipalName <upn>
# Env:   FUNCTION_URL (default: http://localhost:7071)
#        FUNCTION_KEY (required for deployed function)
param(
    [Parameter(Mandatory)][string]$GroupId,
    [Parameter(Mandatory)][string]$UserPrincipalName
)

$BaseUrl  = $env:FUNCTION_URL ?? "https://psconfeu-gpfkaff9bjgkewe5.germanywestcentral-01.azurewebsites.net"
$Key      = $env:FUNCTION_KEY ?? "wz8QaI9kYeyJWviRzAV9zw7cBL7eTWtkz_vSPK-P4wFWAzFuJ8HFhg=="
$Headers  = @{ "Content-Type" = "application/json"; "x-functions-key" = $Key }

$Body = @{ GroupId = $GroupId; UserPrincipalName = $UserPrincipalName } | ConvertTo-Json

Invoke-RestMethod -Method POST -Uri "$BaseUrl/api/GroupMember" -Headers $Headers -Body $Body
