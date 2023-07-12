function Get-Password {
	param(
		[pscredential]$Credential
		)
		$Credential.GetNetworkCredential().Password
}
