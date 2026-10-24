function New-AdoPr {
	[Alias("napr")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$prTitle
	)

	$pr = az repos pr create --title $prTitle --open

	$prParsed = $pr | ConvertFrom-Json
	$prId = $prParsed.pullRequestId

	Write-Host "Successfully created pull request with ID: $prId" -ForegroundColor Green
}