Write-Host "Starting PowerShell setup script"

# Setting up git
git config --global push.autoSetupRemote true

Write-Host "Installing posh git"
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

Write-Host "Writing default pwsh profile"

$desiredProfileCommands = Get-Content -Path "default-profile.ps1" | Where-Object { $_ -notmatch "^#" } | Where-Object { $_ -ne "" }

# Copy the desired profile if there is no profile or if it is null
if (!(Test-Path -Path $PROFILE)) {
	Write-Host "No profile found, creating one"
	New-Item -Path $PROFILE -ItemType File -Force | Out-Null
	Copy-Item -Path "default-profile.ps1" -Destination $PROFILE
}
else {
	$currentProfileCommands = (Get-Content -Path $PROFILE)
	if ($null -eq $currentProfileCommands ) {
		Write-Host "Profile is empty, copying default profile"
		Copy-Item -Path "default-profile.ps1" -Destination $PROFILE
	}
	else {
		foreach ($command in $desiredProfileCommands) {
			if ($currentProfileCommands.Contains($command)) {
				Write-Host "Command '$command' already in profile, skipping"
				continue
			}
			else {
				Write-Host "Adding '$command' to profile"
				Add-Content $profile $command
			}
		}
	}
}

Write-Host "Installing pwsh helpers"
.\build\install-globally.ps1

Write-Host "Deploying personal Copilot instructions"

$copilotDir = Join-Path $HOME ".copilot"
if (!(Test-Path -Path $copilotDir)) {
	Write-Host "Creating Copilot directory at $copilotDir"
	New-Item -Path $copilotDir -ItemType Directory | Out-Null
}

$copilotInstructions = Join-Path $copilotDir "copilot-instructions.md"
$copilotSource = "copilot\copilot-instructions.md"

if (!(Test-Path -Path $copilotInstructions)) {
	Write-Host "Copying Copilot instructions to $copilotInstructions"
	Copy-Item -Path $copilotSource -Destination $copilotInstructions
}
else {
	$overwriteCopilot = Read-Host "Copilot instructions already exist at $copilotInstructions. Overwrite (y/n)?"
	if ($overwriteCopilot -eq "y") {
		Write-Host "Overwriting Copilot instructions"
		Copy-Item -Path $copilotSource -Destination $copilotInstructions -Force
	}
	else {
		Write-Host "Skipping Copilot instructions"
	}
}


$setupAdo = Read-Host "Setup Azure CLI and ADO (y/n)?"

if ($setupAdo -eq "y") {
	Write-Host "Installing Azure CLI"
	winget install Microsoft.AzureCLI -s winget

	if (Get-Command az -CommandType Application -ErrorAction SilentlyContinue) {
		Write-Host "Installing Azure DevOps extension"
		az extension add --name azure-devops

		Write-Host "Authenticating Azure CLI"
		az login
	}
	else {
		Write-Warning "Azure CLI is not available on the current PATH. Open a new PowerShell session and rerun this script to finalize Azure CLI and ADO setup."
	}
}
else {
	Write-Host "Skipping Azure CLI and ADO setup"
}

$setupGithub = Read-Host "Setup GitHub CLI (y/n)?"
if ($setupGithub -eq "y") {
	Write-Host "Installing GitHub CLI"
	winget install GitHub.cli -s winget

	if (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue) {
		Write-Host "Authenticating GitHub CLI"
		gh auth login
	}
	else {
		Write-Warning "GitHub CLI is not available on the current PATH. Open a new PowerShell session and rerun this script to finalize GitHub CLI setup."
	}
}
else {
	Write-Host "Skipping GitHub CLI setup"
}

Write-Host "Finished adding utils and configurations, reload session to see changes"
