#!/bin/bash
# Check if che-ical-mcp is installed and accessible

# Possible installation locations
LOCATIONS=(
    "$HOME/bin/CheICalMCP"
    "/usr/local/bin/che-ical-mcp"
    "/usr/local/bin/CheICalMCP"
    "$HOME/.local/bin/CheICalMCP"
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
    # Get installed version
    INSTALLED_VERSION=$("$MCP_PATH" --version 2>/dev/null | awk '{print $NF}')

    if [[ -n "$INSTALLED_VERSION" ]]; then
        echo "✓ che-ical-mcp v${INSTALLED_VERSION} installed: $MCP_PATH"
    else
        echo "✓ che-ical-mcp is installed: $MCP_PATH"
    fi
else
    # Fallback: check if registered via claude mcp
    if command -v claude &> /dev/null; then
        if claude mcp list 2>/dev/null | grep -q "che-ical-mcp"; then
            echo "✓ che-ical-mcp is registered (via claude mcp)"
            exit 0
        fi
    fi

    echo "⚠️  che-ical-mcp not found!"
    echo ""
    echo "To install, run:"
    echo "  mkdir -p ~/bin"
    echo "  curl -L https://github.com/kiki830621/che-ical-mcp/releases/latest/download/CheICalMCP -o ~/bin/CheICalMCP"
    echo "  chmod +x ~/bin/CheICalMCP"
    echo "  claude mcp add --scope user che-ical-mcp -- ~/bin/CheICalMCP"
    echo ""
    echo "Or download .mcpb from: https://github.com/kiki830621/che-ical-mcp/releases"
fi
