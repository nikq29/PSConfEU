using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}




$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

if ($name) {
    $body = "Hello, $name. This HTTP triggered function executed successfully."
}

$group = Get-MgGroup -Filter ("DisplayName eq '{0}'" -f $name)

$userlist = [System.Collections.Generic.List[PSObject]]@()

if ($null -ne $group) {
 
    (Get-MgGroupMember -GroupId $group.id) | ForEach-Object {

        $user = Get-MgUser -UserId $_.id 

        if ($null -ne $user) {
            $oneUser = [PSCustomObject]@{
                DisplayName = $user.DisplayName
            }
    
            $userlist.Add($oneUser)    
        }
    }
    
    $body = $userlist.DisplayName -join(", ")

} else {
    $body = ("We did not find the group [{0}] in our tenant" -f $Name)
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Send-Response -status [HttpStatusCode]::OK -Body $body
