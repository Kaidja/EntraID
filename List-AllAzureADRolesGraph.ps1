$Scopes = @(
    "Directory.Read.All"
)

Connect-MgGraph -Scopes $Scopes -ForceRefresh

Get-MgDirectoryRoleTemplate | 
    Select-Object -Property DisplayName,Id,Description | 
    Sort-Object -Property DisplayName | ConvertTo-Json | Out-File "C:\Reports\AADRoles.JSON"

Get-MgDirectoryRoleTemplate | Measure-Object
