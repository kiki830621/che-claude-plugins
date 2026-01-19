#!/bin/bash
# Wrapper script to find and execute che-word-mcp binary
# This allows the plugin to work regardless of where the binary is installed

# Possible installation locations (in priority order)
LOCATIONS=(
    "$HOME/bin/CheWordMCP"
    "/usr/local/bin/che-word-mcp"
    "/usr/local/bin/CheWordMCP"
    "$HOME/.local/bin/CheWordMCP"
)

for loc in "${LOCATIONS[@]}"; do
    if [[ -x "$loc" ]]; then
        exec "$loc" "$@"
    fi
done

# Not found - output error to stderr (MCP protocol requirement)
echo "ERROR: CheWordMCP binary not found!" >&2
echo "Please build and install from: /path/to/che-word-mcp" >&2
echo "  swift build -c release" >&2
echo "  cp .build/release/CheWordMCP ~/bin/" >&2
exit 1
