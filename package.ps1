# Package behavior_pack/ and resource_pack/ into a .mcaddon file
# Usage: .\package.ps1 [-OutputName "everything-addon"]

param(
    [string]$OutputName = "everything-addon"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = $PSScriptRoot
$OutputFile = Join-Path $ScriptDir "$OutputName.mcaddon"

# Verify source directories exist
foreach ($dir in @("behavior_pack", "resource_pack")) {
    $fullPath = Join-Path $ScriptDir $dir
    if (-not (Test-Path $fullPath)) {
        Write-Error "Directory not found: $fullPath"
        exit 1
    }
}

# Remove existing output if present
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

# Create archive directly as .mcaddon (zip format)
Compress-Archive -Path (Join-Path $ScriptDir "behavior_pack"), (Join-Path $ScriptDir "resource_pack") -DestinationPath $OutputFile

Write-Host "Created: $OutputFile"
Write-Host "Double-click the .mcaddon file to import into Minecraft."
