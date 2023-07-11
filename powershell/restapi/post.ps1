# creating a resource

$body=@{
    title='foo'
    body='bar'
    userid='123'
}
$jsonbody=$body | ConvertTo-Json

$params=@{
    method='POST'
    Contenttype  = 'application/json'
    uri='https://jsonplaceholder.typicode.com/posts'
    body=$jsonbody
}

Invoke-RestMethod @params