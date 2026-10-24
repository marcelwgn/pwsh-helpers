function Show-EnvironmentVariables {
	[CmdletBinding()]
	[Alias('printenv')]
	Param()

	Get-ChildItem env: | Sort-Object | ForEach-Object { Write-Host ($_.Name + '=' + $_.Value) }
}