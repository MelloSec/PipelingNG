param (
    [string]$filePath,
    [switch]$sigthief
)

# Define necessary paths
$path = "C:\devops"
$confuserPath = "$path\ConfuserEx-CLI\Confuser.CLI.exe"
$confuserConfigPath = "$path\SkavenCryptiv\confuser_aggressive.crproj"

# Download and extract ConfuserEx if not present
if (!(Test-Path $confuserPath)) {
    Invoke-WebRequest -Uri "https://github.com/mkaring/ConfuserEx/releases/download/v1.6.0/ConfuserEx-CLI.zip" -OutFile "$path\ConfuserEx-CLI.zip"
    Expand-Archive -Path "$path\ConfuserEx-CLI.zip" -DestinationPath "$path\ConfuserEx-CLI" -Force
}

# Run ConfuserEx on the specified file
Write-Output "Running ConfuserEx on $filePath"
& "$confuserPath" -n $confuserConfigPath -o $filePath

# Sigthief processing
if ($sigthief) {
    Write-Output "Running Sigthief."
    $outputFileName = $filePath -replace "_cloak", ""
    $signatureBinary = "$path\skavencryptiv\WINWORD.EXE"
    $sigThiefCmd = & "C:\Python\Python.exe" "$path\sigthief.py" -i $signatureBinary -t $filePath -o $outputFileName
    
    if ($sigThiefCmd -notcontains "error") {
        Write-Output "No Sigthief errors. Deleting old file."
        Remove-Item $filePath -Force
    }
}

# XOR Encryption and Base64 Encoding
$key = "NewMilleniumCyanideChrist"
$encryptedFile = "$filePath.enc"
$encodedOriginalFile = "$filePath.txt"
$encodedEncryptedFile = "$encryptedFile.txt"

# Encrypt the file
Write-Output "Encrypting file: $filePath"
& "$path\SkavenCryptIV\SkavenCryptCI.ps1" encrypt $filePath $encryptedFile $key xor

# Check if base64.exe is installed before encoding
$isBase64Installed = Test-Path "C:\Program Files\base64.exe"
if ($isBase64Installed) {
    # Encode the original file
    & "C:\Program Files\base64.exe" -e -n 0 -i $filePath -o $encodedOriginalFile
    Write-Output "Encoded original file: $encodedOriginalFile"

    # Encode the encrypted file
    & "C:\Program Files\base64.exe" -e -n 0 -i $encryptedFile -o $encodedEncryptedFile
    Write-Output "Encoded encrypted file: $encodedEncryptedFile"
} else {
    Write-Output "base64.exe is not installed. Skipping encoding step."
}
