#!/usr/bin/env bash
set -eu

# Auto-detect script directory (supports symlinks and being run from any cwd)
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
cd "$SCRIPT_DIR"

DEST="$HOME/.config/DankMaterialShell/plugins/minimaxCodeUsage"

if [ ! -d "$(dirname "$DEST")" ]; then
    echo "Error: DMS config directory not found. Is DMS installed?"
    exit 1
fi

echo "Installing MiniMax Code Usage to $DEST ..."

# Remove old installation
rm -rf "$DEST"

# Create destination
mkdir -p "$DEST"

# Copy all plugin files
find . -mindepth 1 -not -path '*/.git/*' -exec cp -rP {} "$DEST/" \;

# Make script executable
chmod +x "$DEST/get-minimax-usage" 2>/dev/null || true

echo "Done."
echo ""
echo "Create ~/.mmx/config.json with your API key:"
echo '  mkdir -p ~/.mmx'
echo '  echo "{\"api_key\": \"sk-xxxx\"}" > ~/.mmx/config.json'
echo ""
echo "Then restart DMS to load the plugin."
