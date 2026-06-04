# Usage: ./Group-DELETE.ps1 -GroupId <guid>
# Env:   FUNCTION_URL (default: http://localhost:7071)
#        FUNCTION_KEY (required for deployed function)
param(
    [Parameter(Mandatory)][string]$GroupId
)

$BaseUrl  = $env:FUNCTION_URL ?? "<FUNCTION_URL>"
$Key      = $env:FUNCTION_KEY ?? "<FUNCTION_KEY>"
$Headers  = @{ "x-functions-key" = $Key }

Invoke-RestMethod -Method DELETE -Uri "$BaseUrl/api/Group?GroupId=$GroupId" -Headers $Headers
