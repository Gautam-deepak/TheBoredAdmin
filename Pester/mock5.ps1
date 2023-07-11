#FirstName,LastName,UserName
#Adam,Bertram,abertram
function Get-Employee {
    Import-Csv -Path C:\Employees.csv
}