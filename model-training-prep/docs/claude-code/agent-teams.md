# Claude Code - Agent Teams & Subagents Reference

## Subagents Overview

Subagents are specialized AI assistants that handle specific types of tasks. Each runs in its own context window with a custom system prompt, specific tool access, and independent permissions.

Benefits:
- **Preserve context**: Keep exploration/implementation out of main conversation
- **Enforce constraints**: Limit tools per subagent
- **Reuse**: User-level subagents work across projects
- **Specialize**: Focused system prompts for specific domains
- **Cost control**: Route tasks to faster/cheaper models like Haiku

## Built-in Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| Explore | Haiku | Read-only | Codebase search and analysis |
| Plan | Inherits | Read-only | Research for plan mode |
| General-purpose | Inherits | All | Complex multi-step tasks |
| Bash | Inherits | Terminal | Running commands in separate context |
| statusline-setup | Sonnet | -- | Configure status line |
| Claude Code Guide | Haiku | -- | Questions about features |

## Creating Subagents

### Via /agents Command (Recommended)
```
/agents
```
Interactive interface to create, edit, delete subagents.

### Via Markdown Files

Subagent files use YAML frontmatter + Markdown body:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific,
actionable feedback on quality, security, and best practices.
```

### Via CLI Flag

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

## Subagent Scope (Priority Order)

| Location | Scope | Priority |
|----------|-------|----------|
| `--agents` CLI flag | Current session | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All your projects | 3 |
| Plugin `agents/` dir | Where plugin enabled | 4 (lowest) |

## Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When to delegate to this subagent |
| `tools` | No | Tools to allow (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny |
| `model` | No | `sonnet`, `opus`, `haiku`, `inherit` (default: inherit) |
| `permissionMode` | No | `default`, `acceptEdits`, `delegate`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Maximum agentic turns |
| `skills` | No | Skills to preload into context |
| `mcpServers` | No | MCP servers available |
| `hooks` | No | Lifecycle hooks |
| `memory` | No | Persistent memory: `user`, `project`, `local` |

## Permission Modes

| Mode | Behavior |
|------|----------|
| `default` | Standard permission checking |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny prompts (allowed tools still work) |
| `delegate` | Coordination-only for team leads |
| `bypassPermissions` | Skip all permission checks |
| `plan` | Read-only exploration |

## Persistent Memory

```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices
memory: user
---
```

| Scope | Location | Use Case |
|-------|----------|----------|
| `user` | `~/.claude/agent-memory/<name>/` | Cross-project learnings |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, private |

## Hooks in Subagents

### In Frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

### In settings.json (Project-level)

```json
{
  "hooks": {
    "SubagentStart": [
      { "matcher": "db-agent", "hooks": [{ "type": "command", "command": "./setup-db.sh" }] }
    ],
    "SubagentStop": [
      { "hooks": [{ "type": "command", "command": "./cleanup.sh" }] }
    ]
  }
}
```

## Restricting Subagent Spawning

```yaml
# Only allow spawning worker and researcher
tools: Task(worker, researcher), Read, Bash

# Allow spawning any subagent
tools: Task, Read, Bash
```

## Disabling Subagents

```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

## Foreground vs Background

- **Foreground**: Blocks main conversation, permission prompts passed through
- **Background**: Runs concurrently, permissions pre-approved, MCP tools unavailable
- Press **Ctrl+B** to background a running task
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable

## Common Patterns

1. **Isolate high-volume operations**: Tests, docs, logs in subagent context
2. **Parallel research**: Multiple subagents exploring independent areas
3. **Chain subagents**: Sequential workflow (review -> optimize -> test)
4. **Resume subagents**: Continue previous work with full context

## Example: Code Reviewer

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:
- Code clarity and readability
- Proper error handling
- No exposed secrets
- Input validation
- Test coverage
- Performance considerations

Provide feedback by priority:
- Critical issues (must fix)
- Warnings (should fix)
- Suggestions (consider)
```

## Example: Database Query Validator

```markdown
---
name: db-reader
description: Execute read-only database queries
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---

You are a database analyst with read-only access.
Execute SELECT queries to answer questions about the data.
```
