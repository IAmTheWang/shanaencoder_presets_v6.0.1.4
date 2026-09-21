$presets = $PSScriptRoot
Write-Host "=== All folders ==="
Get-ChildItem $presets -Directory | ForEach-Object { Write-Host $_.Name }
