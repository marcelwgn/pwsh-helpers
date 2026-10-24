function GitAdd {
	[Alias("gad")]
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Pattern = "."
	)

	ExecuteGitCommand "git add $Pattern" `
		"Git add with pattern '$Pattern' succeeded" `
		"Git add with pattern '$Pattern' failed with:" `
	| Out-Null
}

function GitCommit {
	[Alias("gco")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Message,
		[Parameter()]
		[switch]
		$NoVerify
	)
	# Add no verify parameter to skip pre-commit hooks
	$GitParams = ""
	if ($NoVerify) {
		$GitParams += " --no-verify"
	}
	ExecuteGitCommand "git commit -m `"$Message`" $GitParams"`
		"Git commit succeeded" `
		"Git commit failed with:" `
	| Out-Null
}

function GitPush {
	[Alias("gpsh")]
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Remote,
		[Parameter()]
		[switch]
		$NoVerify
	)
	$GitParams = ""
	if ($NoVerify) {
		$GitParams += " --no-verify"
	}
	ExecuteGitCommand "git push $Remote $GitParams" `
		"Git push with remote '$Remote' succeeded" `
		"Git push failed with:" `
	| Out-Null
}

function GitPull {
	[Alias("gpl")]
	[CmdletBinding()]
	param ()

	$lastCommit = (git rev-parse HEAD)
	if (ExecuteGitCommand "git pull") {
		$getNewCommitCount = Invoke-Expression "git rev-list --count ${lastCommit}..HEAD"
		$successMessage = "Git pull succeeded"
		switch ($getNewCommitCount) {
			0 { $successMessage += ", no new commits" }
			1 { $successMessage += ", pulled 1 new commit" }
			Default { $successMessage += ", pulled $getNewCommitCount new commits" }
		}
		Write-Host $successMessage -ForegroundColor Green
	}
	else {
		Write-Host "Git pull failed" -ForegroundColor DarkRed
	}
}

function GitUpdate {
	[Alias("gup")]
	[CmdletBinding()]
	param ()

	$hasNoChanges = (GitHasChanges) -ne $true
	if ($hasNoChanges) {
		Write-Host "Git is clean" -ForegroundColor Green
	}
	else {
		Write-Host "Git is not clean, stashing changes" -ForegroundColor Yellow
		ExecuteGitCommand "git stash -u" `
			"Successfully stashed changes" `
			"Git stash failed with:" `
		| Out-Null
	}
	GitPull
	if ($hasNoChanges -ne $true) {
		Write-Host "Restoring stashed changes" -ForegroundColor Yellow
		ExecuteGitCommand "git stash pop" `
			"Successfully restored stashed changes" `
			"Git stash failed with:" `
		| Out-Null
	}
}

function GitMergeMain {
	[Alias("gmm")]
	[CmdletBinding()]
	param() 


	$hasNoChanges = (GitHasChanges) -ne $true
	if ($hasNoChanges) {
		Write-Host "Git is clean" -ForegroundColor Green
	}
	else {
		Write-Host "Git is not clean, stashing changes" -ForegroundColor Yellow
		ExecuteGitCommand "git stash -u" `
			"Successfully stashed changes" `
			"Git stash failed with:" `
		| Out-Null
	}

	GitCheckoutDefaultBranch

	ExecuteGitCommand "git checkout -" `
		"Switched back to original branch" `
		"Failed to switch back:" `
		| Out-Null

	ExecuteGitCommand "git merge main" `
		"Successfully merged main" `
		"Failed to merge main:" `
		| Out-Null
	
	if ($hasNoChanges -ne $true) {
		Write-Host "Restoring stashed changes" -ForegroundColor Yellow
		ExecuteGitCommand "git stash pop" `
			"Successfully restored stashed changes" `
			"Git stash failed with:" `
		| Out-Null
	}
}

function GitAddCommitPush {
	[Alias("gacp")]
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Message
	)

	if ((GitHasChanges) -ne $true) {
		Write-Host "No changes to commit, skipping" -ForegroundColor Yellow
		return;
	}
	GitAdd
	GitCommit $Message
	GitPush
}

function GitAddCommitPushNoVerify {
	[Alias("gacpn")]
	[CmdletBinding()]
	param (
		[Parameter()]
		[string]
		$Message
	)

	if ((GitHasChanges) -ne $true) {
		Write-Host "No changes to commit, skipping" -ForegroundColor Yellow
		return;
	}
	GitAdd
	GitCommit $Message -NoVerify
	GitPush -NoVerify
}

function GitFeatureBranch {
	[Alias("gfb")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$BranchName
	)

	if (GitHasBranch($BranchName)) {
		Write-Host "Branch '$BranchName' already exists, skipping" -ForegroundColor Yellow
		ExecuteGitCommand "git checkout $BranchName" `
			"Git checkout '$BranchName' succeeded" `
			"Git checkout '$BranchName' failed with:" `
		| Out-Null
		return;
	}
	GitPull
	ExecuteGitCommand "git checkout -b $BranchName" `
		"Successfully created and checked out branch '$BranchName'" `
		"Failed to create branch $BranchName with:" `
	| Out-Null
}

function GitFeatureBranchUser {
	[Alias("gfbu")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$BranchName
	)

	GitFeatureBranch "user/$env:USERNAME/$BranchName"
}

function GitCheckoutDefaultBranch {
	[Alias("gum")]
	[CmdletBinding()]
	param ()

	$DefaultBranch = GitGetDefaultBranch
	if ($DefaultBranch -eq "") {
		Write-Host "Could not determine default branch" -ForegroundColor DarkRed
		return;
	}

	$hasNoChanges = (GitHasChanges) -ne $true
	if ($hasNoChanges) {
		Write-Host "Git is clean" -ForegroundColor Green
	}
	else {
		Write-Host "Git is not clean, stashing changes" -ForegroundColor Yellow
		ExecuteGitCommand "git stash -u" `
			"Successfully stashed changes" `
			"Git stash failed with:" `
		| Out-Null
	}

	ExecuteGitCommand "git checkout $DefaultBranch" `
		"Git checkout '$DefaultBranch' succeeded" `
		"Git checkout '$DefaultBranch' failed with:" `
	| Out-Null

	GitPull

	if ($hasNoChanges -ne $true) {
		Write-Host "Restoring stashed changes" -ForegroundColor Yellow
		ExecuteGitCommand "git stash pop" `
			"Successfully restored stashed changes" `
			"Git stash failed with:" `
		| Out-Null
	}
}

function GitCleanLocalOnlyBranches {
	# This function will delete all local branches with no remote
	[Alias("gclob")]
	[CmdletBinding()]
	param ()

	ExecuteGitCommand "git fetch -p" `
		"Fetched and pruned remote branches" `
		"Failed to fetch and prune remote branches" 
	| Out-Null

	$branches = git branch -vv | Select-String ': gone]' | ForEach-Object { $_.Line.split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0] }

	Write-Host "About to delete the following branches" -ForegroundColor Yellow
	$branches | ForEach-Object {
		Write-Host $_ -ForegroundColor Gray
	}
	$fContinue = Read-Host "Continue? (y/n)"

	if ( $fContinue -ieq "y" ) {
		$branches | ForEach-Object {
			ExecuteGitCommand "git branch -D $_" `
				"Successfully deleted $_" `
				"Failed to delete $_"
			| Out-Null
		}
		Write-Host "Successfully deleted branches" -ForegroundColor Green
	} 
	else {
		Write-Host "Aborting" -ForegroundColor Red
	}
}

### Helper functions ###
function GitGetDefaultBranch {
	if (GitHasBranch("main")) {
		return "main"
	}
	elseif (GitHasBranch("master")) {
		return "master"
	}
	return ""
}

function GitHasChanges {
	$result = & git status *>&1 | Out-String
	return !$result.Contains("nothing to commit, working tree clean");
}

function GitHasBranch {
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$BranchName
	)
	$result = & git show-ref refs/heads/$BranchName *>&1 | Out-String
	return $result -ne "";
}

function GitBranchHasRemoteBranch {
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$BranchName
	)


	$result = & git show-ref refs/heads/$BranchName *>&1 | Out-String
	return $result -ne "";
}

function ExecuteGitCommand {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Command,
		[Parameter(Mandatory = $false)]
		[string]
		$SuccessMessage,
		[Parameter(Mandatory = $false)]
		[string]
		$ErrorMessage
	)

	$result = (Invoke-Expression $Command) *>&1 | Out-String
	if ($LASTEXITCODE -eq 0) {
		if ($SuccessMessage -ne "") {
			Write-Host "$SuccessMessage" -ForegroundColor Green
		}
		return $true
	}
	else {
		if ($ErrorMessage -ne "") {
			Write-Host "$ErrorMessage" -ForegroundColor DarkRed
		}
		Write-Host $result -ForegroundColor Red
		return $false
	}
}