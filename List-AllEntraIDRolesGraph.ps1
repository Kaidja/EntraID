$Scopes = @(
    "RoleManagementPolicy.Read.AzureADGroup"
)

Connect-MgGraph -Scopes $Scopes

$Roles = Get-MgRoleManagementDirectoryRoleDefinition
$Roles | Select-Object -Property DisplayName, Id, Description | 
    ConvertTo-Json | Out-File C:\Temp\EntraRoles.json

Get-MgRoleManagementDirectoryRoleDefinition | Measure-Object
