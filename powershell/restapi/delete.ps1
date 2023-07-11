# deleting a resource


$params=@{
    method="Delete"
    uri="https://jsonplaceholder.typicode.com/posts/1"
}
Invoke-RestMethod @params