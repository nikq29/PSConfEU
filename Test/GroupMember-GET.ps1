# Usage: ./GroupMember-GET.ps1 -GroupId <guid>
# Env:   FUNCTION_URL (default: http://localhost:7071)
#        FUNCTION_KEY (required for deployed function)
param(
    [Parameter(Mandatory)][string]$GroupId
)

$BaseUrl  = $env:FUNCTION_URL ?? "https://psconfeu-gpfkaff9bjgkewe5.germanywestcentral-01.azurewebsites.net"
$Key      = $env:FUNCTION_KEY ?? "wz8QaI9kYeyJWviRzAV9zw7cBL7eTWtkz_vSPK-P4wFWAzFuJ8HFhg=="
$Headers  = @{ "x-functions-key" = $Key }

Invoke-RestMethod -Method GET -Uri "$BaseUrl/api/GroupMember?GroupId=$GroupId" -Headers $Headers
