# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv .\bulk_users.csv


    foreach ($User in $ADUsers)
{
    try { 
	#Read user data from each field in each row and assign the data to a variable as below
		
	
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in
    $email      = $User.email
    $Password   = $User.Password
    $initials   = $user.middleinitial
    $Username 	= -join ("$firstname",$lastname.ToCharArray()[0].ToString())

    #$a=Get-ADUser -identity $Username -ErrorAction Ignore
	#Check to see if the user already exists in AD
	if (!(Get-ADUser -Filter {samaccountname -eq $Username}))
	{
          #User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@nova.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Initials $initials
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -EmailAddress $email `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $False
         
	}
	else
	{

    
         #If user does exist, give a warning
		 Write-Host "A user account with username $Username already exist in Active Directory."

        }
    
}
catch {
       $issue=$($Error[0].exception.message)
       write-host Problem creating the account $username $issue
    }

}