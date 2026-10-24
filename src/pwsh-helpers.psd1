@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'pwsh-helpers.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = 'dab267da-5a2c-4b43-b7a7-f72eacbe418c'

    # Author of this module
    Author            = 'Marcel Wagner'

    # Company or vendor of this module
    CompanyName       = ''

    # Copyright statement for this module
    Copyright         = '(c) 2026 Marcel Wagner'

    # Description of the functionality provided by this module
    Description       = 'PowerShell helpers by Marcel "marcelwgn" Wagner'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '7.0'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        "GitAdd", "GitCommit", "GitPush", "GitPull", "GitUpdate", "GitMergeMain", "GitAddCommitPush", "GitAddCommitPushNoVerify", "GitCheckoutDefaultBranch", "GitFeatureBranch", "GitFeatureBranchUser", "GitCleanLocalOnlyBranches" # Git helpers
        "Show-GitRepoWebsite", "Show-GitBranchWebsite", "Show-GitCommitWebsite", # Git repo/website helpers 
        "Show-GitHubCommitStatusChecks", "Show-GitHubPr", # GitHub helpers
        "New-AdoPr", # ADO helpers
        "Find-InHistory", "Open-FileInTool", # Utils
        "Show-EnvironmentVariables" # Unix polyfills
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @(
        "gad", "gum", "gco", "gpsh", "gpl", "gacp", "gacpn", "gup", "gmm", "gfb", "gfbu", "gclob"
        "sgr", "sgb", "sgc", 
        "sghc", "sghpr",
        "napr",
        "fih", "open",
        "printenv"
    )
    PrivateData       = @{
        PSData = @{
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}