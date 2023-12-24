param(
    [string]$workingFolder,
    [string]$inputFolder,
    [string]$newProjectFolderName,
    [string]$signatureBinary = "C:\Devops\skavencryptiv\WINWORD.exe",
    [string]$method,
    [string]$outputFolder,
    [switch]$confuser,
    [switch]$xor,
    [string]$key
)

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

try {
    $gitPath = (Get-Command git).Source
    Write-Output "Git is installed. Path: $gitPath"
}
catch {
    Write-Output "Git is not installed. Attempting to install Git."
    Install-Module posh-git -Scope CurrentUser -Force;
    Import-Module posh-git;
    Add-PoshGitToProfile -AllHosts
}


# Function to check file existence
function Check-FileExists($file) {
    if (-not (Test-Path $file)) {
        throw "Required file not found: $file"
    }
}

$isBase64Installed = $false

try {
    $commandInfo = Get-Command base64.exe -ErrorAction Stop
    Write-Output "base64.exe is installed. Path: $($commandInfo.Source)"
    $isBase64Installed = $true
}
catch {
    Write-Output "base64.exe is not installed."
}

$path = $workingFolder
# Check required files
Write-Output "Checking script dependencies."
if(!(Test-Path $path)){ New-Item -ItemType Directory -Path $path -Force }
if(!(Test-Path $path\sigthief.py)){ Invoke-WebRequest https://raw.githubusercontent.com/secretsquirrel/SigThief/master/sigthief.py -o $path\sigthief.py }
if(!(Test-Path $path\cloak.py)){ Invoke-WebRequest https://raw.githubusercontent.com/h4wkst3r/InvisibilityCloak/main/InvisibilityCloak.py -o $path\cloak.py }


# Python
Write-Output "Checking Python dependencies."
$pythonPath = "C:\Python\Python.exe"
$installerUrl = "https://www.python.org/ftp/python/3.12.1/python-3.12.1-amd64.exe"
$installerPath = "C:\temp\python_installer.exe"

if (-not (Test-Path $pythonPath)) {
    if(!(Test-Path C:\temp )) { mkdir C:\temp }
    Write-Output "Python not found. Downloading and installing Python..."

    # Download the installer
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    # Run the installer with silent install flags
    Start-Process -FilePath $installerPath -Args "/quiet InstallAllUsers=1 PrependPath=1 TargetDir=C:\Python" -Wait -NoNewWindow

    # Check again if Python is installed
    if (-not (Test-Path $pythonPath)) {
        throw "Python installation failed."
    } else {
        Write-Output "Python installed successfully."
    }
} else {
    Write-Output "Python is already installed."
}
Check-FileExists "C:\Python\Python.exe"

# Check if the Crypter directory exists
Write-Output "Checking Crypter dependencies."
$destination = "$path\skavencryptiv"
if (!(Test-Path $destination\SkavenCryptCI.ps1)) {
    # Clone the repository
    Write-Output "CD script not found, downloading latest version."
    git clone https://github.com/mellosec/skavencryptIV $destination
}
else{ Write-Output "CD Script found."}

if($xor){ Check-FileExists "$path\SkavenCryptIV\Xorcrypt.exe  "}
if($xor){ Check-FileExists "$path\SkavenCryptIV\Skavencrypt.ps1  "}

# Ensure "Temp" and "Artifacts" directories exist
Write-Output "Preparing folders for processing."
$devopsTempDir = Join-Path $path "Temp"
$devopsArtifactsDir = Join-Path $path "Artifacts"

# Check and remove the existing Temp directory, then create a new one
if (Test-Path $devopsTempDir) {
    Remove-Item -Recurse -Force $devopsTempDir
}
New-Item -ItemType Directory -Path $devopsTempDir -Force

# Check if Artifacts directory exists, if not create a new one
if (-not (Test-Path $devopsArtifactsDir)) {
    New-Item -ItemType Directory -Path $devopsArtifactsDir -Force
}

# Create new build directory inside "Temp"
$date = Get-Date -Format "yyyyMMdd_HHmmss"
$folderName = Split-Path $inputFolder -Leaf
$newDir = Join-Path $devopsTempDir "${date}_${folderName}"
New-Item -ItemType Directory -Path $newDir -Force

# Create new artifacts directory inside "Artifacts"
$artifactsDir = Join-Path $devopsArtifactsDir "artifacts_${date}_${folderName}"
New-Item -ItemType Directory -Path $artifactsDir -Force

# Copy inputFolder to the new build directory
Copy-Item -Path $inputFolder -Destination $newDir -Recurse -Force

# Assuming $workingFolder is the base directory for operations
$date = Get-Date -Format "yyyyMMdd_HHmmss"
$newDir = Join-Path $workingFolder "${date}_${newProjectFolderName}"
New-Item -ItemType Directory -Path $newDir -Force

# Copy inputFolder to newDir
Copy-Item -Path $inputFolder -Destination $newDir -Recurse -Force

# The path to the new project directory
$projectDir = Join-Path $newDir $newProjectFolderName

# Navigate to the project directory
Push-Location $projectDir

# Process each subfolder
Write-Output "Running InvisibilityCloak."
Get-ChildItem -Path $newDir -Directory | ForEach-Object {
    $subFolder = $_.FullName
    $folderName = $_.Name
    $cloakName = "${folderName}_cloak"

    # Run cloak.py
    if($method){
        & "C:\Python\Python.exe" "$path\cloak.py" -d $subFolder -n $cloakName -m $method
    }
    else{
    & "C:\Python\Python.exe" "$path\cloak.py" -d $subFolder -n $cloakName
    }

        # Run dotnet build
        Write-Output "Building project."
        & dotnet build -c release

        # Define build output directory
        $buildOutputDir = Join-Path $subFolder "bin\Release"

        # Search for the main output file (.dll or .exe)
        $mainOutputFile = Get-ChildItem -Path $buildOutputDir -Recurse -Include *.dll, *.exe -File | Select-Object -First 1

        if ($mainOutputFile) {
            # Copy the main output file to the artifacts directory
            Copy-Item -Path $mainOutputFile.FullName -Destination $artifactsDir
        } else {
            Write-Warning "No main output file found in $buildOutputDir"
        }
}

        # Return to the previous directory
        Pop-Location
    # } else {
    #     Write-Warning "Renamed project directory not found in $subFolder"
    # }


# Change directory to the artifacts directory
Push-Location $artifactsDir
ls $artifactsDir

# Check if confuser is required
if ($confuser) {
    # Ensure ConfuserEx CLI is available
    $confuserPath = "$path\ConfuserEx-CLI\Confuser.CLI.exe"
    if (!(Test-Path $confuserPath)) {
        Invoke-WebRequest -Uri "https://github.com/mkaring/ConfuserEx/releases/download/v1.6.0/ConfuserEx-CLI.zip" -OutFile "$path\ConfuserEx-CLI.zip"
        Expand-Archive -Path "$path\ConfuserEx-CLI.zip" -DestinationPath "$path\ConfuserEx-CLI" -Force
    }

    # Specify the path to your ConfuserEx configuration file
    $confuserConfigPath = "$path\SkavenCryptiv\confuser_aggressive.crproj"

    # Run ConfuserEx on each project or file in the artifacts directory
    Get-ChildItem -Path $artifactsDir -Recurse | Where-Object { $_.Extension -match "\.(dll|exe)$" } | ForEach-Object {
        # Modify the configuration file or create a new one dynamically to include the current file/project
        # This step depends on how ConfuserEx configuration works with individual files or projects
        # Assuming $confuserConfigPath is updated or a new config is created for each file/project
        Write-Output "Running ConfuserEX on artifacts.."
        & "$path\ConfuserEx-CLI\Confuser.CLI.exe" -n $confuserConfigPath -o $artifactsDir


    }
}


Write-Output "Running Sigthief."
# Run sigthief.py on each .dll and .exe file in the directory
Get-ChildItem -Path "." -File | Where-Object { $_.Extension -match "\.(dll|exe)$" } | ForEach-Object {
    # Derive the output file name by removing "_cloak"
    $outputFileName = $_.Name -replace "_cloak", ""

    # Run sigthief.py
    
    $signatureBinary = "C:\Devops\skavencryptiv\WINWORD.EXE"
    $sigThiefCmd = & "C:\Python\Python.exe" "$path\sigthief.py" -i $signatureBinary -t $_.FullName -o $outputFileName
    
    # If sigthief.py runs successfully, delete the original file
    if ($sigThiefCmd -notcontains "error") {
        Write-Output "No sigthief errors. Deleting old file."
        Remove-Item $_.FullName -Force
    }
}

# Encrypt and Encode Files
if ($xor) {
    Write-Output "Encrypting and Encoding files."

    Get-ChildItem -Path $artifactsDir -File | Where-Object { $_.Extension -match "\.(dll|exe)$" } | ForEach-Object {
        $originalFile = $_.FullName
        $encryptedFile = "$($_.FullName).enc"
        $encodedOriginalFile = "$($_.BaseName).txt"
        $encodedEncryptedFile = "$($_.BaseName).enc.txt"

        # Encrypt the file
        if(!($key)){$key = "NewMilleniumCyanideChrist"}
        & "$path\SkavenCryptIV\SkavenCryptCI.ps1" encrypt $originalFile $encryptedFile $key xor
        Write-Output "Encrypted file: $encryptedFile"

        # Check if base64.exe is installed before encoding
        if ($isBase64Installed) {
            # Encode the original file
            & base64.exe -e -n 0 -i $originalFile -o $encodedOriginalFile
            Write-Output "Encoded original file: $encodedOriginalFile"

            # Encode the encrypted file
            & base64.exe -e -n 0 -i $encryptedFile -o $encodedEncryptedFile
            Write-Output "Encoded encrypted file: $encodedEncryptedFile"
        } else {
            Write-Output "Skipping base64 step as base64.exe is not installed."
        }
    }
}
else {
    # If not encrypting, just encode the original files
    if ($isBase64Installed) {
        Write-Output "Encoding files..."

        Get-ChildItem -Path $artifactsDir -File | Where-Object { $_.Extension -match "\.(dll|exe)$" } | ForEach-Object {
            $inputFile = $_.FullName
            $outputFile = "$($_.BaseName).txt"

            # Run base64.exe to encode the file
            & base64.exe -e -n 0 -i $inputFile -o $outputFile

            Write-Output "Encoded file: $outputFile"
        }
    }
    else {
        Write-Output "Skipping base64 step..."
    }

    Get-ChildItem -Path $artifactsDir
    Copy-Item -Recurse -Force $artifactsDir\* C:\Payloads


}

# Return to the previous directory
Pop-Location

# List contents of the artifacts directory after running sigthief.py
Write-Host "Contents of the Artifacts Directory after processing:" 

