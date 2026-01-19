#!/bin/bash
# Check if che-things-mcp is installed and accessible

# Possible installation locations
LOCATIONS=(
    "$HOME/bin/CheThingsMCP"
    "/usr/local/bin/che-things-mcp"
    "/usr/local/bin/CheThingsMCP"
    "$HOME/.local/bin/CheThingsMCP"
)

MCP_FOUND=false
MCP_PATH=""

# First check actual binary paths
for loc in "${LOCATIONS[@]}"; do
    if [[ -x "$loc" ]]; then
        MCP_FOUND=true
        MCP_PATH="$loc"
        break
    fi
done

if [[ "$MCP_FOUND" == "true" ]]; then
    # Get installed version (with 2 second timeout)
    INSTALLED_VERSION=$(timeout 2 "$MCP_PATH" --version 2>/dev/null | awk '{print $NF}' || true)

    if [[ -n "$INSTALLED_VERSION" ]]; then
        echo "✓ che-things-mcp v${INSTALLED_VERSION} installed: $MCP_PATH"
    else
        echo "✓ che-things-mcp installed: $MCP_PATH"
    fi
else
    # Fallback: check if registered via claude mcp
    if command -v claude &> /dev/null; then
        if claude mcp list 2>/dev/null | grep -q "che-things-mcp"; then
            echo "✓ che-things-mcp is registered (via claude mcp)"
            exit 0
        fi
    fi

    echo "⚠️  che-things-mcp not found!"
    echo ""
    echo "To install, run:"
    echo "  mkdir -p ~/bin"
    echo "  curl -L https://github.com/kiki830621/che-things-mcp/releases/latest/download/CheThingsMCP -o ~/bin/CheThingsMCP"
    echo "  chmod +x ~/bin/CheThingsMCP"
    echo "  claude mcp add --scope user che-things-mcp -- ~/bin/CheThingsMCP"
    echo ""
    echo "Or download .mcpb from: https://github.com/kiki830621/che-things-mcp/releases"
fi
