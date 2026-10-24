# Check if module "pwsh-helpers" is loaded
if (Get-Module pwsh-helpers) {
	Remove-Module "pwsh-helpers"
}
Import-Module ./src/pwsh-helpers.psm1