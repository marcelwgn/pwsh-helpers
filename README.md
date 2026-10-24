# pwsh-helpers

My personal, highly opinionated collection of PowerShell functions and modules.

## Requirements

PowerShell 7.0 or later.

## Installation

### Full install
```powershell
git clone

cd pwsh-helpers

./initial-pwsh-setup.ps1
```

### Helpers only
```powershell
git clone

cd pwsh-helpers

./build/install-globally.ps1
```

## Scope

This set of helpers mostly focuses on making working with git, GitHub and Azure DevOps easier.
Besides the unix-polyfill, there is also a helper to open specific files more easily from the command line.

The full setup script (`initial-pwsh-setup.ps1`) also deploys the personal GitHub Copilot CLI
instructions from [`./copilot/copilot-instructions.md`](./copilot/copilot-instructions.md) to
`~/.copilot/copilot-instructions.md`, prompting before overwriting an existing file.

For a complete list of available functions and their usage, refer to [`./src/pwsh-helpers.psd1`](./src/pwsh-helpers.psd1) for now.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).