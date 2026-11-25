
$target = 'C:/Users/User/AppData/Local/Temp/app_deploy.zip'
if (Test-Path $target) { Remove-Item $target -Force }

$exclude = @('node_modules', '.next', '.git', 'deploy.zip', 'app_deploy.zip', '.cursor')

$items = Get-ChildItem -Path 'c:\Users\User\Downloads\DBC_Revamp - Copy (2)\DBC_Revamp - Copy' | Where-Object { $exclude -notcontains $_.Name } | Select-Object -ExpandProperty FullName

Compress-Archive -Path $items -DestinationPath $target -CompressionLevel Fastest
Write-Host "Created zip, size: $((Get-Item $target).Length)"
