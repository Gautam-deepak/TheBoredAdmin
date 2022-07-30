# Declare DSInternals as the required module.
# https://github.com/MichaelGrafnetter/DSInternals
#requires -Modules DSInternals

# Add a the required parameters
## [parameter(Mandatory)] - makes the parameter required
## [ValidateNotNullOrEmpty()] - validates that the parameter value is neither $null nor empty.
param (
    # Accepts the domain controller's hostname (e.g., dc1.contoso.com)
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $DomainController,
    # Accepts the domain partition naming context (e.g., dc=contoso,dc=com)
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $NamingContext,
    # Accepts the location or path of the weak password list File (i.e., the NSCS Top 100,000 Breached (Pwned) Passwords)
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $WeakPasswordsFile
)

# BEGIN WEAK AD PASSWORD TEST
(
    <# GET ALL AD USER ACCOUNTS
        1. Get all user accounts using the Get-ADReplAccount cmdlet.
            * The -All switch tells the cmdlet to get ALL accounts.
            * The -Server parameter accepts the name of the target domain controller.
            * The -NamingContext parameter accepts the naming context of the domain.
        2. The "Where-Object {$_.SamAccountType -eq 'User'}" filters the result to return only the 'User" account type.
        3. Send the accounts through the pipeline "|"
    #>
    Get-ADReplAccount -All -Server $DomainController -NamingContext $NamingContext |	Where-Object { $_.SamAccountType -eq 'User' } |

    <# TEST ALL USERS' PASSWORD QUALITY
        4. Test each accounts' password quality using the Test-PasswordQuality cmdlet.
            * The -IncludeDisabledAccounts switch will include disabled user accounts in the testing.
            * The -WeakPasswordsFile parameter accepts the location of the weak passwords list file.
    #>
    Test-PasswordQuality -IncludeDisabledAccounts -WeakPasswordsFile $WeakPasswordsFile

    <# RETURN / DISPLAY THE RESULT
        5. Return the ".WeakPasswords" property values containing the list of weak passwords users.
    #>
).WeakPassword
# END WEAK AD PASSWORD TEST

#How to use the script
<#
$params = @{
DomainController = 'win1.novaprime.in'
NamingContext = 'DC=novaprime,dc=in'
WeakPasswordsFile = 'C:\Users\novaprime\Downloads\password.txt'
}
.\exposeweakpasswords.ps1 @params

#>