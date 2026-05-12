# MemU - Documentation

## Project Overview

**Name**: memU
**Purpose**: 24/7 always-on proactive memory framework for AI agents. Reduces LLM token cost for long-running agents, continuously captures and understands user intent.
**Repository**: https://github.com/NevaMind-AI/memU
**Website**: https://memu.so (cloud), https://memu.bot (bot)
**License**: Apache 2.0
**Language**: Python 3.13+
**PyPI**: `memu-py`
**Local Path**: ~/memU/ (core), ~/memU-server/ (API server)

## Core Concept: Memory as File System

| File System | memU Memory |
|-------------|-------------|
| Folders | Categories (auto-organized topics) |
| Files | Memory Items (extracted facts, preferences, skills) |
| Symlinks | Cross-references (related memories linked) |
| Mount points | Resources (conversations, documents, images) |

```
memory/
+-- preferences/
|   +-- communication_style.md
|   +-- topic_interests.md
+-- relationships/
|   +-- contacts/
|   +-- interaction_history/
+-- knowledge/
|   +-- domain_expertise/
|   +-- learned_skills/
+-- context/
    +-- recent_conversations/
    +-- pending_tasks/
```

## Core Features

| Capability | Description |
|------------|-------------|
| 24/7 Proactive Agent | Always-on memory, never sleeps, never forgets |
| User Intention Capture | Understands and remembers goals/preferences across sessions |
| Cost Efficient | Reduces token costs by caching insights, avoiding redundant LLM calls |

## Hierarchical Memory Architecture (3 Layers)

| Layer | Reactive Use | Proactive Use |
|-------|-------------|---------------|
| Resource | Direct access to original data | Background monitoring for patterns |
| Item | Targeted fact retrieval | Real-time extraction from interactions |
| Category | Summary-level overview | Automatic context assembly for anticipation |

## Installation

### Cloud Version
- Website: https://memu.so
- API Base URL: `https://api.memu.so`
- Auth: `Authorization: Bearer YOUR_API_KEY`

### Cloud API (v3)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v3/memory/memorize` | Register continuous learning task |
| GET | `/api/v3/memory/memorize/status/{task_id}` | Check processing status |
| POST | `/api/v3/memory/categories` | List auto-generated categories |
| POST | `/api/v3/memory/retrieve` | Query memory (supports proactive context) |

### Self-Hosted

```bash
pip install -e .
```

With PostgreSQL + pgvector:
```bash
docker run -d --name memu-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=memu \
  -p 5432:5432 pgvector/pgvector:pg16
```

## Core APIs

### memorize() - Continuous Learning Pipeline

```python
result = await service.memorize(
    resource_url="path/to/file.json",
    modality="conversation",       # conversation | document | image | video | audio
    user={"user_id": "123"}        # Optional: scope to user
)

# Returns:
{
    "resource": {...},      # Stored resource metadata
    "items": [...],         # Extracted memory items (available instantly)
    "categories": [...]     # Auto-updated category structure
}
```

### retrieve() - Dual-Mode Intelligence

#### RAG-based (Fast Context)
- Sub-second memory surfacing
- Continuous background monitoring
- Similarity scoring

#### LLM-based (Deep Reasoning)
- Intent prediction
- Query evolution
- Early termination

| Aspect | RAG | LLM |
|--------|-----|-----|
| Speed | Milliseconds | Seconds |
| Cost | Embedding only | LLM inference |
| Proactive use | Continuous monitoring | Triggered loading |
| Best for | Real-time suggestions | Complex anticipation |

```python
result = await service.retrieve(
    queries=[
        {"role": "user", "content": {"text": "What are their preferences?"}},
        {"role": "user", "content": {"text": "Tell me about work habits"}}
    ],
    where={"user_id": "123"},
    method="rag"  # or "llm"
)

# Returns:
{
    "categories": [...],      # Relevant topic areas
    "items": [...],           # Specific memory facts
    "resources": [...],       # Original sources
    "next_step_query": "..."  # Predicted follow-up
}
```

### Proactive Filtering with where

- `where={"user_id": "123"}` - User-specific context
- `where={"agent_id__in": ["1", "2"]}` - Multi-agent coordination
- Omit `where` for global context awareness

## Custom LLM Providers

```python
from memu import MemUService

service = MemUService(
    llm_profiles={
        "default": {
            "base_url": "https://dashscope.aliyuncs.com/compatible-mode/v1",
            "api_key": "your_api_key",
            "chat_model": "qwen3-max",
            "client_backend": "sdk"  # "sdk" or "http" or "httpx"
        },
        "embedding": {
            "base_url": "https://api.voyageai.com/v1",
            "api_key": "your_voyage_api_key",
            "embed_model": "voyage-3.5-lite"
        }
    }
)
```

### Supported Providers

- OpenAI (default)
- Ollama (local)
- OpenRouter (multi-provider gateway)
- DashScope (Alibaba Cloud)
- Voyage AI (embeddings)
- Any OpenAI-compatible API

## Proactive Memory Lifecycle

```
USER QUERY
    |                                  |
    v                                  v
MAIN AGENT                         MEMU BOT
1. Receive user input     1. Monitor input/output
2. Plan & execute         2. Memorize & extract
3. Respond to user        3. Predict user intent
4. Loop                   4. Run proactive tasks
    |                                  |
    +------ CONTINUOUS SYNC LOOP ------+
```

## Proactive Use Cases

1. **Information Recommendation**: Learns interests, surfaces relevant content proactively
2. **Email Management**: Learns patterns, drafts responses, detects conflicts
3. **Trading & Financial Monitoring**: Tracks preferences, correlates events, provides alerts

## memU-server (API Backend)

**Repository**: https://github.com/NevaMind-AI/memU-server
**Local Path**: ~/memU-server/
**Port**: 8000

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/memorize` | Persist conversation for later retrieval |
| POST | `/retrieve` | Query stored memories |
| GET | `/health` | Health check |

### /memorize Request Body

```json
{
  "content": [
    {"role": "user", "content": {"text": "..."}, "created_at": "YYYY-MM-DD HH:MM:SS"},
    {"role": "assistant", "content": {"text": "..."}, "created_at": "YYYY-MM-DD HH:MM:SS"}
  ]
}
```

### /retrieve Request Body

```json
{"query": "your question about the conversation"}
```

### Infrastructure (Docker Compose)

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | 5432 | Database with pgvector extension |
| Temporal | 7233 | Workflow engine gRPC API |
| Temporal UI | 8088 | Web management interface |

### Environment Variables

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=memu
TEMPORAL_DB=temporal
OPENAI_API_KEY=your_key
```

### Docker Deployment

```bash
docker pull nevamindai/memu-server:latest
docker run --rm -p 8000:8000 \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  nevamindai/memu-server:latest
```

## Key Architecture

- **Resource Layer**: Multimodal raw data warehouse
- **Memory Item Layer**: Discrete extracted memory units
- **MemoryCategory Layer**: Aggregated textual memory units
- Full traceability: raw data -> items -> documents and back
- Memory lifecycle: Memorization -> Retrieval -> Self-evolution
- Two retrieval methods: RAG (fast vector search) + LLM (deep semantic understanding)
- Self-evolving: Adapts structure based on usage patterns

## Current System Configuration

### memU Core (~/memU/)
- Python 3.13 venv
- Connected to Ollama for local LLM (qwen2.5-coder:7b)

### memU-server (~/memU-server/)
- FastAPI on port 8000
- PostgreSQL + pgvector on port 5432
- Temporal on port 7233 (UI: 8088)
- Docker Compose for infrastructure

### Integration with Ollama

```python
from memu import MemUService
service = MemUService(
    llm_profiles={
        "default": {
            "base_url": "http://localhost:11434/v1",
            "api_key": "ollama",
            "chat_model": "qwen2.5-coder:7b",
            "client_backend": "httpx"
        }
    }
)
```
