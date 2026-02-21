# Package behavior_pack/ and resource_pack/ into a .mcaddon file
# Usage: .\package.ps1 [-OutputName "everything-addon"]

param(
    [string]$OutputName = "everything-addon"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputFile = Join-Path $ScriptDir "$OutputName.mcaddon"

# Remove existing output if present
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile
}

# Create zip containing both pack folders
$tempZip = Join-Path $ScriptDir "$OutputName.zip"
Compress-Archive -Path (Join-Path $ScriptDir "behavior_pack"), (Join-Path $ScriptDir "resource_pack") -DestinationPath $tempZip
Rename-Item $tempZip $OutputFile

Write-Host "Created: $OutputFile"
Write-Host "Double-click the .mcaddon file to import into Minecraft."
