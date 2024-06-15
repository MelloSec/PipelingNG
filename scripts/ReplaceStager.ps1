param (
    [string]$url,
    [string]$zipName,
    [string]$exeName
)

# Read the template content
$templatePath = ".\StagerTemplate.ps1"
$templateContent = Get-Content -Path $templatePath -Raw

# Replace the placeholders with the actual values
$replacedContent = $templateContent -replace "\{\{\{URL\}\}\}", [RegEx]::Escape($url)
$replacedContent = $replacedContent -replace "\{\{\{ZIPNAME\}\}\}", [RegEx]::Escape($zipName)
$replacedContent = $replacedContent -replace "\{\{\{EXENAME\}\}\}", [RegEx]::Escape($exeName)

# Save the replaced content as Stager.ps1
$outputPath = ".\Stager.ps1"
Set-Content -Path $outputPath -Value $replacedContent

Write-Output "Stager.ps1 has been created with the provided parameters."
