# Automated login for Non-MFA accounts ( it doesn't work with MFA accounts)

#variable

$user="gautamd@gautamd.onmicrosoft.com"
$scriptpath="D:\Office-Docs\Azure_gautamd_key_password"
$tenantid="3387b0ab-2c15-4e17-9ec1-c1b77f1fbc06"


# To generate a AES key for encryption (Need to be used only once,must be removed from the script)
#$aeskeypath = "$scriptpath\aeskey.key"
#$AESKey = New-Object Byte[] 32
#[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
#Set-Content $aeskeypath $AESKey 

# To write password into a password file using a secure AES key (Need to be used only once,must be removed from the script)

#(get-credential).password | ConvertFrom-SecureString -Key (Get-Content $scriptpath\aeskey.key) | set-content $scriptpath\password.txt

# Using the encrypted password again in the script

$encrypted=Get-Content $scriptpath\password.txt | ConvertTo-SecureString -Key (Get-Content $scriptpath\aeskey.key)

# Using the saved password and username in the credential

$credential = New-Object System.Management.Automation.PSCredential($user,$encrypted)

Connect-AzAccount -Credential $credential -TenantId $tenantid