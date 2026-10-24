function Show-GitRepoWebsite {
	[Alias("sgr")]
	[CmdletBinding()]
	param ()

	$repoUrl = GetCurrentRemoteURL
	if ($repoUrl.Length -eq 0) {
		Write-Host "Could not determine repo url" -ForegroundColor DarkRed
		return;
	}
	Write-Host "Repo website is $repoUrl" -ForegroundColor Green
	Start-Process $repoUrl
}

function Show-GitBranchWebsite {
	[Alias("sgb")]
	[CmdletBinding()]
	param (
	)

	$repoUrl = GetCurrentRemoteURL
	$branchName = (git branch --show-current)
	if ($repoUrl.Length -eq 0) {
		Write-Host "Could not determine repo url" -ForegroundColor DarkRed
		return;
	}
	$branchUrl = "$repoUrl/commits/$branchName"
	Write-Host "Branch website is $branchUrl" -ForegroundColor Green
	Start-Process $branchUrl
}

function Show-GitCommitWebsite {
	[Alias("sgc")]
	[CmdletBinding()]
	param (
	)

	$repoUrl = GetCurrentRemoteURL
	$commitHash = (git rev-parse HEAD)
	if ($repoUrl.Length -eq 0) {
		Write-Host "Could not determine repo url" -ForegroundColor DarkRed
		return;
	}
	$commitUrl = "$repoUrl/commit/$commitHash"
	Write-Host "Commit website is $commitUrl" -ForegroundColor Green
	Start-Process $commitUrl
}

function Show-GitHubCommitStatusChecks {
	[Alias("sghc")]
	[CmdletBinding()]
	param ()

	$repoUrl = GetCurrentRemoteURL
	if ($repoUrl.Length -eq 0) {
		Write-Host "Could not determine repo url" -ForegroundColor DarkRed
		return;
	}

	$ownerAndRepo = $repoUrl.Split("/")[-2..-1] -join "/"
	$commitHash = (git rev-parse HEAD)
	$apiUrl = "/repos/$ownerAndRepo/commits/$commitHash/check-runs"

	$result = gh api $apiUrl | ConvertFrom-Json
	$checks = @($result.check_runs | Sort-Object -Property status -Descending | ForEach-Object -Parallel {
			@{
				name   = $_.name
				url    = $_.details_url
				status = ([string]::IsNullOrEmpty($_.conclusion)) ? "in progress" : $_.conclusion
				statusRaw = $_.conclusion
			}
		}
	)

	# No checks
	if ($checks.Length -eq 0) {
		Write-Host "No checks found for commit $commitHash" -ForegroundColor Yellow
		return;
	}

	Write-Host "Checks for commit:" -ForegroundColor Blue
	foreach ($detailUrl in $checks) {
		$color = "Green"
		if ($detailUrl.status -eq "failure") {
			$color = "Red"
		}
		elseif ($detailUrl.status -eq "in progress") {
			$color = "Yellow"
		}
		Write-Host -NoNewline "- $($detailUrl.name)"
		Write-Host " ($($detailUrl.status))" -ForegroundColor $color
		Write-Host "  $($detailUrl.url)"
	}
}

function Show-GitHubPr {
	[Alias("sghpr")]
	[CmdletBinding()]
	param (
	)

	gh pr view --web
}


### Helper functions ###
function GetRemoteForBranch {
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$BranchName
	)
	$result = (git config --get branch.$BranchName.remote).Trim()
	return $result
}

function GetCurrentRemoteURL {
	param (
	)

	$branchName = (git branch --show-current)
	$remoteName = (GetRemoteForBranch $branchName)

	$result = (git config --get remote.$remoteName.url).Trim().TrimEnd(".git")
	if ($result.StartsWith("git@")) {
		$result = $result.Replace(":", "/").Replace("git@", "https://")
	}
	return $result
}