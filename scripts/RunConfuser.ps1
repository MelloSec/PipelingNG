param (
    [string]$confuserPath = "C:\devops\ConfuserEx-CLI\Confuser.CLI.exe",
    [string]$configPath = ".\confuser_minimum.crproj",
    [string]$folderPath = ".\"
)

# Get all .exe and .dll files in the folder
$files = Get-ChildItem -Path $folderPath | Where-Object { $_.Extension -eq ".exe" -or $_.Extension -eq ".dll" }

# Loop through each file and run Confuser CLI with the specified config
foreach ($file in $files) {
    $filePath = $file.FullName
    Write-Output "Processing $filePath"
    & $confuserPath $filePath -o Confused -n $configPath
}

# ex
# .\RunConfuser.ps1 -confuserPath C:\devops\ConfuserEx-CLI\Confuser.CLI.exe 