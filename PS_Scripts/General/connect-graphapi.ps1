#The resource URI
$resource = "https://graph.microsoft.com"
# Your Client ID and Client Secret obainted when registering your WebApp
$clientid = "your_client_id"
$clientSecret = "YOUR_CLIENT_SECRET"
$redirectUri = "https://graphapitest.com/auth"
$clientcert=Get-ChildItem "Cert:\CurrentUser\my\4E9E5B2A318EB2EFEC0C2BA7F73C692D69720048"
$TenantId="3387b0ab-2c15-4e17-9ec1-c1b77f1fbc06"

# UrlEncode the ClientID and ClientSecret and URL's for special characters 
Add-Type -AssemblyName System.Web
$clientIDEncoded = [System.Web.HttpUtility]::UrlEncode($clientid)
$clientSecretEncoded = [System.Web.HttpUtility]::UrlEncode($clientSecret)
$redirectUriEncoded =  [System.Web.HttpUtility]::UrlEncode($redirectUri)
$resourceEncoded = [System.Web.HttpUtility]::UrlEncode($resource)
$scopeEncoded = [System.Web.HttpUtility]::UrlEncode("https://outlook.office.com/user.readwrite.all")

# Function to popup Auth Dialog Windows Form
Function Get-AuthCode {
    Add-Type -AssemblyName System.Windows.Forms

    $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=440;Height=640}
    $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=420;Height=600;Url=($url -f ($Scope -join "%20")) }

    $DocComp  = {
        $Global:uri = $web.Url.AbsoluteUri        
        if ($Global:uri -match "error=[^&]*|code=[^&]*") {$form.Close() }
    }
    $web.ScriptErrorsSuppressed = $true
    $web.Add_DocumentCompleted($DocComp)
    $form.Controls.Add($web)
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null

    $queryOutput = [System.Web.HttpUtility]::ParseQueryString($web.Url.Query)
    $output = @{}
    foreach($key in $queryOutput.Keys){
        $output["$key"] = $queryOutput[$key]
    }

    $output
}


# Get AuthCode
$url = "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&redirect_uri=$redirectUriEncoded&client_id=$clientID&resource=$resourceEncoded&prompt=admin_consent&scope=$scopeEncoded"
Get-AuthCode
# Extract Access token from the returned URI
$regex = '(?<=code=)(.*)(?=&)'
$authCode  = ($uri | Select-string -pattern $regex).Matches[0].Value

Write-output "Received an authCode, $authCode"


#get Access Token
$body = "grant_type=authorization_code&redirect_uri=$redirectUri&client_id=$clientId&client_secret=$clientSecretEncoded&code=$authCode&resource=$resource"
$tokenResponse = Invoke-RestMethod https://login.microsoftonline.com/common/oauth2/token `
    -Method Post -ContentType "application/x-www-form-urlencoded" `
    -Body $body `
    -ErrorAction STOP

#tokenresponse
#$apiUrl = 'https://graph.microsoft.com/v1.0/Groups/'
#$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
#$Users = ($Data | Select-Object Value).Value
#$Users | Format-Table displayName, userPrincipalname, id
#$apiurl="https://login.microsoftonline.com/gautamd.onmicrosoft.com/oauth2/token"

#Connect-MgGraph -ClientID YOUR_APP_ID -TenantId YOUR_TENANT_ID -CertificateName YOUR_CERT_SUBJECT
$mgraph = Connect-MgGraph -ClientID $clientID -TenantId $TenantId -CertificateName $clientcert.Subject

#Automated sign in
#install-module -name msal.ps -acceptlicense
#$MSToken = Get-MsalToken -ClientId $ClientId -TenantId $TenantId -ClientCertificate $ClientCert -scope 'https://graph.microsoft.com/.default' 
#$GraphGroupUrl = 'https://graph.microsoft.com/v1.0/Groups/'
#(Invoke-RestMethod -Headers @{Authorization = "Bearer $($MSToken.AccessToken)"} -Uri $GraphGroupUrl -Method Get).value.displayName

<#
#send email

$apiurl="https://graph.microsoft.com/v1.0/me/sendMail"

$Body = 
@"
{
"message" : {
"subject": "Test message",
"body" : {
"contentType": "Text",
"content": "This is test mail"
},
"toRecipients": [{"emailAddress" : { "address" : "deepakgautam139@gmail.com" }}]
}
}
"@

$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
#>
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($MSToken.AccessToken)"} -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"


