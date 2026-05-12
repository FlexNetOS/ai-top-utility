# AI TOP Rust Rewrite — Implementation Roadmap & Sprint Plan

**Project:** Rebuild Gigabyte AI TOP from Python/JS/Shell (181K LOC) to Rust  
**Timeline:** 24-28 weeks (6-7 months at 1 team)  
**Scope:** Full feature parity + performance improvement  
**Status:** Planning phase  

---

## EXECUTIVE SUMMARY

AI TOP is a system monitoring and ML training orchestration tool with three layers:

| Layer | Current | Target |
|-------|---------|--------|
| **Backend** | Python (99 files, 80K LOC) | Rust workspace |
| **Frontend** | Electron (4 JS files) | Tauri GUI + REST API |
| **DevOps** | Shell scripts (19 files) | Rust + TOML config |
| **ML Interop** | Direct Python calls | PyO3 bindings |

**Compression ratio** on this rewrite: ~30x (human team: 6-8 months → CC+gstack: 1-2 weeks per sprint)

---

## 1. PHASE BREAKDOWN

### PHASE 1: Foundation & Workspace Setup (Weeks 1–2)
**Sprint:** 1-2  
**Objective:** Create Rust workspace, define crate structure, compile successfully  
**Duration:** 2 weeks (10 working days)

#### Deliverables
- [ ] Monorepo Cargo workspace (5+ crates)
- [ ] Base types + serde models for all DTOs
- [ ] Config loader (TOML-based)
- [ ] Logging infrastructure (tracing)
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] `cargo build` succeeds on Linux + macOS + arm64

#### Crates
- `ai-top-core` — shared types, DTOs (cpu_dto, gpu_dto, network_dto, etc.)
- `ai-top-sysmon` — system monitoring (stubs)
- `ai-top-ml` — ML orchestration (stubs)
- `ai-top-api` — REST API server (stubs)
- `ai-top-config` — configuration loader

#### Dependencies
- None (this is the first phase)

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Workspace layout conflicts | LOW | MEDIUM | Use established patterns from RuVector |
| serde/TOML version issues | LOW | LOW | Pin versions early, test on all platforms |

#### Definition of Done
- [x] All 5 crates compile without errors or warnings
- [x] `cargo test` runs (even if test count is 0)
- [x] GitHub Actions CI passes
- [x] README explains crate structure and build process

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| Workspace setup + Cargo.toml | 4 hours | 15 min | Boilerplate |
| Base types (DTOs) | 2 days | 20 min | Boilerplate |
| Config loader skeleton | 1 day | 15 min | Boilerplate |
| Logging setup | 2 hours | 10 min | Boilerplate |
| CI/CD (GitHub Actions) | 4 hours | 30 min | Boilerplate |
| **TOTAL** | **4.5 days** | **~2 hours** | **~100x compression** |

---

### PHASE 2: System Monitoring Core (Weeks 3–5)
**Sprint:** 3-4  
**Objective:** Read CPU, GPU, RAM, SSD, network stats; serve via REST API  
**Duration:** 3 weeks (15 working days)

#### Deliverables
- [ ] CPU monitoring (cores, frequency, temp, load)
- [ ] GPU monitoring (NVIDIA/AMD via sysfs/nvidia-smi)
- [ ] RAM monitoring (used, available, percent)
- [ ] SSD/storage monitoring (mount points, usage)
- [ ] Network monitoring (interfaces, TX/RX rates)
- [ ] REST API endpoints for all metrics
- [ ] SQLite schema for logging historical data
- [ ] M2 Checkpoint: `GET /api/system/stats` returns full system snapshot

#### Crates
- `ai-top-sysmon` (expand) — all monitoring modules
- `ai-top-api` (expand) — REST endpoints (actix-web)
- `ai-top-db` — SQLite integration (rusqlite)

#### Dependencies
- PHASE 1 (foundation must be complete)

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| GPU driver parsing inconsistent | HIGH | HIGH | Test on real NVIDIA/AMD hardware early; add driver detection layer |
| Linux-only syscall assumptions | MEDIUM | MEDIUM | Use procfs/sysfs crates; test on macOS/WSL2 |
| Performance regression in polling | MEDIUM | LOW | Benchmark polling frequency; cache non-changing values |

#### Definition of Done
- [x] All system stat endpoints return correct values
- [x] Integration tests verify stats against system commands (`lscpu`, `nvidia-smi`, etc.)
- [x] REST API follows JSON:API spec
- [x] Error responses include proper HTTP codes + messages
- [x] Performance: stats query <100ms under normal load

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| CPU monitoring | 2 days | 20 min | Feature impl |
| GPU monitoring (NVIDIA) | 3 days | 45 min | Feature impl + research |
| GPU monitoring (AMD ROCm) | 3 days | 45 min | Feature impl + research |
| RAM/SSD/Network | 2 days | 30 min | Feature impl |
| REST API scaffold (actix-web) | 1 day | 15 min | Boilerplate |
| SQLite integration | 1 day | 20 min | Feature impl |
| Integration tests + benchmarks | 2 days | 30 min | Testing |
| **TOTAL** | **14 days** | **3 hours** | **~28x compression** |

---

### PHASE 3: ML Training Orchestration — Part A (Weeks 6–8)
**Sprint:** 5-6  
**Objective:** PyO3 bindings for LLaMA-Factory + core training loop  
**Duration:** 3 weeks (15 working days)

#### Deliverables
- [ ] PyO3 bindings for LLaMA-Factory (finetune entry point)
- [ ] Training session model (tracks state, loss, checkpoints)
- [ ] Training start/stop/pause commands
- [ ] Loss logging to database
- [ ] WebSocket streaming of training metrics
- [ ] M3 Checkpoint: Can start LLaMA-Factory training job via Rust API

#### Crates
- `ai-top-ml` (expand) — PyO3 bindings + training orchestration
- `ai-top-db` (expand) — training log schema

#### Dependencies
- PHASE 1, PHASE 2

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| PyO3 version incompatibility with LLaMA-Factory | HIGH | HIGH | Pin PyO3 early; test integration on Ubuntu 22.04/24.04; use minimal wrapper |
| Python GIL deadlock in training loop | MEDIUM | HIGH | Use tokio::task::spawn_blocking for PyO3 calls; avoid holding GIL across awaits |
| LLaMA-Factory API instability | MEDIUM | MEDIUM | Vendorize critical functions; add timeout wrapper; graceful fallback |
| Memory leaks in PyO3 bindings | MEDIUM | HIGH | Use maturin build tool; run valgrind + address-sanitizer in CI |

#### Definition of Done
- [x] PyO3 module compiles without warnings
- [x] Can call LLaMA-Factory `finetune()` from Rust
- [x] Training metrics logged to SQLite
- [x] WebSocket delivers loss updates in real-time
- [x] Stress test: 10 sequential training runs without memory leaks

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| PyO3 setup + maturin | 1 day | 15 min | Boilerplate |
| LLaMA-Factory binding minimal wrapper | 2 days | 45 min | Feature impl + research |
| Training session state machine | 2 days | 30 min | Feature impl |
| Loss/metric logging | 1 day | 20 min | Feature impl |
| WebSocket streaming | 1 day | 20 min | Feature impl |
| Integration tests (real training run) | 2 days | 30 min | Testing |
| Memory profiling + leak detection | 1 day | 30 min | Testing |
| **TOTAL** | **10 days** | **3 hours** | **~20x compression** |

---

### PHASE 4: ML Training Orchestration — Part B (Weeks 9–11)
**Sprint:** 7-8  
**Objective:** Multi-framework support (LLaVA, Megatron-DeepSpeed), advanced training options  
**Duration:** 3 weeks (15 working days)

#### Deliverables
- [ ] Video-LLaVA training bindings
- [ ] Megatron-DeepSpeed distributed training wrapper
- [ ] Training option builder (learning rate, batch size, epochs, etc.)
- [ ] Model conversion pipeline (checkpoint → ONNX/safetensors)
- [ ] Multi-node training coordinator
- [ ] M4 Checkpoint: Train LLaVA on multi-GPU; convert model to portable format

#### Crates
- `ai-top-ml` (expand) — additional framework bindings
- `ai-top-model-convert` — model conversion utilities

#### Dependencies
- PHASE 3 (PyO3 infrastructure), PHASE 1

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Megatron-DeepSpeed distributed training complexity | HIGH | HIGH | Start with single-node setup first; wrap only essential functions; add distributed troubleshooting logs |
| Model conversion format incompatibilities | MEDIUM | MEDIUM | Test conversion against official tools (diffusers, transformers); add schema validation |
| NCCL/gloo dependency version conflicts | MEDIUM | HIGH | Vendor or pin versions; create Docker image with known-good stack |

#### Definition of Done
- [x] All three frameworks (LLaMA-Factory, LLaVA, Megatron-DeepSpeed) callable from Rust
- [x] Training options builder covers 20+ parameters (no hardcoding)
- [x] Model conversion produces valid outputs (verified by loading in transformers)
- [x] Multi-node training runs on 2+ GPUs
- [x] Telemetry: track GPU utilization, memory, throughput during training

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| Video-LLaVA binding | 2 days | 30 min | Feature impl |
| Megatron-DeepSpeed wrapper | 3 days | 45 min | Feature impl + research |
| Training option builder | 2 days | 30 min | Feature impl |
| Model conversion (checkpoint → portable) | 2 days | 30 min | Feature impl |
| Multi-node orchestration | 2 days | 30 min | Feature impl |
| Integration tests (real multi-GPU runs) | 2 days | 45 min | Testing |
| **TOTAL** | **13 days** | **3.5 hours** | **~18x compression** |

---

### PHASE 5: Chat & Inference (Weeks 12–14)
**Sprint:** 9-10  
**Objective:** Real-time chat inference + RAG pipeline  
**Duration:** 3 weeks (15 working days)

#### Deliverables
- [ ] Chat session management (SQLite-backed)
- [ ] Text-to-text inference (llama.cpp, transformers via PyO3)
- [ ] Streaming responses (Server-Sent Events)
- [ ] RAG pipeline (document embeddings, semantic search)
- [ ] Image-to-text inference (for vision models)
- [ ] Vector database integration (sqlite-vec or qdrant)
- [ ] M5 Checkpoint: Chat endpoint serves LLM responses in real-time; RAG retrieves relevant docs

#### Crates
- `ai-top-inference` — inference orchestration
- `ai-top-rag` — RAG pipeline
- `ai-top-chat` — chat session management
- `ai-top-embeddings` — embedding model wrappers

#### Dependencies
- PHASE 3 (ML infrastructure), PHASE 2 (API framework)

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Streaming response latency (SSE vs WebSocket) | MEDIUM | MEDIUM | Benchmark both; offer both options; add configurable batch sizes |
| Vector DB scaling for large document corpora | MEDIUM | MEDIUM | Use sqlite-vec for embedded; plan Qdrant integration; add pagination to search |
| Embedding model memory footprint | HIGH | MEDIUM | Use smaller models (e2small, minilm); add quantization; allow user to select model |

#### Definition of Done
- [x] Chat endpoint (`POST /api/chat/message`) returns streamed responses
- [x] RAG retrieval (`POST /api/rag/search`) finds relevant documents within 500ms
- [x] Vision model (llava) returns image descriptions
- [x] Chat history persists in SQLite
- [x] Integration test: ask question → retrieve docs → stream answer

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| Chat session manager | 1 day | 15 min | Feature impl |
| Text inference (llama.cpp) | 2 days | 30 min | Feature impl |
| Streaming responses (SSE) | 1 day | 20 min | Feature impl |
| RAG pipeline (embeddings + search) | 2 days | 30 min | Feature impl |
| Vision model inference | 1 day | 20 min | Feature impl |
| Vector DB integration | 1 day | 20 min | Feature impl |
| Integration tests + benchmarks | 2 days | 30 min | Testing |
| **TOTAL** | **10 days** | **2.5 hours** | **~24x compression** |

---

### PHASE 6: Configuration & Model Management (Weeks 15–17)
**Sprint:** 11-12  
**Objective:** TOML config, model download/cache, environment setup  
**Duration:** 3 weeks (15 working days)

#### Deliverables
- [ ] TOML config schema (training, inference, models, paths)
- [ ] Model registry (HuggingFace integration, local cache)
- [ ] Model download + progress tracking
- [ ] Environment validation (CUDA/ROCm, dependencies)
- [ ] Conda environment auto-setup (via Rust subprocess)
- [ ] Docker image generation (optional)
- [ ] M6 Checkpoint: User provides config.toml → system auto-prepares environment + downloads models

#### Crates
- `ai-top-config` (expand) — full schema + validation
- `ai-top-setup` — environment bootstrap
- `ai-top-models` — model registry + download

#### Dependencies
- PHASE 1, PHASE 3, PHASE 4

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Conda environment creation failures on different systems | HIGH | HIGH | Test on Ubuntu 22.04, 24.04, macOS, WSL2; bundle fallback shell script |
| Model download from HF unreliable/slow | MEDIUM | MEDIUM | Add resume capability; mirror option; checksum validation; timeout handling |
| CUDA/ROCm version mismatches | HIGH | HIGH | Auto-detect installed drivers; suggest compatible versions; vendor CUDA stubs for CI |

#### Definition of Done
- [x] Sample config.toml covers all features
- [x] `ai-top setup` reads config, creates conda env, downloads models
- [x] Environment validation catches missing CUDA/ROCm; suggests fixes
- [x] Model cache directory configurable; respects $HOME/.cache
- [x] Integration test: fresh system → config → fully ready setup in <10 min

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| TOML schema design + validation | 2 days | 30 min | Arch + impl |
| Model registry + HF client | 2 days | 30 min | Feature impl |
| Model download + caching | 1 day | 20 min | Feature impl |
| Environment validation | 1 day | 20 min | Feature impl |
| Conda setup automation | 2 days | 30 min | Feature impl + research |
| Docker image + CI integration | 1 day | 20 min | DevOps |
| Integration tests | 2 days | 30 min | Testing |
| **TOTAL** | **11 days** | **3 hours** | **~22x compression** |

---

### PHASE 7: Tauri GUI (Weeks 18–21)
**Sprint:** 13-15  
**Objective:** Dashboard replacing Electron; system + training + chat UIs  
**Duration:** 4 weeks (20 working days)

#### Deliverables
- [ ] Tauri application scaffold (TypeScript + React/Vue)
- [ ] System stats dashboard (live CPU, GPU, RAM, network charts)
- [ ] Training UI (job queue, loss curves, ETA, pause/stop)
- [ ] Chat interface (conversation history, streaming responses)
- [ ] Model manager (list local models, download, delete)
- [ ] Settings panel (TOML editor, env config)
- [ ] M7 Checkpoint: Tauri app displays all major features; replaces Electron

#### Tech Stack
- Tauri v2 (Rust + Rust backend over IPC)
- Frontend: React + TypeScript (or Vue 3)
- Charts: recharts or chart.js
- Styling: TailwindCSS + shadcn/ui

#### Dependencies
- PHASE 2 (system monitoring), PHASE 5 (chat), PHASE 6 (config)

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Tauri + PyO3 interop complexity | HIGH | HIGH | Keep Tauri frontend thin; route all ML calls through REST API, not IPC |
| Chart rendering performance (many data points) | MEDIUM | MEDIUM | Downsample historical data; virtualize tables; lazy-load charts |
| CSS/styling maintenance across platforms | MEDIUM | LOW | Use component library (shadcn/ui); test on Linux, macOS, Windows/WSL2 |

#### Definition of Done
- [x] Tauri app builds on Linux + macOS (Windows/WSL2 optional)
- [x] Dashboard displays CPU, GPU, RAM, network with auto-refresh
- [x] Can start/monitor training jobs from UI
- [x] Chat interface sends/receives messages in real-time
- [x] Model manager shows local + remote models
- [x] No console errors; smooth animations under normal load

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| Tauri project setup | 1 day | 15 min | Boilerplate |
| System stats dashboard | 3 days | 45 min | Feature impl |
| Training UI + job queue | 3 days | 45 min | Feature impl |
| Chat interface | 2 days | 30 min | Feature impl |
| Model manager UI | 1 day | 20 min | Feature impl |
| Settings panel | 1 day | 20 min | Feature impl |
| Integration with REST API | 2 days | 30 min | Feature impl |
| Polish + cross-platform testing | 2 days | 30 min | Testing |
| **TOTAL** | **15 days** | **3.5 hours** | **~26x compression** |

---

### PHASE 8: Testing, Optimization & Release (Weeks 22–28)
**Sprint:** 16-20  
**Objective:** Full feature parity, benchmarking, production readiness  
**Duration:** 6-7 weeks (30-35 working days)

#### Deliverables
- [ ] Integration test suite (100+ tests covering all features)
- [ ] E2E tests (real training runs, RAG queries, etc.)
- [ ] Performance benchmarks (vs Python version)
- [ ] Memory profiling + optimization
- [ ] Security audit (OWASP Top 10, dependency scanning)
- [ ] Documentation (setup, API, ML config, troubleshooting)
- [ ] Release notes + migration guide
- [ ] CI/CD hardening (builds on all platforms)
- [ ] M8 Checkpoint: Feature parity achieved; Rust version faster/more reliable than Python

#### Coverage Goals
- Overall: 80%+
- Core modules (sysmon, ml, api): 90%+
- Edge cases + error paths: 75%+

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Performance regression in specific workloads | MEDIUM | HIGH | Run continuous benchmarks; profile hot paths; compare CPU/memory vs Python baseline |
| Subtle race conditions in concurrent code | MEDIUM | HIGH | Use ThreadSanitizer + Miri; add stress tests; review all unsafe blocks |
| Documentation rot | LOW | MEDIUM | Auto-generate API docs from code comments; create runbooks for common tasks |

#### Definition of Done
- [x] All 100+ integration tests pass on CI
- [x] E2E test: fresh install → full training pipeline → model export → inference in <1 hour
- [x] Benchmarks show ≥20% improvement over Python version (or equivalent with smaller codebase)
- [x] Zero security issues found in audit
- [x] Release notes published; migration guide complete
- [x] GitHub Releases page populated with binaries (Linux, macOS, possibly Windows)

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |
|------|-----------|-----------|------|
| Integration test suite (100+ tests) | 5 days | 1.5 hours | Testing |
| E2E tests (real workloads) | 3 days | 45 min | Testing |
| Performance benchmarking | 2 days | 1 hour | Perf analysis |
| Memory profiling + optimization | 3 days | 1.5 hours | Perf analysis |
| Security audit | 2 days | 1 hour | Security |
| Documentation | 4 days | 1.5 hours | Docs |
| Release prep (binaries, notes, migration) | 2 days | 45 min | DevOps |
| CI/CD hardening | 2 days | 45 min | DevOps |
| **TOTAL** | **23 days** | **8.5 hours** | **~11x compression** |

---

## 2. DEPENDENCY GRAPH

```
PHASE 1 (Foundation)
  ├─→ PHASE 2 (Sysmon) ──→ PHASE 3 (ML-PyO3) ──┬─→ PHASE 4 (ML-Advanced) ──→ PHASE 8 (Release)
  │                              ├─→ PHASE 5 (Chat/Inference) ┘
  │                              └─→ PHASE 6 (Config) ─┐
  │                                                     │
  └─→ PHASE 2 (Sysmon) ────→ PHASE 5 (Chat) ─────────┘
      (REST API ready)          (uses API)      │
                                               │
                    PHASE 7 (Tauri GUI) ←─────┘
                      ↓
                    PHASE 8 (Release)
```

**Critical Path:** PHASE 1 → 2 → 3 → 4 → 6 → 7 → 8 (sequential)  
**Parallel Opportunities:**
- PHASE 5 (Chat) can start once PHASE 2 is done (doesn't depend on PHASE 3/4)
- PHASE 6 (Config) can start once PHASE 1/3 stabilize
- PHASE 7 (GUI) needs PHASE 2, 5, 6 but not all details of 3/4

---

## 3. CRITICAL PATH ANALYSIS

**Longest sequential chain determines minimum project duration:**

```
PHASE 1 (2w) 
  → PHASE 2 (3w) 
  → PHASE 3 (3w) 
  → PHASE 4 (3w) 
  → PHASE 6 (3w) 
  → PHASE 7 (4w) 
  → PHASE 8 (6w)
= 24 weeks minimum
```

**To accelerate:**
1. **Parallelize PHASE 5 (Chat)** with PHASE 3/4 → saves ~2-3 weeks
2. **Start PHASE 6 (Config)** once PHASE 1 + early PHASE 3 done → saves ~1 week
3. **Start PHASE 7 (GUI)** once PHASE 2 endpoints stable → saves ~1-2 weeks

**Realistic timeline (with parallelization):** **20-22 weeks** (5-5.5 months at 1 team)

---

## 4. RISK REGISTER

| # | Risk | Prob | Impact | Severity | Mitigation |
|----|------|------|--------|----------|-----------|
| 1 | PyO3 + LLaMA-Factory incompatibility (version skew) | HIGH | HIGH | **CRITICAL** | Pin versions early (Phase 1); test integration on day 1 of Phase 3; maintain compatibility matrix in docs |
| 2 | Megatron-DeepSpeed distributed training complexity | HIGH | HIGH | **CRITICAL** | Start single-node only; use official examples; wrap essential functions only; add extensive logging |
| 3 | GPU driver parsing fails on customer hardware | HIGH | MEDIUM | **HIGH** | Test on real NVIDIA + AMD hardware by week 5; add fallback to `nvidia-smi`/`rocm-smi`; driver detection layer |
| 4 | Memory leaks in PyO3 bindings under stress | MEDIUM | HIGH | **HIGH** | Run valgrind + Address Sanitizer in CI from Phase 3 onward; stress test 100+ training runs |
| 5 | Tauri + REST API over IPC latency issues | MEDIUM | MEDIUM | **HIGH** | Keep Tauri thin (presentation only); measure latency early; may switch to native Rust UI if problematic |
| 6 | Documentation debt accumulates | MEDIUM | MEDIUM | **MEDIUM** | Allocate 20% of Phase 8 for docs; write as-you-build; auto-generate API docs from code |
| 7 | Model download from HuggingFace unreliable | MEDIUM | MEDIUM | **MEDIUM** | Add resume capability; local cache; checksum validation; timeout handling; mirror option |
| 8 | Performance regression vs Python (worst case) | LOW | MEDIUM | **MEDIUM** | Benchmark continuously from Phase 2; profile hot paths; Rust should be 20%+ faster by Phase 8 |
| 9 | CI/CD flakiness (intermittent test failures) | MEDIUM | LOW | **MEDIUM** | Isolate tests; use fixtures; avoid real GPU calls in most tests; mock ML frameworks |
| 10 | Conda environment setup failures on WSL2/macOS | HIGH | MEDIUM | **HIGH** | Test on all three platforms by Phase 6; bundle fallback shell scripts; create Docker image |

---

## 5. MILESTONE CHECKPOINTS

| Milestone | Sprint | Expected Date | Demo | Success Criteria |
|-----------|--------|----------------|------|------------------|
| **M0: Kickoff** | — | Week 0 | Architecture doc | Crate structure agreed; team aligned |
| **M1: Foundation** | 1-2 | Week 2 | `cargo build` passes | Workspace compiles; CI/CD working |
| **M2: Sysmon** | 3-4 | Week 5 | `GET /api/system/stats` | CPU/GPU/RAM/network readings accurate |
| **M3: ML Binding** | 5-6 | Week 8 | Start LLaMA training via API | PyO3 working; loss logged |
| **M4: Multi-Framework** | 7-8 | Week 11 | Train LLaVA + export model | LLaVA + DeepSpeed working; conversion pipeline |
| **M5: Chat + RAG** | 9-10 | Week 14 | Chat endpoint streams response | Inference + RAG retrieval <500ms |
| **M6: Config + Setup** | 11-12 | Week 17 | User runs `ai-top setup` → ready | Auto-env setup; model download working |
| **M7: GUI** | 13-15 | Week 21 | Tauri app launches with dashboard | Dashboard, training UI, chat, model manager |
| **M8: Release** | 16-20 | Week 28 | v1.0 ships | Feature parity + 20% perf improvement |

---

## 6. EFFORT ESTIMATES (SUMMARY)

### Total Project Effort

| Phase | Human-Team Days | CC+gstack Hours | Compression | Notes |
|-------|-----------------|-----------------|-------------|-------|
| 1: Foundation | 4.5 | 2 | ~100x | Boilerplate-heavy |
| 2: Sysmon | 14 | 3 | ~28x | Feature impl + research |
| 3: ML-PyO3 | 10 | 3 | ~20x | Complex integration |
| 4: ML-Advanced | 13 | 3.5 | ~18x | Framework diversity |
| 5: Chat/RAG | 10 | 2.5 | ~24x | Feature impl + testing |
| 6: Config/Setup | 11 | 3 | ~22x | Env complexity |
| 7: Tauri GUI | 15 | 3.5 | ~26x | UI/UX + cross-platform |
| 8: Test/Release | 23 | 8.5 | ~11x | Comprehensive testing |
| **TOTAL** | **100.5 days** | **32 hours** | **~19x** | ~20 weeks @ 1 team |

### Breakdown by Task Type

| Task Type | Human Days | CC+gstack Hours | Compression |
|-----------|-----------|-----------------|-------------|
| Boilerplate/Scaffolding | 15 | 1 | ~100x |
| Feature Implementation | 50 | 1.5 | ~30x |
| Testing (unit + integration) | 20 | 0.75 | ~50x |
| Architecture/Design | 10 | 4 | ~5x |
| Documentation | 4 | 1.5 | ~8x |
| DevOps/CI | 2 | 1 | ~5x |
| **TOTAL** | **100.5** | **32** | **~19x** |

### Timeline Scenarios

**Scenario A: One full-time engineer**
- Actual effort: ~20 weeks (100 days ÷ 5 days/week)
- With CC+gstack: ~1-2 weeks per sprint
- Wall-clock time: 24-28 weeks (5.5-6.5 months)

**Scenario B: Two engineers (50% parallelization)**
- Actual effort: ~10 weeks (50 days each)
- Wall-clock time: 12-14 weeks (3-3.5 months)
- Phases 5/6 run in parallel with 3/4

**Scenario C: Full team (3+ engineers, 70% parallelization)**
- Actual effort: ~7 weeks (33 days each)
- Wall-clock time: 8-10 weeks (2-2.5 months)
- Phases 5/6/7 run in parallel with 3/4

---

## 7. RESOURCE ALLOCATION & BURNDOWN

### Per-Phase Resource Needs

| Phase | Primary Skills | Secondary Skills | Hours/Week | Slack |
|-------|----------------|-----------------|-----------|-------|
| 1 | Rust fundamentals, Cargo | DevOps (CI/CD) | 20 | 2 |
| 2 | Systems programming, procfs | Testing, debugging | 40 | 5 |
| 3 | PyO3 + FFI, Python internals | Memory profiling | 40 | 10 |
| 4 | ML frameworks, distributed training | CUDA/ROCm drivers | 40 | 10 |
| 5 | Async Rust (tokio), streaming | NLP/embeddings | 35 | 5 |
| 6 | Config design, automation | Shell scripting, DevOps | 30 | 3 |
| 7 | Tauri, React/Vue, CSS | UX/design | 30 | 5 |
| 8 | Testing, profiling, security | Release engineering | 35 | 5 |

---

## 8. DEFINITION OF DONE (PROJECT-LEVEL)

Before shipping v1.0:

**Functionality**
- [x] All 8 core subsystems operational (sysmon, ML, chat, RAG, config, GUI, API, DB)
- [x] Feature parity with Python version (all major features)
- [x] No critical bugs in issue tracker

**Quality**
- [x] 80%+ test coverage across codebase
- [x] Zero memory leaks (valgrind clean)
- [x] Zero security issues (audit complete)
- [x] All CI checks passing (build, test, lint, format)

**Performance**
- [x] 20%+ faster than Python version (same workload)
- [x] System stats query <100ms
- [x] Chat streaming latency <200ms per token
- [x] RAG search <500ms for 10K-doc corpus

**Documentation**
- [x] API documentation (auto-generated)
- [x] Setup guide (Linux, macOS, Windows/WSL2)
- [x] ML training walkthrough
- [x] Configuration reference
- [x] Troubleshooting guide

**Release**
- [x] GitHub Releases with binaries (Linux + macOS)
- [x] Changelog summarizing major changes
- [x] Migration guide for Python users
- [x] Docker image for quick start (optional)

---

## 9. SKILL & TOOLING MATRIX

### Required Expertise by Phase

| Expertise | Phase | Depth | Tools |
|-----------|-------|-------|-------|
| Rust (async, FFI, macros) | All | **Expert** | tokio, PyO3, maturin, tracing |
| Systems programming | 2, 6 | **Expert** | procfs, sysfs, libc, nix crate |
| ML frameworks | 3, 4 | **Intermediate** | transformers, llama-factory, torch, CUDA/ROCm |
| PyO3/Python C API | 3, 4 | **Advanced** | pyo3, maturin, GIL management |
| Database | 2, 5, 6 | **Intermediate** | SQLite, rusqlite, sqlx, migrations |
| Web/REST API | 2, 5 | **Intermediate** | actix-web, tokio, serde, openapi |
| UI/Frontend | 7 | **Intermediate** | Tauri, React/Vue, TypeScript, TailwindCSS |
| DevOps/CI | 1, 8 | **Intermediate** | GitHub Actions, Docker, shell scripting |
| Security | 8 | **Intermediate** | OWASP Top 10, dependency scanning, fuzzing |

### Recommended Tools & Crates

**Core Infrastructure**
- Tokio — async runtime
- Serde — serialization
- Tracing — structured logging
- Anyhow — error handling

**Systems**
- procfs — Linux /proc parsing
- sysinfo — cross-platform system stats
- nix — POSIX syscalls

**ML/PyO3**
- pyo3 — Python bindings
- maturin — Python package builder
- candle — lightweight ML (alternative to PyO3)

**Database**
- rusqlite — SQLite (sync)
- sqlx — SQL toolkit (async, compile-time checked)
- migrations — schema versioning

**Web**
- actix-web — HTTP server
- tokio-tungstenite — WebSocket
- serde_json + toml — serialization

**GUI**
- Tauri v2 — desktop app framework
- React/Vue — frontend framework
- TailwindCSS — styling
- shadcn/ui — component library

**Testing & Profiling**
- Criterion — benchmarking
- Proptest — property testing
- Valgrind — memory profiling
- ThreadSanitizer — race detection

---

## 10. DECISION MATRIX: KEY ARCHITECTURAL CHOICES

| Decision | Options | Chosen | Rationale |
|----------|---------|--------|-----------|
| **GUI Framework** | Tauri vs Native (gtk/cocoa) vs Web-only | Tauri | Rust-native, cross-platform, smaller footprint than Electron |
| **ML Framework Bindings** | PyO3 vs Candle vs ONNX Runtime | PyO3 | Reuse existing Python ecosystem (LLaMA-Factory, transformers); proven in prod |
| **Database** | PostgreSQL vs SQLite vs RocksDB | SQLite | Embedded, zero-config, sufficient for single-instance monitoring |
| **REST API** | Actix-web vs Axum vs Rocket | Actix-web | Mature, performant, good ecosystem; Axum option if needs simplicity |
| **Async Runtime** | Tokio vs async-std | Tokio | Industry standard; used by actix-web, tungstenite, most crates |
| **Config Format** | TOML vs YAML vs JSON | TOML | Rusty, less verbose than YAML, human-readable unlike JSON |
| **Vector DB** | sqlite-vec vs Qdrant vs Milvus | sqlite-vec (primary), Qdrant (scaling) | Embedded option for simplicity; Qdrant if scaling needed |

---

## 11. SUCCESS METRICS & ACCEPTANCE CRITERIA

**At Project Completion (Phase 8):**

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Feature Parity** | 100% | Feature checklist vs Python version |
| **Test Coverage** | 80%+ | `cargo tarpaulin` report |
| **Performance** | 20%+ faster | Benchmark suite vs baseline |
| **Memory Usage** | 30-40% of Python | RSS under same workload |
| **P99 Latency (API)** | <500ms | Load test results |
| **Uptime (24h soak)** | 99.9%+ | No crashes/leaks over 24 hours |
| **Security Issues** | 0 critical | Audit report |
| **Documentation** | 95%+ API docs | Auto-generated + manual guides |

---

## 12. ROLLOUT STRATEGY

### Beta Release (End of Phase 7)
- Feature-freeze branch
- Intensive QA + bug fixing
- Soft launch to 5-10 power users
- Collect feedback + adjust

### v1.0 Release (Phase 8, Week 28)
- All features verified
- Performance benchmarks complete
- Security audit passed
- Binaries shipped (Linux, macOS)
- Full documentation published

### v1.1+ (Post-Release)
- Windows/WSL2 support
- Advanced features (multi-node coordination, advanced RAG)
- Performance tuning based on real-world usage
- Community contributions

---

## 13. CONTINGENCY & ESCALATION

**If Major Blocker Found:**

1. **PyO3 Incompatibility** (e.g., LLaMA-Factory breaks with PyO3 latest):
   - **Option A:** Vendorize critical LLaMA-Factory functions; rewrite in Rust
   - **Option B:** Use Candle (Hugging Face's native Rust ML library)
   - **Timeline impact:** +2-4 weeks

2. **Megatron-DeepSpeed Complexity** (distributed training not feasible):
   - **Option A:** Support single-GPU training only; document limitations
   - **Option B:** Partner with external distributed training service (Ray, Kubeflow)
   - **Timeline impact:** -2 weeks (scope reduction) or +3 weeks (external integration)

3. **Performance Regression** (Rust version slower than Python):
   - **Action:** Profile hot paths; optimize allocations; consider C FFI for compute kernels
   - **Timeline impact:** +1-2 weeks in Phase 8

---

## 14. NEXT STEPS (IMMEDIATE)

**Week 0 (This Week):**
- [ ] Finalize team + assign phase leads
- [ ] Set up GitHub repo + branch protection
- [ ] Create Cargo workspace scaffold (Phase 1)
- [ ] Schedule Phase 1 kickoff

**Week 1-2 (Phase 1):**
- [ ] Build Cargo workspace
- [ ] Generate all DTO types (serde)
- [ ] Set up tracing/logging
- [ ] Configure CI/CD

**Week 3 (Phase 2 Start):**
- [ ] Implement CPU monitoring
- [ ] Deploy REST API scaffold
- [ ] Start integration tests

---

## APPENDIX: PHASE DETAIL TEMPLATES

### Phase Template (Copy for new phases)

```markdown
### PHASE X: [Name] (Weeks N–M)
**Sprint:** N-M  
**Objective:** [Clear, buildable objective]  
**Duration:** X weeks (Y working days)

#### Deliverables
- [ ] Feature 1
- [ ] Feature 2

#### Crates
- `crate-name` — description

#### Dependencies
- PHASE N (required feature)

#### Risk Assessment
| Risk | Probability | Impact | Mitigation |

#### Definition of Done
- [x] Criterion 1
- [x] Criterion 2

#### Effort Estimate
| Task | Human Team | CC+gstack | Type |

**TOTAL:** X days | Y hours | Zx compression
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-04-02  
**Author:** Hive Team Charlie (Haiku Queen Coordinator)  
**Status:** Ready for Planning Phase

