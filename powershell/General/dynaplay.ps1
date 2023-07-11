$UserName = "novaprime"
$Password = "Pakalu@1234"
$API_URL = "localhost"
$API_Port="8080"
$JobName = "vault2"
$JobToken = "token"
$header = @{}
$header.Add('Authorization', 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$(${UserName}):$(${Password})")))
$Params = @{uri = "http://${API_URL}:${API_Port}/crumbIssuer/api/json";
        Method = 'Get';
        Headers = $header;}
$API_Crumb = Invoke-RestMethod @Params
write-host $API_Crumb
$header.Add('Jenkins-Crumb', $API_Crumb.crumb)
$Params['uri'] = "http://localhost:8080/$JobName/build?token=$JobToken"
$Params['Method'] = 'Post'
$Params['Headers'] = $header
Invoke-RestMethod @Params