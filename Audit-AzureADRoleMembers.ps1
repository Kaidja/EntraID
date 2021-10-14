#Connect to Azure
Connect-AzureAD

$AuditData = @()

#Get the Azure AD Directory Roles
$AzureADRoles = Get-AzureADDirectoryRole
foreach($Role in $AzureADRoles){

    #Get specific Azure AD Role members    
    $GroupMembers = Get-AzureADDirectoryRoleMember -ObjectId $Role.ObjectId

    foreach($Member in $GroupMembers){
        #Check the member type
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
        #Create PowerShell object and save the information
        $Object = New-Object -TypeName PSObject -Property $UserProperties
        $AuditData += $Object
    }
}

#Print out the data
$AuditData
