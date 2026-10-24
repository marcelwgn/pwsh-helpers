Import-Module $PSScriptRoot/utils.psm1
Import-Module $PSScriptRoot/git-helpers.psm1

$toolsToOpenFolders = @("code-insiders", "code", "devenv", "start")

function Open-FileInTool {
	[Alias("open")]
	[CmdletBinding()]
	param (
		[string]
		$pathSpecifier = "."
	)

	# Handle directories
	if (Test-Path $pathSpecifier -PathType Container) {
		# Use any of the available tools
		foreach ($entry in $toolsToOpenFolders) {
			if (Test-CommandExists $entry) {
				try {
					if ($entry -eq "start") {
						Start-Process -FilePath $pathSpecifier
					}
					else {
						& $entry $pathSpecifier
					}
					return
				}
				catch {
					Write-Host "Failed to open folder with $entry" -ForegroundColor Yellow
				}
			}
		}
		Start-Process $pathSpecifier
		return;
	}

	# Handle anything else that is not a directory
	if (Test-Path $pathSpecifier) {
		Start-Process $pathSpecifier
		return
	}

	# Handle file extensions
	if ($pathSpecifier -ne "." -or $pathSpecifier.Length -ne 0) {
		# Find the first file with the given extension
		$files = Get-ChildItem -Recurse -File -Filter "*.$pathSpecifier"
		if ($files.Count -eq 0) {
			Write-Host "No files found with extension '$pathSpecifier'" -ForegroundColor Yellow
			return
		}
		Start-Process $files[0]
		return
	}
}

function Find-InHistory {
	[Alias("fih")]
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]
		$Search,
		[Parameter()]
		[bool]
		$stripFindInHistory = $true
	)

	$history = Get-Content (Get-PSReadlineOption).HistorySavePath
	$results = @{}
	ForEach ($entry in $history) {
		if ($entry.Contains($Search)) {
			$startsWithHistory = $entry.StartsWith("fih") || $entry.StartsWith("FindInHistory")
			if (!$startsWithHistory || $stripFindInHistory) {
				if ($results.Contains($entry)) {
					$results[$entry] = ($results[$entry] + 1)
				}
				else {
					$results.Add($entry, 1) *> $null
				}
			}
		}
	}

	$results.GetEnumerator() | Sort-Object -Property value | ForEach-Object {
		Write-Host $_.Key
	}

	if ($history.Count -eq 0) {
		Write-Host "No results found" -ForegroundColor Yellow
	}
}