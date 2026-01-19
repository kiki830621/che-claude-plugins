#!/bin/bash
# Wrapper script to find and execute che-ical-mcp binary
# This allows the plugin to work regardless of where the binary is installed

# Possible installation locations (in priority order)
LOCATIONS=(
    "$HOME/bin/CheICalMCP"
    "/usr/local/bin/che-ical-mcp"
    "/usr/local/bin/CheICalMCP"
    "$HOME/.local/bin/CheICalMCP"
    # MCPB installation location (Claude Desktop)
    "$HOME/Library/Application Support/Claude/mcp-servers/che-ical-mcp/server/CheICalMCP"
)

for loc in "${LOCATIONS[@]}"; do
    if [[ -x "$loc" ]]; then
        exec "$loc" "$@"
    fi
done

# Not found - output error to stderr (MCP protocol requirement)
echo "ERROR: CheICalMCP binary not found!" >&2
echo "Please install from: https://github.com/kiki830621/che-ical-mcp/releases" >&2
exit 1
