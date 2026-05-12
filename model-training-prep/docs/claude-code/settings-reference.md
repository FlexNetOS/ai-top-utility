# Claude Code - Complete Settings Reference

## Configuration Hierarchy (Highest to Lowest Precedence)

| Scope | Location | Who it affects | Shared? |
|-------|----------|----------------|---------|
| Managed | System-level `managed-settings.json` | All users on machine | Yes (IT deployed) |
| Command line | CLI arguments | Current session | No |
| Local | `.claude/*.local.*` files | You, in this repo only | No (gitignored) |
| Project | `.claude/` in repository | All collaborators | Yes (committed) |
| User | `~/.claude/` directory | You, across all projects | No |

### File Locations

| File | Location | Scope | Purpose |
|------|----------|-------|---------|
| `settings.json` | `~/.claude/` | User | Global settings |
| `settings.json` | `.claude/` | Project | Team-shared settings |
| `settings.local.json` | `.claude/` | Local | Personal project overrides |
| `managed-settings.json` | System dirs | Managed | Organization-wide policies |
| `managed-mcp.json` | System dirs | Managed | Managed MCP configuration |
| `~/.claude.json` | User home | User | Preferences, OAuth, MCP servers |
| `.mcp.json` | Project root | Project | Project-scoped MCP servers |
| `CLAUDE.md` | Various | Multiple | Memory files with instructions |

System directories:
- macOS: `/Library/Application Support/ClaudeCode/`
- Linux/WSL: `/etc/claude-code/`
- Windows: `C:\Program Files\ClaudeCode\`

## Settings Schema

### Permissions

```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)", "Read(~/.zshrc)"],
    "ask": ["Bash(git push *)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits",
    "disableBypassPermissionsMode": "disable"
  }
}
```

| Setting | Type | Description |
|---------|------|-------------|
| `allow` | String[] | Permission rules to allow tool use |
| `ask` | String[] | Rules requiring confirmation |
| `deny` | String[] | Rules to block tool use |
| `additionalDirectories` | String[] | Additional working directories |
| `defaultMode` | String | `acceptEdits`, `askAlways`, `bypassPermissions` |
| `disableBypassPermissionsMode` | String | Set to `"disable"` to prevent bypassing |

### Permission Rule Syntax

Rules follow format: `Tool` or `Tool(specifier)`

| Pattern | Effect | Example |
|---------|--------|---------|
| `Tool` | Matches all uses | `Bash` |
| `Tool(pattern *)` | Wildcard matching | `Bash(npm run *)` |
| `Read(path)` | File read ops | `Read(./.env)` |
| `Edit(path)` | File write ops | `Edit(./src/**)` |
| `WebFetch(domain:X)` | Network requests | `WebFetch(domain:github.com)` |
| `MCP(server.tool)` | MCP tool access | `MCP(github.search_repos)` |
| `Task(type:name)` | Task execution | `Task(type:deployment)` |

Evaluation order: deny -> ask -> allow (first match wins)

### Model & API Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `model` | String | `claude-sonnet-4-5-20250929` | Override default model |
| `apiKeyHelper` | String | -- | Script to generate auth value |
| `otelHeadersHelper` | String | -- | Script for OTel headers |

### Environment Variables

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "FOO": "bar"
  }
}
```

### Session & Cleanup

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `cleanupPeriodDays` | Number | 30 | Delete inactive sessions after N days |
| `plansDirectory` | String | `~/.claude/plans` | Where plan files are stored |

### UI & Display

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `outputStyle` | String | -- | Output style adjustment |
| `showTurnDuration` | Boolean | true | Show turn duration messages |
| `spinnerVerbs` | Object | -- | Customize spinner verbs |
| `spinnerTipsEnabled` | Boolean | true | Show spinner tips |
| `terminalProgressBarEnabled` | Boolean | true | Terminal progress bar |
| `prefersReducedMotion` | Boolean | false | Reduce animations |
| `language` | String | -- | Response language preference |

### Login & Auth

| Setting | Type | Description |
|---------|------|-------------|
| `forceLoginMethod` | String | `claudeai` or `console` |
| `forceLoginOrgUUID` | String | Auto-select org by UUID |

### Advanced Features

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `alwaysThinkingEnabled` | Boolean | false | Extended thinking by default |
| `respectGitignore` | Boolean | true | `@` picker respects gitignore |
| `autoUpdatesChannel` | String | `"latest"` | `"stable"` or `"latest"` |
| `teammateMode` | String | `"auto"` | `auto`, `in-process`, `tmux` |

### Git Attribution

```json
{
  "attribution": {
    "commit": "Co-Authored-By: Claude <noreply@anthropic.com>",
    "pr": "Generated with Claude Code"
  }
}
```

### Sandbox Configuration

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker", "git"],
    "allowUnsandboxedCommands": true,
    "network": {
      "allowUnixSockets": ["~/.ssh/agent-socket"],
      "allowAllUnixSockets": false,
      "allowLocalBinding": true,
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "httpProxyPort": 8080,
      "socksProxyPort": 8081
    },
    "enableWeakerNestedSandbox": false
  }
}
```

### MCP Server Settings

| Setting | Type | Description |
|---------|------|-------------|
| `enableAllProjectMcpServers` | Boolean | Auto-approve all `.mcp.json` servers |
| `enabledMcpjsonServers` | String[] | Specific servers to approve |
| `disabledMcpjsonServers` | String[] | Specific servers to reject |

### Plugin Configuration

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": true
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/claude-plugins" }
    }
  }
}
```

### Hooks

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "./validate.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "./lint.sh" }] }
    ]
  }
}
```

## Environment Variables Reference

### Authentication

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | API key for Claude SDK |
| `ANTHROPIC_AUTH_TOKEN` | Custom Authorization header |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom headers (newline-separated) |
| `ANTHROPIC_FOUNDRY_API_KEY` | Microsoft Foundry API key |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry base URL |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key |
| `MCP_CLIENT_SECRET` | OAuth client secret for MCP |
| `MCP_OAUTH_CALLBACK_PORT` | Fixed OAuth callback port |

### Model Configuration

| Variable | Purpose | Default |
|----------|---------|---------|
| `ANTHROPIC_MODEL` | Model name | `claude-sonnet-4-5-20250929` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Haiku-class model | -- |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sonnet-class model | -- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opus-class model | -- |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents | -- |
| `CLAUDE_CODE_EFFORT_LEVEL` | Effort level (Opus 4.6+) | `high` |
| `MAX_THINKING_TOKENS` | Extended thinking budget | 31,999 |
| `DISABLE_PROMPT_CACHING` | Disable caching | -- |

### Bash & Execution

| Variable | Purpose |
|----------|---------|
| `BASH_DEFAULT_TIMEOUT_MS` | Default bash timeout |
| `BASH_MAX_TIMEOUT_MS` | Maximum timeout |
| `BASH_MAX_OUTPUT_LENGTH` | Max output chars before truncation |
| `CLAUDE_CODE_SHELL` | Override shell detection |
| `CLAUDE_CODE_SHELL_PREFIX` | Prefix for all bash commands |

### Performance

| Variable | Purpose | Default |
|----------|---------|---------|
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens | 32,000 |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Auto-compaction threshold | 95% |
| `ENABLE_TOOL_SEARCH` | MCP tool search | `auto` |
| `MAX_MCP_OUTPUT_TOKENS` | Max MCP tool output | 25,000 |
| `MCP_TIMEOUT` | MCP startup timeout (ms) | -- |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout (ms) | -- |

### Features

| Variable | Purpose |
|----------|---------|
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams |
| `CLAUDE_CODE_ENABLE_TASKS` | Enable task tracking |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks |

### Proxy

| Variable | Purpose |
|----------|---------|
| `HTTP_PROXY` | HTTP proxy server |
| `HTTPS_PROXY` | HTTPS proxy server |
| `NO_PROXY` | Bypass proxy for these hosts |

## Example: Current System Configuration

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "respectGitignore": true,
  "cleanupPeriodDays": 30,
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_EFFORT_LEVEL": "high",
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "64000",
    "CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE": "60",
    "BASH_DEFAULT_TIMEOUT_MS": "120000",
    "BASH_MAX_TIMEOUT_MS": "600000"
  },
  "attribution": {
    "commit": "Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>",
    "pr": ""
  },
  "permissions": {
    "allow": [
      "Bash(git *)", "Bash(npm *)", "Bash(podman *)",
      "Bash(kubectl *)", "Bash(systemctl *)",
      "Read(~/.claude/**)", "Read(~/CLAUDE.md)"
    ],
    "deny": [
      "Read(./.env)", "Read(./.env.*)",
      "Read(./secrets/**)", "Read(**/.env)", "Read(**/secrets/**)"
    ],
    "defaultMode": "acceptEdits",
    "additionalDirectories": [
      "~/Documents/Sull-AI-DevOps/", "~/Documents/openclaw/",
      "~/os-recall/", "~/OpenMemory/",
      "~/memU/", "~/memU-server/", "~/memU-ui/",
      "~/turbo-flow-claude/"
    ]
  },
  "model": "claude-opus-4-6",
  "enableAllProjectMcpServers": true,
  "language": "english",
  "sandbox": {
    "enabled": false,
    "allowUnsandboxedCommands": true,
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org", "*.anthropic.com", "localhost", "127.0.0.1"],
      "allowAllUnixSockets": true,
      "allowLocalBinding": true
    }
  },
  "mcpServers": {
    "vibe_kanban": {
      "command": "npx",
      "args": ["-y", "vibe-kanban@latest", "--mcp"]
    }
  },
  "alwaysThinkingEnabled": true,
  "effortLevel": "high"
}
```
