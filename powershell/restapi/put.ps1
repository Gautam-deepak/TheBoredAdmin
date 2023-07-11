# updating a resource

$body=@{
    title='foo'
    body='bar disco'
    userid='123'
}
$jsonbody=$body | ConvertTo-Json

$params=@{
    method='PUT'
    Contenttype  = 'application/json'
    uri='https://jsonplaceholder.typicode.com/posts/1'
    body=$jsonbody
}

Invoke-RestMethod @params