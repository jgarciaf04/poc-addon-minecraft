#!/usr/bin/env bash
# Package behavior_pack/ and resource_pack/ into a .mcaddon file
# Usage: ./package.sh [output_name]
# The .mcaddon file is a zip archive that Minecraft auto-imports when double-clicked

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_NAME="${1:-everything-addon}"
OUTPUT_FILE="${SCRIPT_DIR}/${OUTPUT_NAME}.mcaddon"

# Remove existing output if present
rm -f "$OUTPUT_FILE"

# Create zip containing both pack folders
cd "$SCRIPT_DIR"
zip -r "$OUTPUT_FILE" behavior_pack/ resource_pack/

echo "Created: $OUTPUT_FILE"
echo "Double-click the .mcaddon file to import into Minecraft."
