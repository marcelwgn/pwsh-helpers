# List style prediction
Set-PSReadLineOption -PredictionViewStyle ListView -HistoryNoDuplicates -PredictionSource HistoryAndPlugin

# Posh git
Import-Module posh-git

# Increased history count
Set-Variable MaximumHistoryCount 32767
