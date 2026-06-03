using namespace System.Net

param($Request, $TriggerMetadata)

switch ($Request.Method) {
    "GET" {
        $groupId = $Request.Query.GroupId
        if (-not $groupId) { $groupId = $Request.Body.GroupId }
        if (-not $groupId) {
            Send-Response -status ([HttpStatusCode]::BadRequest) -Body "GroupId is required"
            return
        }
        try {
            $group = Get-MgGroup -GroupId $groupId -ErrorAction Stop
            $body = [PSCustomObject]@{ Found = $true; Id = $group.Id; DisplayName = $group.DisplayName } | ConvertTo-Json
            Send-Response -status ([HttpStatusCode]::OK) -Body $body
        } catch {
            if ($_.Exception.Message -match '404|NotFound|ResourceNotFound') {
                Send-Response -status ([HttpStatusCode]::NotFound) -Body (@{ Found = $false } | ConvertTo-Json)
            } else {
                Send-Response -status ([HttpStatusCode]::InternalServerError) -Body ("Graph error: {0}" -f $_.Exception.Message)
            }
        }
    }
    "POST" {
        $name = $Request.Body.Name
        if (-not $name) {
            Send-Response -status ([HttpStatusCode]::BadRequest) -Body "Name is required"
            return
        }
        $mailNickname = $name -replace '[^a-zA-Z0-9]', ''
        if (-not $mailNickname) {
            Send-Response -status ([HttpStatusCode]::BadRequest) -Body "Name must contain at least one alphanumeric character"
            return
        }
        $params = @{
            DisplayName     = $name
            MailNickname    = $mailNickname
            SecurityEnabled = $true
            MailEnabled     = $false
            GroupTypes      = @()
        }
        try {
            $group = New-MgGroup -BodyParameter $params -ErrorAction Stop
            $body = [PSCustomObject]@{ Id = $group.Id; DisplayName = $group.DisplayName } | ConvertTo-Json
            Send-Response -status ([HttpStatusCode]::Created) -Body $body
        } catch {
            Send-Response -status ([HttpStatusCode]::InternalServerError) -Body ("Failed to create group: {0}" -f $_.Exception.Message)
        }
    }
    "DELETE" {
        $groupId = $Request.Query.GroupId
        if (-not $groupId) { $groupId = $Request.Body.GroupId }
        if (-not $groupId) {
            Send-Response -status ([HttpStatusCode]::BadRequest) -Body "GroupId is required"
            return
        }
        try {
            Remove-MgGroup -GroupId $groupId -ErrorAction Stop
            Send-Response -status ([HttpStatusCode]::OK) -Body "Group deleted"
        } catch {
            if ($_.Exception.Message -match '404|NotFound|ResourceNotFound') {
                Send-Response -status ([HttpStatusCode]::NotFound) -Body "Group not found"
            } else {
                Send-Response -status ([HttpStatusCode]::InternalServerError) -Body ("Failed to delete group: {0}" -f $_.Exception.Message)
            }
        }
    }
}
