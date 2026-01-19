#!/bin/bash
# Wrapper script to find and execute che-things-mcp binary
# This allows the plugin to work regardless of where the binary is installed

# Possible installation locations (in priority order)
LOCATIONS=(
    "$HOME/bin/CheThingsMCP"
    "/usr/local/bin/che-things-mcp"
    "/usr/local/bin/CheThingsMCP"
    "$HOME/.local/bin/CheThingsMCP"
    # MCPB installation location (Claude Desktop)
    "$HOME/Library/Application Support/Claude/mcp-servers/che-things-mcp/server/CheThingsMCP"
)

for loc in "${LOCATIONS[@]}"; do
    if [[ -x "$loc" ]]; then
        exec "$loc" "$@"
    fi
done

# Not found - output error to stderr (MCP protocol requirement)
echo "ERROR: CheThingsMCP binary not found!" >&2
echo "Please install from: https://github.com/kiki830621/che-things-mcp/releases" >&2
exit 1
