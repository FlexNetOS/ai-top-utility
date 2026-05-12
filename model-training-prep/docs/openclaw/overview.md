# OpenClaw - Documentation

## Project Overview

**Name**: OpenClaw
**Purpose**: Personal AI assistant that runs on your own devices. Answers you on channels you already use (WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, Microsoft Teams, WebChat) with multi-channel inbox, voice, and canvas features.
**Repository**: https://github.com/openclaw/openclaw
**Website**: https://openclaw.ai
**Documentation**: https://docs.openclaw.ai
**License**: MIT
**Local Path**: ~/Documents/openclaw/
**Runtime**: Node >= 22

## Installation

```bash
npm install -g openclaw@latest
# or: pnpm add -g openclaw@latest

openclaw onboard --install-daemon
```

The wizard installs the Gateway daemon (launchd/systemd user service) so it stays running.

## Quick Start

```bash
openclaw onboard --install-daemon
openclaw gateway --port 18789 --verbose

# Send a message
openclaw message send --to +1234567890 --message "Hello from OpenClaw"

# Talk to the assistant
openclaw agent --message "Ship checklist" --thinking high
```

## Architecture

```
WhatsApp / Telegram / Slack / Discord / Google Chat / Signal / iMessage /
BlueBubbles / Microsoft Teams / Matrix / Zalo / WebChat
               |
               v
+-------------------------------+
|            Gateway            |
|       (control plane)         |
|     ws://127.0.0.1:18789      |
+-------------------------------+
               |
               +-- Pi agent (RPC)
               +-- CLI (openclaw ...)
               +-- WebChat UI
               +-- macOS app
               +-- iOS / Android nodes
```

## Supported Channels

| Channel | Integration | Config Key |
|---------|-------------|------------|
| WhatsApp | Baileys | `channels.whatsapp` |
| Telegram | grammY | `channels.telegram` |
| Slack | Bolt | `channels.slack` |
| Discord | discord.js | `channels.discord` |
| Google Chat | Chat API | `channels.googlechat` |
| Signal | signal-cli | `channels.signal` |
| BlueBubbles | iMessage (recommended) | `channels.bluebubbles` |
| iMessage | Legacy macOS | `channels.imessage` |
| Microsoft Teams | Extension | `channels.msteams` |
| Matrix | Extension | `channels.matrix` |
| Zalo | Extension | `channels.zalo` |
| Zalo Personal | Extension | `channels.zalouser` |
| WebChat | Gateway WS | Built-in |

## Configuration

Minimal `~/.openclaw/openclaw.json`:

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

Full configuration reference: https://docs.openclaw.ai/gateway/configuration

### Channel Configuration Examples

```json5
// Telegram
{
  channels: {
    telegram: {
      botToken: "123456:ABCDEF",
    },
  },
}

// Discord
{
  channels: {
    discord: {
      token: "1234abcd",
    },
  },
}
```

### Environment Variables

| Variable | Channel |
|----------|---------|
| `TELEGRAM_BOT_TOKEN` | Telegram |
| `SLACK_BOT_TOKEN` + `SLACK_APP_TOKEN` | Slack |
| `DISCORD_BOT_TOKEN` | Discord |

## Security Model

- **Default**: Tools run on host for main session (full access for single user)
- **Group/channel safety**: `agents.defaults.sandbox.mode: "non-main"` for Docker sandboxes
- **Sandbox defaults**: Allow bash, process, read, write, edit, sessions_*; Deny browser, canvas, nodes, cron, discord, gateway
- **DM pairing**: Unknown senders get pairing code, must approve with `openclaw pairing approve`

## Key Subsystems

### Gateway WebSocket Network
Single WS control plane for clients, tools, and events.

### Agent Workspace & Skills
- Workspace root: `~/.openclaw/workspace` (configurable)
- Injected prompt files: `AGENTS.md`, `SOUL.md`, `TOOLS.md`
- Skills: `~/.openclaw/workspace/skills/<skill>/SKILL.md`

### Multi-agent Routing
Route inbound channels/accounts/peers to isolated agents with per-agent workspaces and sessions.

### Voice Wake + Talk Mode
Always-on speech for macOS/iOS/Android with ElevenLabs.

### Live Canvas
Agent-driven visual workspace with A2UI (Agent-to-UI) push/reset, eval, snapshot.

### Browser Control
Dedicated openclaw Chrome/Chromium with CDP control, snapshots, actions, uploads, profiles.

### Agent to Agent (Sessions Tools)
- `sessions_list` - discover active sessions
- `sessions_history` - fetch transcript logs
- `sessions_send` - message another session

### Skills Registry (ClawHub)
Minimal skill registry at https://clawhub.com. Agent can search and pull skills automatically.

## Chat Commands

| Command | Description |
|---------|-------------|
| `/status` | Session status (model + tokens) |
| `/new` or `/reset` | Reset session |
| `/compact` | Compact session context |
| `/think <level>` | off/minimal/low/medium/high/xhigh |
| `/verbose on/off` | Toggle verbose mode |
| `/usage off/tokens/full` | Per-response usage footer |
| `/restart` | Restart gateway |
| `/activation mention/always` | Group activation toggle |

## CLI Commands

| Command | Description |
|---------|-------------|
| `openclaw onboard` | Guided setup wizard |
| `openclaw gateway` | Start the gateway |
| `openclaw agent` | Direct agent interaction |
| `openclaw message send` | Send a message |
| `openclaw channels login` | Link messaging device |
| `openclaw pairing approve` | Approve DM sender |
| `openclaw doctor` | Health check and migrations |
| `openclaw update` | Update to latest version |
| `openclaw nodes` | Manage device nodes |

## Development Channels

| Channel | Description | npm dist-tag |
|---------|-------------|--------------|
| stable | Tagged releases | `latest` |
| beta | Prerelease tags | `beta` |
| dev | Head of `main` | `dev` |

Switch: `openclaw update --channel stable|beta|dev`

## Apps (Optional)

### macOS (OpenClaw.app)
Menu bar control, Voice Wake, push-to-talk overlay, WebChat, debug tools, remote gateway control.

### iOS Node
Voice trigger forwarding, Canvas surface, camera, Bonjour pairing.

### Android Node
Canvas, Talk Mode, camera, screen recording, optional SMS.

## Model Recommendation

Anthropic Pro/Max (100/200) + Opus 4.6 recommended for long-context strength and prompt-injection resistance.

## Current System Configuration

- Running on port 18789 (gateway) / 18792
- Model: anthropic/claude-opus-4-6 (primary)
- Auth: anthropic:claude-cli profile
