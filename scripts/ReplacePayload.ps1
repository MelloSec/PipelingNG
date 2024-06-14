param (
    [string]$inputFile,
    [string]$templateFile,
    [string]$outputFile
)

# Ensure the HTML output directory exists
$htmlOutputDir = (Get-Item $outputFile).DirectoryName
if (-Not (Test-Path -Path $htmlOutputDir)) {
    New-Item -ItemType Directory -Path $htmlOutputDir | Out-Null
}

# Read the base64 blob from the input file and remove any extraneous whitespace
$base64Blob = (Get-Content -Path $inputFile -Raw).Trim()

# Read the template file
$templateContent = Get-Content -Path $templateFile -Raw

# Replace {{{BINARY}}} in the template with the base64 blob
$outputContent = $templateContent -replace '\{\{\{BINARY\}\}\}', $base64Blob

# Write the result to the output file
$outputContent | Set-Content -Path $outputFile

# Example usage:
# .\ReplacePayload.ps1 -inputFile ".\Confused\Tokenvator.exe.txt" -templateFile ".\template.html" -outputFile .\HTML\tokenvator.html
