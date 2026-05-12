# Anthropic Cookbook (Claude Cookbooks) - Documentation Overview

**Repository**: https://github.com/anthropics/anthropic-cookbook
**Purpose**: Official code examples and guides for building with Claude API
**Language**: Python (primarily), concepts applicable to any language
**License**: MIT
**Collected**: 2026-02-13

---

## 1. Purpose

The Anthropic Cookbook (officially "Claude Cookbooks") provides copy-able code snippets and Jupyter notebooks demonstrating how to build applications with the Claude API. It covers the full range of Claude capabilities: tool use, multi-modal input, RAG, classification, summarization, agent patterns, fine-tuning, and the Claude Agent SDK.

This is the primary reference for integration patterns when building AI-powered applications with Anthropic's models.

---

## 2. Repository Structure

```
anthropic-cookbook/
  capabilities/          # Core Claude capabilities
    classification/      # Text/data classification techniques
    retrieval_augmented_generation/  # RAG patterns
    summarization/       # Summarization techniques
  claude_agent_sdk/      # Agent SDK tutorials (KEY SECTION)
    00_The_one_liner_research_agent.ipynb
    01_The_chief_of_staff_agent.ipynb
    02_The_observability_agent.ipynb
    research_agent/      # Standalone research agent implementation
    chief_of_staff_agent/ # Multi-agent executive assistant
    observability_agent/  # DevOps monitoring agent
  coding/                # Code-related examples
  extended_thinking/     # Extended thinking / chain-of-thought
  finetuning/            # Fine-tuning on Bedrock
    datasets/            # Sample datasets
    finetuning_on_bedrock.ipynb
  multimodal/            # Vision and multimodal
    getting_started_with_vision.ipynb
    best_practices_for_vision.ipynb
    reading_charts_graphs_powerpoints.ipynb
    how_to_transcribe_text.ipynb
    using_sub_agents.ipynb
  observability/         # Observability patterns
  patterns/              # Design patterns
    agents/              # Agent architecture patterns
  skills/                # Claude Code skills
  tool_evaluation/       # Tool evaluation framework
  tool_use/              # Tool use examples (KEY SECTION)
    calculator_tool.ipynb
    customer_service_agent.ipynb
    extracting_structured_json.ipynb
    memory_cookbook.ipynb
    memory_tool.py
    parallel_tools.ipynb
    programmatic_tool_calling_ptc.ipynb
    tool_choice.ipynb
    tool_search_alternate_approaches.ipynb
    tool_search_with_embeddings.ipynb
    tool_use_with_pydantic.ipynb
    vision_with_tools.ipynb
    automatic-context-compaction.ipynb
  third_party/           # Third-party integrations
    Pinecone/            # Vector DB RAG
    VoyageAI/            # Embeddings
    Wikipedia/           # Wikipedia search
  misc/                  # Additional examples
    how_to_make_sql_queries.ipynb
    read_web_pages_with_haiku.ipynb
    illustrated_responses.ipynb
    pdf_upload_summarization.ipynb
    building_evals.ipynb
    how_to_enable_json_mode.ipynb
    building_moderation_filter.ipynb
    prompt_caching.ipynb
```

---

## 3. Tool Use Examples (Key Section)

The `tool_use/` directory is the primary reference for Claude tool integration patterns.

### Available Notebooks

| Notebook | Description | Key Concepts |
|----------|-------------|--------------|
| `calculator_tool.ipynb` | Basic calculator tool integration | Tool definition, input schema, tool_result handling |
| `customer_service_agent.ipynb` | Multi-tool customer service agent | Agent loop, tool routing, conversation state |
| `extracting_structured_json.ipynb` | Force structured JSON output via tools | Tool choice, schema enforcement |
| `memory_cookbook.ipynb` | Memory system with tools | Persistent memory, read/write/search memory tools |
| `memory_tool.py` | Standalone memory tool implementation | File-based memory, embedding search |
| `parallel_tools.ipynb` | Parallel tool execution | Multiple simultaneous tool calls |
| `programmatic_tool_calling_ptc.ipynb` | Programmatic Tool Calling (PTC) | Automated tool selection, dynamic schemas |
| `tool_choice.ipynb` | Controlling tool selection behavior | `auto`, `any`, `tool` choice modes |
| `tool_search_alternate_approaches.ipynb` | Tool search strategies | Dynamic tool selection for large tool sets |
| `tool_search_with_embeddings.ipynb` | Embedding-based tool search | Semantic tool discovery |
| `tool_use_with_pydantic.ipynb` | Pydantic-based tool definitions | Type-safe tool schemas |
| `vision_with_tools.ipynb` | Vision + tools together | Multimodal tool use |
| `automatic-context-compaction.ipynb` | Context window management | Automatic summarization, token optimization |

### Tool Definition Pattern

```python
tools = [
    {
        "name": "get_weather",
        "description": "Get the current weather in a given location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA"
                }
            },
            "required": ["location"]
        }
    }
]

response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    tools=tools,
    messages=[{"role": "user", "content": "What's the weather in SF?"}]
)
```

### Tool Choice Modes

| Mode | Behavior |
|------|----------|
| `{"type": "auto"}` | Claude decides whether to use tools (default) |
| `{"type": "any"}` | Claude must use at least one tool |
| `{"type": "tool", "name": "get_weather"}` | Claude must use the specified tool |

---

## 4. Claude Agent SDK (Key Section)

The `claude_agent_sdk/` directory contains a tutorial series for building production agents using the Claude Agent SDK (`claude-agent-sdk-python`).

### Architecture

The Claude Agent SDK provides a programmatic interface to Claude Code's agentic capabilities:

```python
from claude_code_sdk import ClaudeSDKClient, ClaudeAgentOptions

client = ClaudeSDKClient()
options = ClaudeAgentOptions(
    system_prompt="You are a research agent...",
    tools=["WebSearch", "Read"],
    model="claude-opus-4-6"
)

# One-liner agent execution
result = await client.query("Research topic X", options=options)
```

### Agent Tutorial Progression

| Notebook | Agent | Key Concepts |
|----------|-------|--------------|
| `00` | Research Agent | `query()`, WebSearch tool, Read tool, multimodal, conversation context |
| `01` | Chief of Staff | CLAUDE.md, plan mode, slash commands, hooks, subagent orchestration, Bash tool |
| `02` | Observability Agent | MCP servers (Git 13+ tools, GitHub 100+ tools), CI/CD monitoring, incident response |

### Key SDK Concepts

- **`query()`**: Execute an agent query with tools and system prompt
- **`ClaudeSDKClient`**: Persistent client with conversation state
- **`ClaudeAgentOptions`**: Configure model, tools, system prompt, permissions
- **Plan Mode**: Strategic planning without execution (read-only)
- **Hooks**: Event-driven callbacks for compliance, logging, auditing
- **Subagents**: Specialized child agents for domain expertise
- **MCP Integration**: Connect to external systems via Model Context Protocol

### Standalone Agent Implementations

Each tutorial includes a runnable agent in its own directory:
- `research_agent/` - Web search + multimodal analysis
- `chief_of_staff_agent/` - Multi-agent executive assistant with financial modeling
- `observability_agent/` - DevOps monitoring with GitHub integration

---

## 5. Fine-Tuning

The `finetuning/` directory contains:
- `finetuning_on_bedrock.ipynb` - Fine-tuning Claude on AWS Bedrock
- `datasets/` - Sample training datasets

This is relevant for our model training preparation work.

---

## 6. MCP Integration Patterns

MCP (Model Context Protocol) examples appear across multiple sections:

- **`claude_agent_sdk/02_The_observability_agent.ipynb`**: Full MCP integration with Git (13+ tools) and GitHub (100+ tools) servers
- **`tool_use/`**: Tool patterns that map to MCP tool definitions
- **`patterns/agents/`**: Agent architecture patterns using MCP

### MCP Server Integration Pattern

```python
options = ClaudeAgentOptions(
    mcp_servers=[
        {
            "name": "github",
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"]
        }
    ]
)
```

---

## 7. Integration Patterns for Training Data

The cookbook provides patterns useful for generating training data:

### Pattern: Tool Use Conversations
Each notebook generates multi-turn conversations with tool calls and results, which can be converted to training pairs.

### Pattern: Agent Loops
Agent notebooks demonstrate the complete request-response-tool_use-tool_result loop, providing rich training signal for:
- When to use which tools
- How to compose tool results into responses
- Error handling and retry logic
- Multi-step planning

### Pattern: Memory Systems
The `memory_cookbook.ipynb` and `memory_tool.py` demonstrate persistent memory patterns directly applicable to our OpenMemory/MemU systems.

---

## 8. Prerequisites

```bash
# Python dependencies
pip install anthropic

# For notebooks
pip install jupyter anthropic

# For Agent SDK tutorials
pip install uv
uv sync
uv run python -m ipykernel install --user --name="cc-sdk-tutorial"

# API key
export ANTHROPIC_API_KEY="your-key"
```

---

## 9. Related Resources

- [Anthropic Developer Docs](https://docs.claude.com)
- [Claude API Fundamentals Course](https://github.com/anthropics/courses/tree/master/anthropic_api_fundamentals)
- [Claude Agent SDK Python](https://github.com/anthropics/claude-agent-sdk-python)
- [Anthropic on AWS](https://github.com/aws-samples/anthropic-on-aws)
- [Anthropic Discord](https://www.anthropic.com/discord)

---

## 10. Source

- Repository: https://github.com/anthropics/anthropic-cookbook
- README SHA: dae0afd314940ca051db290b6b01cf4ec019857c
- Agent SDK README SHA: 5bf6ac246b91fb372d8827c6c0e6ce2970868627
