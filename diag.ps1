$presets = 'D:\software\ShanaEncoder v6.0.1.4 免安装版\presets'
Get-ChildItem $presets | Where-Object { $_.Name -match 'qsv|Qsv|QSV' } | Select-Object FullName
Write-Host "---3ya folders---"
Get-ChildItem $presets | Where-Object { $_.Name -match '3' } | Select-Object FullName
Write-Host "---FastSameAudio check---"
Get-ChildItem "$presets\0cpuQualityGpt5.3CodexFastSameAudio" -ErrorAction SilentlyContinue | Select-Object Name
