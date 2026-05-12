# OpenCode - Documentation Overview

**Repository**: https://github.com/anomalyco/opencode
**Website**: https://opencode.ai
**npm Package**: opencode-ai
**Purpose**: Open source AI coding agent (TUI + Desktop + client/server)
**Language**: TypeScript (Bun monorepo)
**License**: MIT
**Version on this system**: v1.1.59
**Collected**: 2026-02-13

---

## 1. Purpose

OpenCode is an open source AI coding agent built for the terminal. It is provider-agnostic, supporting Claude, OpenAI, Google, local models (Ollama, LM Studio, llama.cpp), and 75+ other LLM providers. It features a rich TUI interface, built-in LSP support, a client/server architecture, MCP integration, and two built-in agents (build and plan).

Key differentiators from Claude Code:
- 100% open source
- Not coupled to any provider (provider-agnostic)
- Out-of-the-box LSP support
- Focus on TUI (built by neovim users / terminal.shop creators)
- Client/server architecture (drive from mobile, web, or other clients)

---

## 2. Installation

```bash
# Quick install
curl -fsSL https://opencode.ai/install | bash

# Package managers
npm i -g opencode-ai@latest
brew install anomalyco/tap/opencode   # macOS/Linux (recommended)
sudo pacman -S opencode               # Arch Linux
scoop install opencode                # Windows
choco install opencode                # Windows
mise use -g opencode                  # Any OS
nix run nixpkgs#opencode              # Nix

# Desktop app (beta)
brew install --cask opencode-desktop  # macOS
# Also: .deb, .rpm, AppImage for Linux
```

### Installation Directory Priority
1. `$OPENCODE_INSTALL_DIR` - Custom path
2. `$XDG_BIN_DIR` - XDG-compliant path
3. `$HOME/bin` - Standard user bin
4. `$HOME/.opencode/bin` - Default fallback

---

## 3. Configuration

### File Format & Locations

OpenCode uses **JSON/JSONC** config files with merge semantics (later overrides conflicting keys).

**Precedence order** (lowest to highest):
1. Remote config (`.well-known/opencode`)
2. Global config (`~/.config/opencode/opencode.json`)
3. Custom config (`OPENCODE_CONFIG` env var)
4. Project config (`opencode.json` in project root)
5. `.opencode/` directories
6. Inline config (`OPENCODE_CONFIG_CONTENT` env var)

### Core Configuration Options

```jsonc
{
  // Primary model
  "model": "anthropic/claude-opus-4-6",

  // Lightweight model for titles, summaries
  "small_model": "anthropic/claude-haiku-4-5-20251001",

  // Default agent
  "default_agent": "build",

  // Auto-update: true, false, or "notify"
  "autoupdate": "notify",

  // Theme
  "theme": "opencode",

  // Provider settings
  "provider": {
    "timeout": 300000,
    "setCacheKey": true
  },

  // Tools management (disable specific tools)
  "tools": {
    "write": true,
    "bash": true
  },

  // MCP servers
  "mcp": {
    "servers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"]
      }
    }
  },

  // Custom commands
  "command": {
    "deploy": {
      "description": "Deploy to production",
      "command": "bash deploy.sh"
    }
  },

  // Keybinds
  "keybinds": {},

  // Code formatter
  "formatter": "prettier",

  // Permission mode
  "permission": "ask",

  // Context compaction
  "compaction": {
    "mode": "auto",
    "reserved": 4096
  },

  // File watcher ignore patterns
  "watcher": {
    "ignore": ["node_modules", ".git"]
  },

  // Instructions / rules files
  "instructions": ["AGENTS.md"],

  // Plugins
  "plugin": [],

  // Provider allow/block lists
  "enabled_providers": [],
  "disabled_providers": [],

  // Sharing
  "share": "manual",

  // Experimental features
  "experimental": {}
}
```

### TUI Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `scroll_speed` | 3 | Scroll multiplier (min: 1) |
| `scroll_acceleration.enabled` | false | macOS-style acceleration |
| `diff_style` | `"auto"` | Diff rendering: `"auto"` or `"stacked"` |

### Server Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `port` | auto | Listen port |
| `hostname` | auto | Listen address |
| `mdns` | false | mDNS service discovery |
| `mdnsDomain` | - | Custom mDNS domain |
| `cors` | - | Allowed CORS origins |

### Variable Substitution

- Environment variables: `{env:VARIABLE_NAME}`
- File contents: `{file:path/to/file}`

### Config Subdirectories

Both `~/.config/opencode/` and `.opencode/` support:
```
agents/    - Custom agent definitions
commands/  - Custom commands
modes/     - Custom modes
plugins/   - Custom plugins
skills/    - Custom skills
tools/     - Custom tools
themes/    - Custom themes
```

---

## 4. Agents

OpenCode includes two built-in agents switchable with `Tab`:

### build (Default)
- Full-access development agent
- Can read, write, and execute
- Used for implementing changes

### plan (Read-Only)
- Analysis and exploration agent
- Denies file edits by default
- Asks permission before bash commands
- Ideal for exploring unfamiliar codebases or planning changes

### general (Subagent)
- Complex searches and multistep tasks
- Used internally, invocable via `@general` in messages
- Not directly selectable

### Custom Agent Definition

```jsonc
{
  "agent": {
    "my_agent": {
      "description": "Custom agent for specific tasks",
      "model": "anthropic/claude-opus-4-6",
      "system_prompt": "You are a specialized agent...",
      "tools": ["read", "write", "bash"]
    }
  }
}
```

---

## 5. Providers (75+)

### Cloud Providers
| Provider | Models | Auth |
|----------|--------|------|
| Anthropic | Claude Opus 4.6, Sonnet 4.5, Haiku 4.5 | API key |
| OpenAI | GPT-4o, o3 | API key |
| Google | Gemini 2.5 Pro/Flash | API key / Vertex AI |
| Amazon Bedrock | Claude via Bedrock | AWS credentials |
| Groq | Fast inference models | API key |
| Together AI | Open source models | API key |
| OpenRouter | Multi-provider routing | API key |
| DeepSeek | DeepSeek models | API key |
| xAI | Grok models | API key |
| Moonshot AI | Kimi K2/K2.5 | API key |

### Local Providers
| Provider | Setup |
|----------|-------|
| Ollama | `ollama serve` on port 11434 |
| LM Studio | Local server |
| llama.cpp | HTTP server mode |

### Authentication
```bash
# Interactive provider setup
opencode /connect

# API keys stored in
~/.local/share/opencode/auth.json

# Or via environment variables
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."
```

### Custom Provider (OpenAI-compatible)

```jsonc
{
  "provider": {
    "custom": {
      "baseURL": "http://localhost:8081/v1",
      "apiKey": "local",
      "timeout": 60000
    }
  }
}
```

### Amazon Bedrock Configuration

```jsonc
{
  "provider": {
    "amazon-bedrock": {
      "region": "us-east-1",
      "profile": "default",
      "endpoint": "https://vpce-xxx.bedrock-runtime.us-east-1.vpce.amazonaws.com"
    }
  }
}
```

---

## 6. Key Commands

| Command | Description |
|---------|-------------|
| `/init` | Initialize project, create AGENTS.md |
| `/connect` | Authenticate with LLM providers |
| `/models` | Select model |
| `/undo` | Revert recent changes |
| `/redo` | Restore reverted changes |
| `/share` | Generate shareable conversation link |
| `Tab` | Switch between build/plan agents |
| `@general` | Invoke general subagent |

---

## 7. MCP Integration

OpenCode supports MCP (Model Context Protocol) servers for extending agent capabilities.

### Configuration

```jsonc
{
  "mcp": {
    "servers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_TOKEN": "{env:GITHUB_TOKEN}"
        }
      },
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
      }
    }
  }
}
```

---

## 8. AGENTS.md

OpenCode creates and maintains an `AGENTS.md` file in the project root (via `/init`). This file:
- Describes project structure and coding patterns
- Should be committed to Git
- Helps the agent understand context
- Similar to Claude Code's `CLAUDE.md`

---

## 9. Project Architecture

```
opencode/
  packages/
    console/     # TUI application
    web/         # Website / landing
  sdks/          # Client SDKs
  infra/         # Infrastructure (SST)
  specs/         # Specifications
  github/        # GitHub integration
  patches/       # Dependency patches
```

- **Monorepo**: Managed with Bun + Turborepo
- **Language**: TypeScript throughout
- **Build**: Bun bundler
- **Infra**: SST (Serverless Stack) for cloud deployment
- **Runtime**: Bun

---

## 10. Integration with This System

Current system configuration (`~/.opencode/`):
- Model: `anthropic/claude-opus-4-6` (200K context)
- Auth: Anthropic OAuth (web auth credentials)
- Version: v1.1.59
- MCP servers: 4 configured
- Skills: 32 installed

### System-Level Config Path
```
~/.config/opencode/opencode.json  # Global config
~/.local/share/opencode/auth.json # API keys
~/.opencode/                      # Project-level overrides
```

---

## 11. Sources

- Repository: https://github.com/anomalyco/opencode
- README SHA: bd01fc94e8f1110751fe22d87adbfb13bbe38e27
- Docs: https://opencode.ai/docs
- npm: https://www.npmjs.com/package/opencode-ai
- Discord: https://opencode.ai/discord
