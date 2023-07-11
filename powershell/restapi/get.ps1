# listing a single resource

$uri="https://jsonplaceholder.typicode.com/posts/1"
Invoke-RestMethod -Uri $uri

# listing all resource

$uri="https://jsonplaceholder.typicode.com/posts/"
Invoke-RestMethod -Uri $uri         