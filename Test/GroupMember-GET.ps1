# Usage: ./GroupMember-GET.ps1 -GroupId <guid>
# Env:   FUNCTION_URL (default: http://localhost:7071)
#        FUNCTION_KEY (required for deployed function)
param(
    [Parameter(Mandatory)][string]$GroupId
)

$BaseUrl  = $env:FUNCTION_URL ?? "<FUNCTION_URL>"
$Key      = $env:FUNCTION_KEY ?? "<FUNCTION_KEY>"
$Headers  = @{ "x-functions-key" = $Key }

Invoke-RestMethod -Method GET -Uri "$BaseUrl/api/GroupMember?GroupId=$GroupId" -Headers $Headers
