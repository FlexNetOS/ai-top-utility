# Claude Code - Documentation

## Project Overview

**Name**: Claude Code
**Purpose**: An agentic coding tool by Anthropic that reads codebases, edits files, runs commands, and integrates with development tools. Available in terminal, IDE (VS Code, JetBrains), desktop app, and browser.
**Website**: https://code.claude.com
**Documentation**: https://code.claude.com/docs/en/overview

## Installation

```bash
# Native Install (macOS, Linux, WSL)
curl -fsSL https://claude.ai/install.sh | bash

# Windows PowerShell
irm https://claude.ai/install.ps1 | iex

# Homebrew
brew install --cask claude-code

# WinGet
winget install Anthropic.ClaudeCode
```

## Surfaces

| Surface | Description |
|---------|-------------|
| Terminal CLI | Full-featured CLI for working with Claude Code in terminal |
| VS Code / Cursor | Extension with inline diffs, @-mentions, plan review |
| JetBrains | Plugin for IntelliJ, PyCharm, WebStorm with interactive diff viewing |
| Desktop App | Standalone app for visual diff review and multiple sessions |
| Web | Browser-based, no local setup, long-running tasks at claude.ai/code |
| Chrome | Debug live web applications |
| Slack | Route bug reports from Slack to pull requests |

## Key Capabilities

1. **Automate tedious tasks**: Write tests, fix lint errors, resolve merge conflicts, update dependencies, write release notes
2. **Build features and fix bugs**: Describe in plain language, Claude plans and implements across multiple files
3. **Git operations**: Stage changes, write commit messages, create branches, open PRs
4. **MCP integration**: Connect to external tools via Model Context Protocol (Jira, Google Drive, Slack, etc.)
5. **CLAUDE.md customization**: Set coding standards, architecture decisions, preferred libraries per project
6. **Custom skills**: Package repeatable workflows as slash commands (e.g., /review-pr, /deploy-staging)
7. **Hooks**: Run shell commands before/after Claude Code actions
8. **Agent teams**: Spawn multiple agents working on different parts simultaneously
9. **CLI composability**: Pipe logs, run in CI, chain with other tools following Unix philosophy
10. **Cross-device**: Start on laptop, continue on mobile via web/iOS app

## Authentication

- **Claude.ai subscription** (Pro/Max) or **Anthropic Console** API account
- Terminal CLI and VS Code also support third-party providers
- OAuth-based login on first use

## CLI Usage

```bash
# Start in a project
cd your-project
claude

# Run a one-off command
claude -p "translate new strings into French and raise a PR"

# Pipe input
tail -f app.log | claude -p "Slack me if you see any anomalies"

# Bulk operations
git diff main --name-only | claude -p "review these changed files for security issues"
```

## CLAUDE.md

A markdown file in the project root that Claude Code reads at session start. Used for:
- Coding standards and architecture decisions
- Preferred libraries and frameworks
- Review checklists
- Project-specific context

Multiple locations supported:
- `CLAUDE.md` in project root (project-level)
- `~/.claude/CLAUDE.md` (user-level)
- `.claude/CLAUDE.md` (git-tracked project settings)

## CI/CD Integration

- **GitHub Actions**: Automate code review and issue triage
- **GitLab CI/CD**: Similar automation capabilities
- **Headless mode**: Run programmatically with Agent SDK
