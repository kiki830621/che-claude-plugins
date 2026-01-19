#!/bin/bash
# Wrapper script to find and execute che-duckdb-mcp binary
# This allows the plugin to work regardless of where the binary is installed

# Possible installation locations (in priority order)
LOCATIONS=(
    "$HOME/bin/CheDuckDBMCP"
    "/usr/local/bin/che-duckdb-mcp"
    "/usr/local/bin/CheDuckDBMCP"
    "$HOME/.local/bin/CheDuckDBMCP"
)

for loc in "${LOCATIONS[@]}"; do
    if [[ -x "$loc" ]]; then
        exec "$loc" "$@"
    fi
done

# Not found - output error to stderr (MCP protocol requirement)
echo "ERROR: CheDuckDBMCP binary not found!" >&2
echo "Please build and install from: /path/to/che-duckdb-mcp" >&2
echo "  swift build -c release" >&2
echo "  cp .build/release/CheDuckDBMCP ~/bin/" >&2
exit 1
