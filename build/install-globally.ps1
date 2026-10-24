$firstModulePath = ""
# Find the location of the modules
if ($IsMacOs) {
    $firstModulePath = ($env:PSModulePath -split ":" )[0]
}
else {
    $firstModulePath = ($env:PSModulePath -split ';')[0]
}
# Determine install path
$version = (Import-PowerShellDataFile ./src/pwsh-helpers.psd1).ModuleVersion
$moduleInstallPath = "$firstModulePath\pwsh-helpers\" + $version

# Copy the module to the install path
$projectRootDirectory = Split-Path ([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition))
New-Item -Path $moduleInstallPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
Copy-Item -Path (Get-Item -Path "$projectRootDirectory\src\*").FullName -Destination $moduleInstallPath -Recurse -Container -Force

# Add the module to the profile
$lines = @()
(Get-Content -Path $PROFILE) |
ForEach-Object {
    if ($_.Contains("pwsh-helpers.psd1")) {
        $basePath = $_.SubString(0, $_.IndexOf("pwsh-helpers"))
        $lines += $basePath + "pwsh-helpers" + [IO.Path]::DirectorySeparatorChar + $version + [IO.Path]::DirectorySeparatorChar + "pwsh-helpers.psd1'"
    }
    else {
        $lines += $_
    }
}

Set-Content -Path $PROFILE -Value $lines