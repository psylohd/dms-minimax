#!/usr/bin/env bash
set -eu

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

# Copy files excluding .git and minimaxCodeUsage subdir
find "$HOME/dev/dms-minimax" -mindepth 1 -not -path '*/.git/*' -not -path '*/minimaxCodeUsage/*' -exec cp -rP {} "$DEST/" \;

# Copy minimaxCodeUsage subdir contents
mkdir -p "$DEST/minimaxCodeUsage"
find "$HOME/dev/dms-minimax/minimaxCodeUsage" -mindepth 1 -exec cp -rP {} "$DEST/minimaxCodeUsage/" \;

# Make script executable
chmod +x "$DEST/minimaxCodeUsage/get-minimax-usage"
chmod +x "$DEST/get-minimax-usage" 2>/dev/null || true

echo "Done."
echo ""
echo "Create ~/.mmx/config.json with your API key:"
echo '  mkdir -p ~/.mmx'
echo '  echo "{\"api_key\": \"sk-xxxx\"}" > ~/.mmx/config.json'
echo ""
echo "Then restart DMS to load the plugin."
