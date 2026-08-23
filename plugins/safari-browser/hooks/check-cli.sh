#!/bin/bash
# Check if safari-browser CLI is installed

BINARY_NAME="safari-browser"
INSTALL_PATH="$HOME/bin/$BINARY_NAME"
SOURCE_DIR="$HOME/Developer/safari-browser"

if [[ -x "$INSTALL_PATH" ]]; then
    echo "✓ $BINARY_NAME installed: $INSTALL_PATH"
else
    echo "⚠️  $BINARY_NAME not found at $INSTALL_PATH"
    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "   Clone first:"
        echo "     git clone git@github.com:PsychQuant/safari-browser.git $SOURCE_DIR"
    fi
    echo "   Then, in $SOURCE_DIR:"
    echo "     make install                                  # ad-hoc signed"
    echo "     DEVELOPER_ID=<cert-sha1> make install-signed   # Developer ID signed"
    echo "   Use install-signed if you want history / bookmarks / cloud-tabs /"
    echo "   downloads: those need Full Disk Access, and an ad-hoc grant stops"
    echo "   applying after every rebuild (safari-browser#119)."
fi
