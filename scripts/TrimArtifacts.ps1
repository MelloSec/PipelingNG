$directoryPath = "C:\Devops\Artifacts" # Replace with your directory path
$count = "10"

# Get all folders in the directory, sorted by creation time in descending order
$folders = Get-ChildItem -Path $directoryPath -Directory | Sort-Object CreationTime -Descending

# Skip the first X folders (the most recent ones) and delete the rest
$folders | Select-Object -Skip $count | Remove-Item -Recurse -Force

