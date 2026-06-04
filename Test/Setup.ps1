$Group = (./Group-POST.ps1 -Name "PSConfEU")

./groupmember-post.ps1  -GroupId $Group.id -UserPrincipalName <USER_PRINCIPAL_NAME>

./group-delete.ps1 -GroupId $Group.id