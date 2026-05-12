# Claude Code - MCP Integration Reference

## Overview

Claude Code connects to external tools and data sources through the Model Context Protocol (MCP), an open standard for AI-tool integrations. MCP servers give Claude Code access to tools, databases, and APIs.

## Transport Types

| Transport | Description | Usage |
|-----------|-------------|-------|
| HTTP (Streamable) | Recommended for cloud services | `claude mcp add --transport http <name> <url>` |
| SSE | Server-Sent Events (deprecated) | `claude mcp add --transport sse <name> <url>` |
| stdio | Local processes | `claude mcp add --transport stdio <name> -- <command> [args]` |

## Installing MCP Servers

### Remote HTTP Server (Recommended)
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp

# With Bearer token
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

### Remote SSE Server (Deprecated)
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

### Local stdio Server
```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**Option ordering**: All options must come before the server name. `--` separates server name from command/args.

### From JSON Configuration
```bash
claude mcp add-json weather-api '{"type":"http","url":"https://api.weather.com/mcp","headers":{"Authorization":"Bearer token"}}'
```

### Import from Claude Desktop
```bash
claude mcp add-from-claude-desktop
```

## Managing Servers

```bash
claude mcp list          # List all configured servers
claude mcp get github    # Get details for a server
claude mcp remove github # Remove a server
/mcp                     # Check status within Claude Code
```

## Scopes

| Scope | Storage | Shared | Description |
|-------|---------|--------|-------------|
| local (default) | `~/.claude.json` | No | Personal, current project only |
| project | `.mcp.json` in project root | Yes (git) | Team-shared |
| user | `~/.claude.json` | No | All your projects |

```bash
claude mcp add --scope local ...    # Default
claude mcp add --scope project ...  # Shared via git
claude mcp add --scope user ...     # Cross-project
```

Precedence: local > project > user

## OAuth Authentication

```bash
# Add server requiring OAuth
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp

# Authenticate within Claude Code
> /mcp
# Follow browser login flow
```

### Pre-configured OAuth Credentials

```bash
claude mcp add --transport http \
  --client-id your-client-id --client-secret --callback-port 8080 \
  my-server https://mcp.example.com/mcp
```

## Environment Variable Expansion in .mcp.json

Supported syntax:
- `${VAR}` - expand variable
- `${VAR:-default}` - expand with default

Works in: `command`, `args`, `env`, `url`, `headers`

```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

## Using Claude Code as MCP Server

```bash
claude mcp serve
```

Claude Desktop configuration:
```json
{
  "mcpServers": {
    "claude-code": {
      "type": "stdio",
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

## MCP Tool Search

Automatically enabled when MCP tool descriptions exceed 10% of context window.

| ENABLE_TOOL_SEARCH | Behavior |
|--------------------|----------|
| `auto` (default) | Activates at 10% context threshold |
| `auto:<N>` | Custom threshold percentage |
| `true` | Always enabled |
| `false` | Disabled, all tools loaded upfront |

Requires Sonnet 4+ or Opus 4+ models.

## MCP Resources

Reference MCP resources via @ mentions:
```
> Can you analyze @github:issue://123 and suggest a fix?
> Compare @postgres:schema://users with @docs:file://database/user-model
```

## MCP Prompts as Commands

```
> /mcp__github__list_prs
> /mcp__github__pr_review 456
> /mcp__jira__create_issue "Bug in login flow" high
```

## Output Limits

- Warning threshold: 10,000 tokens
- Default max: 25,000 tokens
- Configurable: `MAX_MCP_OUTPUT_TOKENS=50000`

## Managed MCP Configuration

### Option 1: Exclusive Control (managed-mcp.json)

Deploy to system directories. Users cannot add/modify MCP servers.

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "company-internal": {
      "type": "stdio",
      "command": "/usr/local/bin/company-mcp-server",
      "args": ["--config", "/etc/company/mcp-config.json"]
    }
  }
}
```

### Option 2: Policy-Based (Allowlists/Denylists)

In managed-settings.json:

```json
{
  "allowedMcpServers": [
    { "serverName": "github" },
    { "serverCommand": ["npx", "-y", "@modelcontextprotocol/server-filesystem"] },
    { "serverUrl": "https://mcp.company.com/*" }
  ],
  "deniedMcpServers": [
    { "serverName": "dangerous-server" },
    { "serverUrl": "https://*.untrusted.com/*" }
  ]
}
```

Denylist always takes precedence over allowlist.

## Plugin-Provided MCP Servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`:

```json
{
  "database-tools": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": { "DB_URL": "${DB_URL}" }
  }
}
```

## Dynamic Tool Updates

Claude Code supports MCP `list_changed` notifications, allowing servers to dynamically update available tools without reconnection.
