using namespace System.Net

param($Request, $TriggerMetadata)

$groupId = $Request.Query.GroupId
if (-not $groupId) { $groupId = $Request.Body.GroupId }
if (-not $groupId) {
    Send-Response -status ([HttpStatusCode]::BadRequest) -Body "GroupId is required"
    return
}

switch ($Request.Method) {
    "GET" {
        $members = Get-MgGroupMember -GroupId $groupId -All
        $userList = $members | Where-Object {
            $_.AdditionalProperties['@odata.type'] -eq '#microsoft.graph.user'
        } | ForEach-Object {
            $user = Get-MgUser -UserId $_.Id
            [PSCustomObject]@{ DisplayName = $user.DisplayName; UPN = $user.UserPrincipalName }
        }
        Send-Response -status ([HttpStatusCode]::OK) -Body (@($userList) | ConvertTo-Json)
    }
    "POST" {
        $upn = $Request.Body.UserPrincipalName
        if (-not $upn) {
            Send-Response -status ([HttpStatusCode]::BadRequest) -Body "UserPrincipalName is required"
            return
        }
        $user = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue
        if (-not $user) {
            Send-Response -status ([HttpStatusCode]::NotFound) -Body "User not found"
            return
        }
        try {
            New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.Id -ErrorAction Stop
            Send-Response -status ([HttpStatusCode]::OK) -Body "Member added"
        } catch {
            if ($_.Exception.Message -match 'already exist') {
                Send-Response -status ([HttpStatusCode]::Conflict) -Body "User is already a member of this group"
            } else {
                Send-Response -status ([HttpStatusCode]::InternalServerError) -Body ("Failed to add member: {0}" -f $_.Exception.Message)
            }
        }
    }
    "DELETE" {
        $upn = $Request.Query.UserPrincipalName
        if (-not $upn) { $upn = $Request.Body.UserPrincipalName }
        if (-not $upn) {
            Send-Response -status ([HttpStatusCode]::BadRequest) -Body "UserPrincipalName is required"
            return
        }
        $user = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue
        if (-not $user) {
            Send-Response -status ([HttpStatusCode]::NotFound) -Body "User not found"
            return
        }
        try {
            Remove-MgGroupMemberByRef -GroupId $groupId -DirectoryObjectId $user.Id -ErrorAction Stop
            Send-Response -status ([HttpStatusCode]::OK) -Body "Member removed"
        } catch {
            if ($_.Exception.Message -match '404|NotFound|ResourceNotFound') {
                Send-Response -status ([HttpStatusCode]::NotFound) -Body "User is not a member of this group"
            } else {
                Send-Response -status ([HttpStatusCode]::InternalServerError) -Body ("Failed to remove member: {0}" -f $_.Exception.Message)
            }
        }
    }
}
