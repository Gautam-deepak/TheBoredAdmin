# modifying a resource


# modifying a resource

$body=@{
    body='bar bar'
}
$jsonbody=$body | ConvertTo-Json

$params=@{
    method='PATCH'
    Contenttype  = 'application/json'
    uri='https://jsonplaceholder.typicode.com/posts/1'
    body=$jsonbody
}

Invoke-RestMethod @params