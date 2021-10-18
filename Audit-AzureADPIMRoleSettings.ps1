#Install AzureADPreview PowerShell Module
Install-module AzureADPreview -Force -Verbose

#Connect Azure AD
Connect-AzureAD

#Audit file location. It creates a CSV file
$AuditFileLocation = "C:\AADAudit.csv"
#Get Azure AD Tenant ID
$AzureADTenantDID = (Get-AzureADTenantDetail).ObjectId

#Azure AD Role names and IDs on my GitHub account
$URL = "https://raw.githubusercontent.com/Kaidja/AzureActiveDirectory/main/AzureADRoles.json"
#Convert Azure AD Roles from JSON
$AADGitHubRoles = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content | ConvertFrom-Json

#Process the AD roles and gather the data for each role
foreach($AADRole in $AADGitHubRoles){

    Write-Output -InputObject "---- Processing $($AADRole.DisplayName)"
    
    #Define the query filter
    $Filter = "ResourceId eq '$($AzureADTenantDID)' and RoleDefinitionId eq '$($AADRole.ID)'"
    $PIMADRoleSettings = Get-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Filter $Filter
    
    #Get the PIM role settings
    $ExpirationRule = $PIMADRoleSettings.UserMemberSettings[0].Setting | ConvertFrom-Json
    $MfaRule = $PIMADRoleSettings.UserMemberSettings[1].Setting | ConvertFrom-Json
    $JustificationRule = $PIMADRoleSettings.UserMemberSettings[2].Setting | ConvertFrom-Json
    $TicketingRule = $PIMADRoleSettings.UserMemberSettings[3].Setting | ConvertFrom-Json
    $ApprovalRule = $PIMADRoleSettings.UserMemberSettings[4].Setting | ConvertFrom-Json

    #Build object for each role
    $PIMProperties = $null
    $PIMProperties = [ORDERED]@{
        RoleID = $AADRole.Id
        RoleName = $AADRole.DisplayName
        PermanentAssignment = $ExpirationRule.permanentAssignment
        MaximumGrantPeriodInMinutes = $ExpirationRule.maximumGrantPeriodInMinutes
        MfaRequired = $MfaRule.mfaRequired
        Required = $JustificationRule.required
        TicketingRequired = $TicketingRule.ticketingRequired
    }

    #Add Approvals, if exist
    $i = 1
    foreach($Approval in $ApprovalRule.Approvers){
        
        $PIMProperties += @{
            "Approval $i" = $Approval.DisplayName
        }

        $i++
    }

    $Object = New-Object -TypeName PSObject -Property $PIMProperties
    #Convert to CSV
    $Object | ConvertTo-Csv -OutVariable ExportData -NoTypeInformation -Delimiter ";" | Out-Null
    #Export Role settings to a CSV file
    $ExportData[1..($ExportData.count - 1)] | ForEach-Object { Add-Content -Value $PSItem -Path $AuditFileLocation }

}
