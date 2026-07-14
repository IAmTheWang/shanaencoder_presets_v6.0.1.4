$presets = 'D:\software\ShanaEncoder v6.0.1.4 免安装版\presets'
Write-Host "=== All folders ==="
Get-ChildItem $presets -Directory | ForEach-Object { Write-Host $_.Name }
