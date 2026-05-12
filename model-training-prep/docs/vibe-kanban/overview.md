# Vibe Kanban - Documentation Overview

**Repository**: https://github.com/BloopAI/vibe-kanban
**Website**: https://vibekanban.com
**npm Package**: vibe-kanban
**Purpose**: Visual project management and orchestration tool for AI coding agents
**Language**: Rust (backend) + TypeScript/React (frontend)
**License**: Apache 2.0
**Version**: 0.1.11 (latest)
**Collected**: 2026-02-13

---

## 1. Purpose

Vibe Kanban is a visual Kanban-style project management tool specifically designed for orchestrating AI coding agents. It enables developers to:

- Easily switch between different coding agents (Claude Code, Gemini CLI, Codex, Amp, OpenCode, Cursor, Qwen-Code, Copilot, Droid)
- Orchestrate multiple coding agents in parallel or sequence
- Quickly review agent work and start dev servers
- Track task status across coding agent sessions
- Centralize MCP server configurations
- Open projects remotely via SSH
- Manage git worktrees per task for isolated execution

It fills the role of a "project manager for AI agents" -- the human plans and reviews, while agents execute in isolated workspaces.

---

## 2. Installation & Usage

```bash
# Primary method (no install needed)
npx vibe-kanban

# Or install globally
npm i -g vibe-kanban

# Self-hosting available
# See: https://vibekanban.com/docs/self-hosting
```

No separate agent installation needed -- Vibe Kanban uses agents already authenticated on the system (Claude Code, etc.).

---

## 3. MCP Server

Vibe Kanban exposes a **local MCP server** for external MCP clients (Claude Desktop, Raycast, coding agents) to manage projects and tasks programmatically.

### MCP Server Configuration

Add to your agent's MCP config (e.g., `~/.claude/.mcp.json`):

```json
{
  "mcpServers": {
    "vibe_kanban": {
      "command": "npx",
      "args": ["-y", "vibe-kanban@latest", "--mcp"]
    }
  }
}
```

Or configure via the Vibe Kanban UI: Settings -> MCP Servers.

### MCP Tools

#### Project Management

| Tool | Parameters | Description |
|------|-----------|-------------|
| `list_projects` | (none) | Retrieve all projects with metadata |
| `list_repos` | `project_id` | List repositories within a project |

#### Workspace Context

| Tool | Parameters | Description |
|------|-----------|-------------|
| `get_context` | (none) | Get current workspace metadata (project, task, session). Only available during active workspace sessions |

#### Task Operations

| Tool | Required Params | Optional Params | Description |
|------|----------------|-----------------|-------------|
| `list_tasks` | `project_id` | `status`, `limit` | List tasks with optional filtering |
| `create_task` | `project_id`, `title` | `description` | Create a new task |
| `get_task` | `task_id` | - | Get task details |
| `update_task` | `task_id` | `title`, `description`, `status` | Update task fields |
| `delete_task` | `task_id` | - | Delete a task |

#### Repository Configuration

| Tool | Parameters | Description |
|------|-----------|-------------|
| `get_repo` | `repo_id` | Get repo details including setup/cleanup/dev scripts |
| `update_setup_script` | `repo_id` | Modify repository setup automation |
| `update_cleanup_script` | `repo_id` | Modify repository cleanup automation |
| `update_dev_server_script` | `repo_id` | Modify dev server configuration |

#### Task Execution

| Tool | Required Params | Optional Params | Description |
|------|----------------|-----------------|-------------|
| `start_workspace_session` | `task_id`, `executor`, `repos` (array: `repo_id`, `base_branch`) | `variant` | Start a coding agent workspace session |

### Supported Executors

| Executor ID | Agent |
|------------|-------|
| `claude-code` | Claude Code (Anthropic) |
| `amp` | Amp |
| `gemini` | Gemini CLI (Google) |
| `codex` | Codex (OpenAI) |
| `opencode` | OpenCode |
| `cursor_agent` | Cursor Agent |
| `qwen-code` | Qwen-Code |
| `copilot` | GitHub Copilot |
| `droid` | Droid |

---

## 4. Architecture

### Technology Stack
- **Backend**: Rust
- **Frontend**: React (TypeScript)
- **Database**: SQLite (SQLx)
- **Build**: pnpm monorepo
- **Distribution**: npm (npx wrapper), pre-built binaries

### How It Works

1. **Projects** contain **Repositories** and **Tasks**
2. Each **Task** can be assigned to a **coding agent** (executor)
3. When a task starts, Vibe Kanban creates an isolated **workspace** (git worktree)
4. The agent executes in the worktree with its own branch
5. On completion, changes can be reviewed and merged
6. Multiple agents can work on different tasks simultaneously

### Git Worktree Isolation

Each task execution uses a git worktree, providing:
- Isolated branch per task (no conflicts between concurrent agents)
- Clean working directory for each agent
- Easy diff review after completion
- Automatic cleanup of completed worktrees

---

## 5. Configuration

### Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `PORT` | Runtime | Auto | Server port (production: full server; dev: frontend) |
| `BACKEND_PORT` | Runtime | `0` (auto) | Backend port (dev only) |
| `FRONTEND_PORT` | Runtime | `3000` | Frontend port (dev only) |
| `HOST` | Runtime | `127.0.0.1` | Backend host |
| `MCP_HOST` | Runtime | = `HOST` | MCP server host |
| `MCP_PORT` | Runtime | = `BACKEND_PORT` | MCP server port |
| `DISABLE_WORKTREE_CLEANUP` | Runtime | Not set | Disable worktree cleanup (debug) |
| `VK_ALLOWED_ORIGINS` | Runtime | Not set | CORS allowed origins |
| `POSTHOG_API_KEY` | Build | Empty | Analytics (disabled if empty) |
| `POSTHOG_API_ENDPOINT` | Build | Empty | Analytics endpoint |

### Remote Deployment

Vibe Kanban supports remote server deployment with SSH integration:

1. Expose web UI via Cloudflare Tunnel, ngrok, etc.
2. Configure Remote SSH in Settings -> Editor Integration
3. Set Remote SSH Host and User
4. "Open in VSCode" generates `vscode://vscode-remote/ssh-remote+user@host/path` URLs

### Reverse Proxy / Custom Domain

When behind a reverse proxy, set `VK_ALLOWED_ORIGINS`:

```bash
VK_ALLOWED_ORIGINS=https://vk.example.com,https://vk-staging.example.com
```

---

## 6. Integration Patterns

### Pattern: Multi-Agent Orchestration

```
1. Create project in Vibe Kanban
2. Break work into tasks on the Kanban board
3. Assign tasks to different agents:
   - Task 1 -> claude-code (backend API)
   - Task 2 -> opencode (frontend UI)
   - Task 3 -> gemini (tests)
4. Agents work in parallel on isolated worktrees
5. Review and merge completed work
```

### Pattern: Sequential Pipeline

```
1. Task 1 (plan): plan agent analyzes codebase
2. Task 2 (implement): build agent implements changes
3. Task 3 (test): agent writes and runs tests
4. Task 4 (review): agent reviews and refines
```

### Pattern: MCP Integration with Claude Code

When running inside Claude Code, the Vibe Kanban MCP server provides:
- Project context awareness via `get_context`
- Task management without leaving the agent
- Automated workspace session management

---

## 7. Development

### Prerequisites
- Rust (latest stable)
- Node.js >= 18
- pnpm >= 8

```bash
# Install dev tools
cargo install cargo-watch
cargo install sqlx-cli

# Install dependencies
pnpm i

# Run dev server
pnpm run dev

# Build frontend
cd frontend && pnpm build

# Build from source (macOS)
./local-build.sh
```

---

## 8. Community Variants

| Package | Description |
|---------|-------------|
| `vibe-kanban` | Official package (BloopAI) |
| `vibe-kanban-better-mcp` | Enhanced MCP server with simplified tools and environment-based project/repo locking |
| `vibe-kanban-pm` | Community fork (Lanespire) |

---

## 9. Relevance to This System

Vibe Kanban is directly useful for our model-training-prep workflow:

- **Orchestrate training tasks** across multiple agents (Claude Code, OpenCode)
- **Track preparation steps** (data collection, config auditing, model download)
- **MCP integration** allows agents to self-manage tasks
- **Git worktree isolation** prevents concurrent agents from conflicting
- **Remote access** enables monitoring training runs from any device

### Potential MCP Config Addition

```json
{
  "mcpServers": {
    "vibe_kanban": {
      "command": "npx",
      "args": ["-y", "vibe-kanban@latest", "--mcp"]
    }
  }
}
```

---

## 10. Sources

- Repository: https://github.com/BloopAI/vibe-kanban
- README SHA: 162a27c61bf93bac3153bc42b878092f9754b3ef
- npm: https://www.npmjs.com/package/vibe-kanban
- Website: https://vibekanban.com
- MCP Docs: https://vibekanban.com/docs/integrations/vibe-kanban-mcp-server
- DeepWiki: https://deepwiki.com/BloopAI/vibe-kanban
