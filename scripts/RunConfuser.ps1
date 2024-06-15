param (
    [string]$confuserPath = "C:\devops\ConfuserEx-CLI\Confuser.CLI.exe",
    [string]$configPath = ".\confuser_minimum.crproj",
    [string]$folderPath = ".\"
)

# Ensure the Confused output directory exists
$confusedDir = "Confused"
if (-Not (Test-Path -Path $confusedDir)) {
    New-Item -ItemType Directory -Path $confusedDir | Out-Null
}

# Get all .exe and .dll files in the folder
$files = Get-ChildItem -Path $folderPath | Where-Object { $_.Extension -eq ".exe" -or $_.Extension -eq ".dll" }

# Loop through each file and run Confuser CLI with the specified config
foreach ($file in $files) {
    $filePath = $file.FullName
    Write-Output "Processing $filePath"
    & $confuserPath $filePath -o $confusedDir -n $configPath
}

# Encode each .exe and .dll file in the Confused folder to Base64
$confusedFiles = Get-ChildItem -Path $confusedDir | Where-Object { $_.Extension -eq ".exe" -or $_.Extension -eq ".dll" }
foreach ($confusedFile in $confusedFiles) {
    $confusedFilePath = $confusedFile.FullName
    $base64OutputPath = Join-Path -Path $confusedDir -ChildPath "$($confusedFile.BaseName).txt"
    Write-Output "Encoding $confusedFilePath to Base64"
    base64.exe -n 0 -i $confusedFilePath -o $base64OutputPath
    Write-Output "Base64 encoding complete: $base64OutputPath"
}

# Example usage:
# .\RunConfuser.ps1 -confuserPath "C:\devops\ConfuserEx-CLI\Confuser.CLI.exe" -configPath ".\confuser_minimum.crproj" -folderPath ".\"
