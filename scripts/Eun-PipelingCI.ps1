$dotnetFolder = ".\ondeck\"
$workingFolder = "C:\Devops"
$signatureBinary = "$workingFolder\skavencryptiv\WINWORD.exe" # Adjust this path as necessary
$method = "rot13" # String obfuscation method
$confuser = $true # Run confuser with 'aggressive' preset
$xor = $true 
$key = "NewMilleniumCyanideChrist" # XOR key


# Iterate through each folder in the .\dotnet directory
Get-ChildItem -Path $dotnetFolder -Directory | ForEach-Object {
    $proj = Join-Path $dotnetFolder $_.Name
    $projName = $_.Name

    $params = @{
        newProjectFolderName = $projName
        workingFolder = $workingFolder    
        inputFolder = $proj
        signatureBinary = $signatureBinary
        method = $method
        confuser = $confuser
        xor = $xor 
        key = $key
        sigthief = $false
    }

    # Run PipelingNG.ps1 script with parameters
    .\PipelingNG\PipelingCI.ps1 @params
}