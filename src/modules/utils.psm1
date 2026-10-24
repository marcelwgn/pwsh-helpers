function Test-CommandExists {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$command
	)
	$oldPreference = $ErrorActionPreference
	$ErrorActionPreference = 'stop'
	try { if (Get-Command $command) { RETURN $true } }
	Catch { RETURN $false }
	Finally { $ErrorActionPreference = $oldPreference }
}
