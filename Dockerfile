FROM ghcr.io/sparfenyuk/mcp-proxy:latest

USER root

# Install Node.js for npm-based MCP servers
RUN apk add --no-cache nodejs npm

# Install MCP servers: fetch (Python/pip), memory + sequential-thinking (npm)
RUN pip install --no-cache-dir mcp-server-fetch && \
    npm install -g \
    @modelcontextprotocol/server-memory \
    @modelcontextprotocol/server-sequential-thinking

# Create data directory for memory server persistence
RUN mkdir -p /data/memory && chmod 777 /data/memory

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY servers.json /default-servers.json

ENTRYPOINT ["/entrypoint.sh"]
