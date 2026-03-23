#!/bin/sh

PORT="${PORT:-8080}"
CONFIG_FILE="${MCP_CONFIG_FILE:-/default-servers.json}"
MCP_CORS="${MCP_CORS_ORIGIN:-*}"

# Fix volume permissions (non-fatal)
if [ -d /data ]; then
  chmod -R 777 /data/memory 2>/dev/null || true
fi

echo "Starting MCP Proxy Gateway"
echo "  Port: ${PORT}"
echo "  Config: ${CONFIG_FILE}"
echo ""

echo "Endpoints:"
echo "  Status:  http://0.0.0.0:${PORT}/status"

# Parse server names from config and print endpoints (non-fatal)
if command -v python3 > /dev/null 2>&1; then
  GATEWAY_PORT="${PORT}" python3 -c "
import json, os
port = os.environ['GATEWAY_PORT']
with open('${CONFIG_FILE}') as f:
    cfg = json.load(f)
for name in cfg.get('mcpServers', {}):
    print(f'  {name}:  http://0.0.0.0:{port}/servers/{name}/sse')
" 2>/dev/null || true
fi

echo ""
echo "Starting proxy..."

# Use exec with explicit args array to avoid shell glob expansion of * in --allow-origin
exec catatonit -- mcp-proxy \
  --host 0.0.0.0 \
  --port "${PORT}" \
  --named-server-config "${CONFIG_FILE}" \
  --pass-environment \
  --allow-origin "${MCP_CORS}"
