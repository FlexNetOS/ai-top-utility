# Agent Zero - Documentation

## Project Overview

**Name**: Agent Zero
**Purpose**: A personal, organic agentic framework that grows and learns with you. General-purpose AI assistant that uses the computer as a tool, with multi-agent cooperation, persistent memory, and fully customizable behavior.
**Repository**: https://github.com/frdel/agent-zero (now github.com/agent0ai/agent-zero)
**Website**: https://agent-zero.ai
**Version**: v0.9.8 (latest: Skills, UI Redesign & Git projects)
**License**: Open source
**Container**: Running as `agent-zero` in Podman on port 50080

## Quick Start

```bash
# Docker (simplest)
docker pull agent0ai/agent-zero
docker run -p 50001:80 agent0ai/agent-zero
# Visit http://localhost:50001
```

## Key Features

### 1. General-purpose Assistant
- Not pre-programmed for specific tasks
- Persistent memory for learning across sessions
- Give it a task and it gathers info, executes commands, cooperates with other agents

### 2. Computer as a Tool
- Uses the OS as a tool (no single-purpose tools pre-programmed)
- Can write its own code and create its own tools
- Default tools: online search (SearXNG), memory, communication, code/terminal execution
- Skills System (SKILL.md standard): Compatible with Claude Code, Cursor, Goose, Codex, Copilot

### 3. Multi-agent Cooperation
- Hierarchical structure: superior agents delegate to subordinates
- Agent 0's superior is the human user
- Every agent can create subordinate agents for subtasks
- Clean context management per agent

### 4. Fully Customizable
- Behavior defined by system prompt in `prompts/default/agent.system.md`
- All prompts in `prompts/` folder
- All default tools in `python/tools/` folder
- Automated configuration via `A0_SET_` environment variables

### 5. Communication
- Real-time streamed, interactive terminal
- Stop and intervene at any point
- Configurable reporting and delegation patterns

## Architecture

### Directory Structure (Container: /a0/)

```
/a0/
+-- agent.py          # Main agent logic
+-- agents/           # Agent configurations
+-- conf/             # Configuration files
|   +-- model_providers.yaml
|   +-- projects.default.gitignore
|   +-- skill.default.gitignore
|   +-- workdir.gitignore
+-- docker/           # Docker configs
+-- docs/             # Documentation
+-- knowledge/        # Knowledge base
+-- lib/              # Libraries
+-- models.py         # Model definitions
+-- preload.py        # Preload logic
+-- prompts/          # System prompts
+-- python/           # Python tools
+-- skills/           # Agent skills
+-- tests/            # Test suite
+-- usr/              # User data
+-- webui/            # Web interface
```

## Model Providers

Agent Zero supports 20+ LLM providers via LiteLLM:

### Chat Providers

| Provider ID | Name | LiteLLM Provider |
|-------------|------|-----------------|
| `a0_venice` | Agent Zero API | openai |
| `anthropic` | Anthropic | anthropic |
| `cometapi` | CometAPI | cometapi |
| `deepseek` | DeepSeek | deepseek |
| `github_copilot` | GitHub Copilot | github_copilot |
| `google` | Google | gemini |
| `groq` | Groq | groq |
| `huggingface` | HuggingFace | huggingface |
| `lm_studio` | LM Studio | lm_studio |
| `mistral` | Mistral AI | mistral |
| `moonshot` | Moonshot AI | moonshot |
| `ollama` | Ollama | ollama |
| `openai` | OpenAI | openai |
| `azure` | OpenAI Azure | azure |
| `bedrock` | AWS Bedrock | bedrock |
| `openrouter` | OpenRouter | openrouter |
| `sambanova` | Sambanova | sambanova |
| `venice` | Venice.ai | openai |
| `xai` | xAI | xai |
| `zai` | Z.AI | openai |
| `zai_coding` | Z.AI Coding | openai |
| `other` | Other OpenAI compatible | openai |

### Embedding Providers

| Provider ID | Name |
|-------------|------|
| `huggingface` | HuggingFace |
| `google` | Google |
| `lm_studio` | LM Studio |
| `mistral` | Mistral AI |
| `ollama` | Ollama |
| `openai` | OpenAI |
| `azure` | OpenAI Azure |
| `bedrock` | AWS Bedrock |
| `openrouter` | OpenRouter |
| `other` | Other OpenAI compatible |

## Tools

### Default Tools
- **search_engine**: Web search via SearXNG
- **document_query**: Query documents in knowledge base
- **code_execution_tool**: Execute Python code in container
- **communication**: User and agent communication
- **memory**: Persistent memory operations

### Skills System (SKILL.md Standard)
- Portable, structured agent capabilities
- Compatible with Claude Code, Cursor, Goose, Codex, Copilot
- Located in `/a0/skills/`
- Import via UI or file upload

### Browser Tools (MCP-based)
- Browser OS MCP
- Chrome DevTools MCP
- Playwright MCP

## Projects System

Each project includes:
- Isolated workspace under `/a0/usr/projects/<name>/`
- Custom instructions injected into system prompts
- Dedicated or shared memory
- Project-scoped secrets and variables
- Git repository integration
- File structure injection
- Custom agent configurations
- Knowledge base integration

### Project Configuration
- **Description**: Purpose and context
- **Instructions**: Injected into agent system prompt
- **Memory isolation**: Own memory (recommended) or global
- **Variables**: Non-sensitive config in `.a0proj/variables.env`
- **Secrets**: Sensitive config in `.a0proj/secrets.env`
- **File structure**: Auto-inject directory structure (configurable depth)

## Connectivity

### MCP (Model Context Protocol)
- Agent Zero can act as MCP Server (Streamable HTTP)
- Agent Zero can use external MCP servers as tools
- Settings -> MCP/A2A to configure

### A2A (Agent to Agent Protocol)
- Agents can communicate with each other
- Settings -> MCP/A2A -> A0 A2A Server to enable
- Task delegation to specialized instances
- Distributed workflows across agents

### External API
- API endpoints for programmatic access
- Webhook support

## Web UI Features

- Real-time WebSocket communication
- Process groups with expand/collapse
- File browser and editor
- Knowledge import (txt, pdf, csv, html, json, md)
- Chat history in JSON format
- Context viewer for debugging
- Scheduler for recurring tasks
- In-browser file editor
- Message queue system

## Configuration

### Environment Variables
- `A0_SET_*` prefix for automated configuration
- API keys: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, etc.
- Configuration via `.env` file

### Settings Page
- Model selection (chat + embedding)
- Provider configuration
- Browser agent settings
- Memory settings
- Speech (TTS/STT) settings
- Security settings

## Current System Configuration

- Running in Podman container `agent-zero` on port 50080
- Version: v2026.02.01
- Chat model: qwen2.5-coder:7b (Ollama) / claude-opus-4-6 (Anthropic)
- Available via MCP client/server and A2A protocol
