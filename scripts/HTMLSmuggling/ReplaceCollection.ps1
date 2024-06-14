param (
    [string]$folderPath,
    [string]$templateFile
)

# Function to process a single file
function Process-File {
    param (
        [string]$inputFile,
        [string]$templateFile,
        [string]$outputFile
    )

    # Read the base64 blob from the input file and remove any extraneous whitespace
    $base64Blob = (Get-Content -Path $inputFile -Raw).Trim()

    # Read the template file
    $templateContent = Get-Content -Path $templateFile -Raw

    # Replace {{{BINARY}}} in the template with the base64 blob
    $outputContent = $templateContent -replace '\{\{\{BINARY\}\}\}', $base64Blob

    # Write the result to the output file
    [System.IO.File]::WriteAllText($outputFile, $outputContent)
}

# Ensure the HTML output directory exists
$htmlOutputDir = ".\HTML"
if (-Not (Test-Path -Path $htmlOutputDir)) {
    New-Item -ItemType Directory -Path $htmlOutputDir | Out-Null
}

# Process each .txt file in the specified folder
$txtFiles = Get-ChildItem -Path $folderPath -Filter *.txt
foreach ($txtFile in $txtFiles) {
    $inputFile = $txtFile.FullName
    $fileNameWithoutExtension = $txtFile.BaseName
    $outputFile = Join-Path -Path $htmlOutputDir -ChildPath "$fileNameWithoutExtension.html"
    Process-File -inputFile $inputFile -templateFile $templateFile -outputFile $outputFile
}
