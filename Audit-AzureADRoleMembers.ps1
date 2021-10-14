#Connect to Azure
Connect-AzureAD

$AuditData = @()
$AzureADRoles = Get-AzureADDirectoryRole
foreach($Role in $AzureADRoles){
    
    $GroupMembers = Get-AzureADDirectoryRoleMember -ObjectId $Role.ObjectId

    foreach($Member in $GroupMembers){

        If($Member.ObjectType -eq "ServicePrincipal"){
            
            $ObjectType = "ServicePrincipal"
        }
        Else{
            $ObjectType = "User"
        }

        $UserProperties = @{
            AzureADRole = $Role.DisplayName
            ObjectType = $ObjectType
            DisplayName = $Member.DisplayName
        
        }
        $Object = New-Object -TypeName PSObject -Property $UserProperties
        $AuditData += $Object
    }
}

$AuditData
