# AI TOP Rust Workspace Architecture

Complete Rust workspace design for rebuilding the Gigabyte AI TOP Utility.
Replaces: 99 Python files (~180K LOC), 4 Electron/JS files, 19 shell scripts,
and the 107MB `main2404` compiled binary.

---

## 1. Workspace Layout

```toml
# Cargo.toml (workspace root)
[workspace]
resolver = "2"
members = [
    "crates/aitop-core",
    "crates/aitop-hw",
    "crates/aitop-config",
    "crates/aitop-model-hub",
    "crates/aitop-inference",
    "crates/aitop-finetune",
    "crates/aitop-rag",
    "crates/aitop-chat",
    "crates/aitop-dataset",
    "crates/aitop-ml",
    "crates/aitop-multinode",
    "crates/aitop-setup",
    "crates/aitop-api",
    "crates/aitop-cli",
    "crates/aitop-gui",
]

[workspace.package]
version = "0.1.0"
edition = "2024"
license = "Proprietary"
repository = "https://github.com/FlexNetOS/ai-top"

[workspace.dependencies]
# Async runtime
tokio = { version = "1", features = ["full"] }
# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"
toml = "0.8"
# Error handling
thiserror = "2"
anyhow = "1"
# Logging
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }
# HTTP
axum = { version = "0.8", features = ["ws", "multipart"] }
tower = "0.5"
tower-http = { version = "0.6", features = ["cors", "trace", "fs"] }
reqwest = { version = "0.12", features = ["json", "stream"] }
# Database
sqlx = { version = "0.8", features = ["runtime-tokio", "postgres", "migrate"] }
# GPU / Hardware
nvml-wrapper = "0.10"           # NVIDIA Management Library
sysinfo = "0.33"                # Cross-platform CPU/RAM/disk
# ML inference
llama-cpp-rs = "0.4"            # llama.cpp bindings (GGUF)
candle-core = "0.8"             # Pure Rust ML tensors
candle-nn = "0.8"
candle-transformers = "0.8"
# Python interop (for frameworks that have no Rust equivalent)
pyo3 = { version = "0.23", features = ["auto-initialize"] }
# GUI
tauri = "2"
# CLI
clap = { version = "4", features = ["derive"] }
# Testing
assert_cmd = "2"
tempfile = "3"
mockall = "0.13"
```

```
ai-top/
+-- Cargo.toml                    # workspace root
+-- crates/
|   +-- aitop-core/               # shared domain types
|   +-- aitop-hw/                 # hardware abstraction
|   +-- aitop-config/             # configuration management
|   +-- aitop-model-hub/          # model download & management
|   +-- aitop-inference/          # inference engines
|   +-- aitop-finetune/           # fine-tuning orchestration
|   +-- aitop-rag/                # RAG pipeline
|   +-- aitop-chat/               # chat interface
|   +-- aitop-dataset/            # dataset generation
|   +-- aitop-ml/                 # classical ML pipeline
|   +-- aitop-multinode/          # multi-node coordination
|   +-- aitop-setup/              # system provisioning
|   +-- aitop-api/                # REST/WebSocket API server
|   +-- aitop-cli/                # CLI binary
|   +-- aitop-gui/                # Tauri GUI binary
+-- config/
|   +-- default.toml              # default config
|   +-- local.toml.example        # local override template
+-- migrations/                   # sqlx migrations
+-- tests/                        # integration tests
+-- scripts/                      # build/release automation
+-- LICENSE.txt
+-- ARCHITECTURE.md               # this file
```

---

## 2. Per-Crate Design

### 2.1 `aitop-core` (lib)

**Purpose**: Shared domain types, error enums, and trait definitions used across
every other crate. Zero external dependencies beyond `serde` and `thiserror`.

**Replaces**: `backend/lib/source/core/dto/system/*.py` (cpu_dto, gpu_dto, ram_dto,
ssd_dto, network_dto, ip_dto, system_dto, vendor_dto), `core/tool/formatter.py`

**Key modules**:

```
src/
  lib.rs
  error.rs          # AitopError enum (workspace-wide)
  hw/
    mod.rs
    cpu.rs          # CpuInfo, CpuArch enum
    gpu.rs          # GpuInfo, GpuVendor enum, GpuMemory
    ram.rs          # RamInfo
    disk.rs         # DiskInfo, DiskKind enum
    network.rs      # NetworkInterface, IpAddr wrapper
    system.rs       # SystemInfo (aggregate)
    vendor.rs       # HardwareVendor enum
  model/
    mod.rs
    metadata.rs     # ModelMetadata, ModelFormat enum
    quantization.rs # QuantizationLevel enum
  training/
    mod.rs
    job.rs          # TrainingJob, TrainingStatus enum
    metrics.rs      # LossMetrics, TrainingProgress
    schedule.rs     # ScheduleConfig
  format.rs         # Output formatters (table, JSON, CSV)
```

**Key types**:

```rust
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum GpuVendor {
    Nvidia,
    Amd,
    Intel,
    Unknown,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum GpuComputeApi {
    Cuda { version: (u8, u8) },
    Rocm { version: (u8, u8) },
    OneApi,
    None,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GpuInfo {
    pub index: u32,
    pub name: String,
    pub vendor: GpuVendor,
    pub compute: GpuComputeApi,
    pub vram_total_mb: u64,
    pub vram_used_mb: u64,
    pub temperature_c: Option<f32>,
    pub utilization_pct: Option<f32>,
    pub power_watts: Option<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CpuInfo {
    pub model_name: String,
    pub arch: CpuArch,
    pub cores_physical: u32,
    pub cores_logical: u32,
    pub frequency_mhz: u64,
    pub utilization_pct: f32,
    pub temperature_c: Option<f32>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CpuArch { X86_64, Aarch64, Other }

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SystemInfo {
    pub cpu: CpuInfo,
    pub gpus: Vec<GpuInfo>,
    pub ram: RamInfo,
    pub disks: Vec<DiskInfo>,
    pub network: Vec<NetworkInterface>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ModelFormat {
    Safetensors,
    Gguf,
    Ggml,
    Pytorch,
    Onnx,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelMetadata {
    pub id: String,
    pub name: String,
    pub format: ModelFormat,
    pub size_bytes: u64,
    pub quantization: Option<QuantizationLevel>,
    pub path: PathBuf,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TrainingStatus {
    Queued,
    Running { epoch: u32, loss: f64, progress_pct: f32 },
    Completed { final_loss: f64, duration_secs: u64 },
    Failed { error: String },
    Cancelled,
}

#[derive(Debug, thiserror::Error)]
pub enum AitopError {
    #[error("hardware detection failed: {0}")]
    Hardware(String),
    #[error("model not found: {id}")]
    ModelNotFound { id: String },
    #[error("inference error: {0}")]
    Inference(String),
    #[error("training error: {0}")]
    Training(String),
    #[error("configuration error: {0}")]
    Config(String),
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("database error: {0}")]
    Database(String),
    #[error("network error: {0}")]
    Network(String),
}
```

**Dependencies**: `serde`, `thiserror`

---

### 2.2 `aitop-hw` (lib)

**Purpose**: Hardware detection and real-time monitoring. Polls GPU, CPU, RAM,
disk, and network status. Provides async streams of metrics for the dashboard.

**Replaces**: `backend/lib/source/system_info.py`, `core/dto/system/*.py` (runtime
collection), `core/log/system_info_log.py`, `core/setting_SSDs/Mount_SSD.py`,
`core/setting_SSDs/Show_SSDs.py`

**Key modules**:

```
src/
  lib.rs
  detect.rs         # One-shot hardware detection
  monitor.rs        # Async polling loop (tokio::interval)
  nvidia.rs         # NVML wrapper (nvml-wrapper crate)
  amd.rs            # ROCm SMI via sysfs + /opt/rocm/bin/rocm-smi
  intel.rs          # Intel GPU via sysfs
  disk.rs           # SSD detection, mount, SMART
  traits.rs         # GpuBackend trait
```

**Key traits**:

```rust
/// Trait for GPU vendor backends. Each vendor implements this.
#[async_trait]
pub trait GpuBackend: Send + Sync {
    /// Detect all GPUs of this vendor
    async fn detect(&self) -> Result<Vec<GpuInfo>, AitopError>;
    /// Poll current utilization for a specific GPU
    async fn poll(&self, index: u32) -> Result<GpuInfo, AitopError>;
    /// Get compute capability string
    fn compute_api(&self) -> GpuComputeApi;
}

/// Async stream of system snapshots at a given interval
pub fn monitor_stream(
    interval: Duration,
) -> impl Stream<Item = SystemInfo> + Send;
```

**Dependencies**: `aitop-core`, `tokio`, `sysinfo`, `nvml-wrapper`, `tracing`

---

### 2.3 `aitop-config` (lib)

**Purpose**: TOML-based configuration with validation at startup. Replaces the
INI-based `local.ini` with a typed, serde-derived config.

**Replaces**: `backend/config/local.ini`, `backend/lib/source/config/*.py`,
`backend/lib/source/LMM_config/*.py`

**Key modules**:

```
src/
  lib.rs
  schema.rs         # AitopConfig struct (top-level)
  database.rs       # DatabaseConfig
  api.rs            # ApiConfig (host, port, CORS)
  training.rs       # TrainingDefaults (batch_size, lr, etc.)
  model.rs          # ModelConfig (download paths, registries)
  validate.rs       # Startup validation logic
```

**Key types**:

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AitopConfig {
    pub database: DatabaseConfig,
    pub api: ApiConfig,
    pub training: TrainingDefaults,
    pub models: ModelConfig,
    pub logging: LogConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatabaseConfig {
    pub enable: bool,
    pub host: String,
    pub port: u16,
    pub database: String,
    pub username: String,
    // password loaded from env var AITOP_DB_PASSWORD, never from file
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiConfig {
    pub host: IpAddr,
    pub port: u16,
    pub cors_origins: Vec<String>,
}

impl AitopConfig {
    /// Load from TOML file, overlay env vars, validate
    pub fn load(path: &Path) -> Result<Self, AitopError>;
}
```

**Dependencies**: `aitop-core`, `serde`, `toml`, `tracing`

---

### 2.4 `aitop-model-hub` (lib)

**Purpose**: Model discovery, download (HuggingFace Hub), storage management,
format detection, and deletion.

**Replaces**: `backend/lib/source/download_model_list/*.py` (download_model,
delete_download_model, download_model_list, get/set_download_model_path),
`core/model_conversion/*.py` (conversion, delete_model, model_options,
show_model_format)

**Key modules**:

```
src/
  lib.rs
  registry.rs       # ModelRegistry trait + HuggingFaceRegistry impl
  download.rs       # Async download with progress (reqwest + tokio)
  storage.rs        # Local model storage (scan, index, delete)
  convert.rs        # Model format conversion (safetensors <-> GGUF)
  format.rs         # Format detection from file headers
```

**Key traits**:

```rust
#[async_trait]
pub trait ModelRegistry: Send + Sync {
    async fn search(&self, query: &str) -> Result<Vec<ModelMetadata>, AitopError>;
    async fn download(
        &self,
        model_id: &str,
        dest: &Path,
        progress: impl Fn(DownloadProgress) + Send,
    ) -> Result<ModelMetadata, AitopError>;
}

pub struct DownloadProgress {
    pub bytes_downloaded: u64,
    pub bytes_total: Option<u64>,
    pub speed_bytes_sec: u64,
}
```

**Dependencies**: `aitop-core`, `tokio`, `reqwest`, `serde_json`, `tracing`

---

### 2.5 `aitop-inference` (lib)

**Purpose**: Unified inference engine with pluggable backends. Supports text
generation, image-text-to-text, text-to-image, and text-to-video.

**Replaces**: `backend/lib/source/inference/*.py` (base, transformers, llamacpp,
image_text_to_text, text_to_image, text_to_video)

**Key modules**:

```
src/
  lib.rs
  engine.rs         # InferenceEngine trait
  llamacpp.rs       # llama.cpp backend via llama-cpp-rs
  candle.rs         # Pure Rust backend via candle
  gguf.rs           # GGUF model loader
  text_gen.rs       # Text generation pipeline
  multimodal.rs     # Image+text input handling
  generation.rs     # Text-to-image / text-to-video (PyO3 bridge)
  sampling.rs       # Temperature, top-k, top-p, repetition penalty
```

**Key traits**:

```rust
#[async_trait]
pub trait InferenceEngine: Send + Sync {
    /// Load a model by path
    async fn load(&mut self, model: &ModelMetadata) -> Result<(), AitopError>;

    /// Generate text completion
    async fn generate(
        &self,
        prompt: &str,
        params: &GenerationParams,
    ) -> Result<InferenceStream, AitopError>;

    /// Unload model from memory
    async fn unload(&mut self) -> Result<(), AitopError>;

    /// Report VRAM usage
    fn vram_usage_mb(&self) -> u64;
}

pub struct GenerationParams {
    pub max_tokens: u32,
    pub temperature: f32,
    pub top_p: f32,
    pub top_k: u32,
    pub repetition_penalty: f32,
    pub stop_sequences: Vec<String>,
}

/// Streaming inference output
pub type InferenceStream = Pin<Box<dyn Stream<Item = Result<String, AitopError>> + Send>>;
```

**Dependencies**: `aitop-core`, `tokio`, `llama-cpp-rs`, `candle-core`,
`candle-nn`, `candle-transformers`, `pyo3` (optional, for diffusion models)

---

### 2.6 `aitop-finetune` (lib)

**Purpose**: Fine-tuning orchestration. Manages training jobs, schedules,
hyperparameter configuration, and log streaming. Delegates to LLaMA-Factory
via subprocess or PyO3.

**Replaces**: `backend/lib/source/finetune.py`, `finetune_options.py`,
`finetune_schedule.py`, `LMM_finetune.py`, `LMM_finetune_options.py`,
`LMM_finetune_schedule.py`, `core/finetune/*.py` (LMM_options, LMM_training,
options, training), `core/log/loss_log.py`, `core/log/training_log.py`

**Key modules**:

```
src/
  lib.rs
  orchestrator.rs   # TrainingOrchestrator (job lifecycle)
  job.rs            # TrainingJob state machine
  options.rs        # Hyperparameter structs (LoRA, QLoRA, full)
  schedule.rs       # Cron-like training scheduler
  log_stream.rs     # Real-time loss/metric streaming
  llama_factory.rs  # LLaMA-Factory subprocess bridge
  megatron.rs       # Megatron-DeepSpeed bridge
```

**Key types**:

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FinetuneOptions {
    pub method: FinetuneMethod,
    pub base_model: String,
    pub dataset_path: PathBuf,
    pub output_dir: PathBuf,
    pub epochs: u32,
    pub batch_size: u32,
    pub learning_rate: f64,
    pub lora: Option<LoraConfig>,
    pub gpu_ids: Vec<u32>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum FinetuneMethod {
    Full,
    Lora,
    Qlora,
    Dpo,
    Ppo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LoraConfig {
    pub rank: u32,
    pub alpha: f32,
    pub dropout: f32,
    pub target_modules: Vec<String>,
}

pub struct TrainingOrchestrator { /* ... */ }

impl TrainingOrchestrator {
    pub async fn submit(&self, opts: FinetuneOptions) -> Result<TrainingJob, AitopError>;
    pub async fn status(&self, job_id: &str) -> Result<TrainingStatus, AitopError>;
    pub async fn cancel(&self, job_id: &str) -> Result<(), AitopError>;
    pub fn log_stream(&self, job_id: &str) -> impl Stream<Item = TrainingLogEntry>;
}
```

**Dependencies**: `aitop-core`, `aitop-hw`, `tokio`, `pyo3`, `tracing`

---

### 2.7 `aitop-rag` (lib)

**Purpose**: Retrieval-Augmented Generation pipeline. Document ingestion,
chunking, embedding, vector storage, and retrieval.

**Replaces**: `backend/lib/source/RAG.py`, `core/RAG/rag_process.py`

**Key modules**:

```
src/
  lib.rs
  ingest.rs         # Document loader (PDF, TXT, MD, DOCX)
  chunk.rs          # Text chunking strategies
  embed.rs          # Embedding generation (candle or API call)
  store.rs          # Vector store trait + SQLite/Qdrant adapters
  retrieve.rs       # Similarity search + reranking
  pipeline.rs       # End-to-end RAG orchestration
```

**Key traits**:

```rust
#[async_trait]
pub trait VectorStore: Send + Sync {
    async fn upsert(&self, docs: &[EmbeddedChunk]) -> Result<(), AitopError>;
    async fn search(
        &self,
        query_embedding: &[f32],
        top_k: usize,
    ) -> Result<Vec<RetrievedChunk>, AitopError>;
    async fn delete(&self, doc_id: &str) -> Result<(), AitopError>;
}

pub struct EmbeddedChunk {
    pub id: String,
    pub doc_id: String,
    pub text: String,
    pub embedding: Vec<f32>,
    pub metadata: serde_json::Value,
}
```

**Dependencies**: `aitop-core`, `aitop-inference`, `tokio`, `candle-core`, `sqlx`

---

### 2.8 `aitop-chat` (lib)

**Purpose**: Chat interface with conversation history, system prompts, and
streaming responses. Glues inference + RAG for context-aware chat.

**Replaces**: `backend/lib/source/Chat.py`, `core/Chat/chat_inference.py`

**Key modules**:

```
src/
  lib.rs
  session.rs        # ChatSession (conversation history)
  router.rs         # Route chat to inference or RAG-augmented
  template.rs       # Prompt template rendering (Jinja2-like)
  stream.rs         # SSE / WebSocket streaming adapter
```

**Dependencies**: `aitop-core`, `aitop-inference`, `aitop-rag`, `tokio`

---

### 2.9 `aitop-dataset` (lib)

**Purpose**: Synthetic dataset generation from LLMs. Produce, recommend,
preview, and save training datasets.

**Replaces**: `backend/lib/source/llm_produce_dataset.py`,
`core/llm_produce_dataset/*.py` (core_llm_produce_dataset, producing,
recommend, saving, showing)

**Key modules**:

```
src/
  lib.rs
  generator.rs      # DatasetGenerator (use inference to produce samples)
  recommend.rs      # Recommend dataset strategies from model type
  preview.rs        # Preview/show generated samples
  export.rs         # Save to JSON, JSONL, CSV, Alpaca format
  schema.rs         # DatasetEntry, DatasetConfig
```

**Dependencies**: `aitop-core`, `aitop-inference`, `tokio`, `serde_json`

---

### 2.10 `aitop-ml` (lib)

**Purpose**: Classical machine learning pipeline. Classification, regression,
anomaly detection, clustering. Uses `linfa` (pure Rust sklearn equivalent).

**Replaces**: `backend/lib/source/config/MachineLearning_config.py` and the
MachineLearning modules referenced by the original `core/` tree.

**Key modules**:

```
src/
  lib.rs
  pipeline.rs       # MlPipeline trait
  classify.rs       # Classification (random forest, logistic regression)
  regress.rs        # Regression (linear, gradient boosted)
  anomaly.rs        # Anomaly detection (isolation forest, LOF)
  cluster.rs        # Clustering (k-means, DBSCAN)
  preprocess.rs     # Feature scaling, encoding, imputation
  evaluate.rs       # Metrics (accuracy, F1, MSE, silhouette)
```

**Dependencies**: `aitop-core`, `linfa`, `linfa-trees`, `linfa-clustering`,
`linfa-linear`, `ndarray`, `csv`

---

### 2.11 `aitop-multinode` (lib)

**Purpose**: Multi-node training coordination. Discover peers, coordinate
distributed training runs, manage SSH tunnels and rank assignment.

**Replaces**: `backend/lib/source/multinode.py`, `core/multinode/multinode_process.py`

**Key modules**:

```
src/
  lib.rs
  discover.rs       # Peer discovery (mDNS or static config)
  coordinator.rs    # Rank assignment, barrier sync
  ssh.rs            # SSH tunnel management (russh crate)
  launch.rs         # Distributed launch (torchrun wrapper)
```

**Dependencies**: `aitop-core`, `tokio`, `russh`, `tracing`

---

### 2.12 `aitop-setup` (lib + bin)

**Purpose**: System provisioning and environment setup. Replaces all 19 shell
scripts with idempotent Rust functions.

**Replaces**: `install-scripts/*.sh` (1_conda*.sh, 2_apt.sh, 3_conda*.sh,
amd_2_rocm.sh, nvidia_driver_cuda.sh, llama_cpp.sh, power_install.sh,
set_cuda_library.sh, after-install.sh, after-remove.sh)

**Key modules**:

```
src/
  lib.rs
  detect.rs         # Detect current system state (what is installed)
  conda.rs          # Conda/Miniforge install + env management
  cuda.rs           # CUDA toolkit detection and setup
  rocm.rs           # ROCm detection and setup
  apt.rs            # APT package installation
  pip.rs            # pip package installation into conda env
  llama_cpp.rs      # Build llama.cpp with correct CUDA arch
  validate.rs       # Post-setup validation checks
  plan.rs           # Diff current vs desired state, produce install plan
  bin/main.rs       # `aitop-setup` CLI binary
```

**Design pattern**: Declarative desired-state. The user specifies what they
want (NVIDIA + CUDA 13 + llama.cpp); the tool diffs against current state
and executes only the missing steps.

**Dependencies**: `aitop-core`, `aitop-hw`, `tokio`, `clap`, `tracing`

---

### 2.13 `aitop-api` (lib)

**Purpose**: HTTP REST + WebSocket API server. Axum-based. Exposes all
functionality over a versioned API on port 8080.

**Replaces**: `backend/main.py` (FastAPI server), `electron/preload.js`
(IPC bridge)

**Key modules**:

```
src/
  lib.rs
  router.rs         # Top-level Axum router
  routes/
    mod.rs
    system.rs       # GET /api/v1/system (hardware info)
    models.rs       # CRUD /api/v1/models (download, list, delete)
    inference.rs    # POST /api/v1/inference/generate (streaming SSE)
    finetune.rs     # POST /api/v1/finetune (submit job, status, cancel)
    rag.rs          # POST /api/v1/rag (ingest, query)
    chat.rs         # WS /api/v1/chat (WebSocket streaming)
    dataset.rs      # POST /api/v1/dataset (generate, export)
    ml.rs           # POST /api/v1/ml (train, predict)
    multinode.rs    # GET /api/v1/cluster (peer status)
  middleware/
    auth.rs         # API key authentication
    rate_limit.rs   # Token bucket rate limiter
    cors.rs         # CORS configuration
  state.rs          # AppState (shared across handlers)
  ws.rs             # WebSocket upgrade + message handling
  error.rs          # Axum error response mapping
```

**Dependencies**: `aitop-core`, `aitop-hw`, `aitop-config`, `aitop-model-hub`,
`aitop-inference`, `aitop-finetune`, `aitop-rag`, `aitop-chat`, `aitop-dataset`,
`aitop-ml`, `aitop-multinode`, `axum`, `tower`, `tower-http`, `tokio`, `tracing`

---

### 2.14 `aitop-cli` (bin)

**Purpose**: Command-line interface for headless / SSH operation. Subcommand-based.

**Replaces**: Direct use of `backend/main.py` in terminal mode.

**Key modules**:

```
src/
  main.rs
  commands/
    mod.rs
    system.rs       # aitop system info
    model.rs        # aitop model list|download|delete|convert
    infer.rs        # aitop infer --model X --prompt "..."
    finetune.rs     # aitop finetune start|status|cancel|schedule
    rag.rs          # aitop rag ingest|query
    chat.rs         # aitop chat (interactive REPL)
    dataset.rs      # aitop dataset generate|export
    ml.rs           # aitop ml train|predict
    cluster.rs      # aitop cluster status|join
    setup.rs        # aitop setup (delegates to aitop-setup)
    serve.rs        # aitop serve (starts API server)
```

**Dependencies**: `aitop-api`, `aitop-config`, `clap`, `tokio`, `anyhow`,
`tracing-subscriber`

---

### 2.15 `aitop-gui` (bin, Tauri)

**Purpose**: Desktop GUI. Tauri 2 application with a web frontend (HTML/CSS/JS).
Calls the Rust backend directly via Tauri commands (no HTTP overhead).

**Replaces**: `electron/` (main.js, preload.js, renderer-app.js, renderer-app.css,
renderer.html), `web-ui/` (index.html, assets/)

**Key modules**:

```
src-tauri/
  src/
    main.rs         # Tauri app entry
    commands/
      mod.rs
      system.rs     # #[tauri::command] fn get_system_info()
      models.rs     # #[tauri::command] fn list_models()
      inference.rs  # #[tauri::command] fn generate()
      finetune.rs   # #[tauri::command] fn start_finetune()
      chat.rs       # #[tauri::command] fn chat()
    state.rs        # Managed Tauri state
src/                # Frontend (HTML/CSS/JS or framework)
  index.html
  app.js
  app.css
```

**Dependencies**: `aitop-core`, `aitop-hw`, `aitop-config`, `aitop-model-hub`,
`aitop-inference`, `aitop-finetune`, `aitop-rag`, `aitop-chat`, `aitop-dataset`,
`aitop-ml`, `tauri`

---

## 3. Cross-Crate Dependency Graph

```
                          aitop-core
                              |
         +--------+-------+--+--+--------+--------+
         |        |       |     |        |        |
     aitop-hw  aitop-   aitop-  |   aitop-ml  aitop-setup
         |     config  model-   |        |        |
         |        |    hub      |        |     aitop-hw
         |        |       |     |        |
         +--------+--+---+     |        |
                      |        |        |
                 aitop-inference         |
                   |    |               |
            +------+    +-------+       |
            |                   |       |
        aitop-rag          aitop-finetune
            |                   |
            +-------+-----------+
                    |
                aitop-chat
                    |
                aitop-dataset
                    |
    +---------------+---------------+
    |               |               |
aitop-api       aitop-cli       aitop-gui
```

Key rules:
- `aitop-core` depends on nothing workspace-internal
- Binary crates (`aitop-cli`, `aitop-gui`) depend on `aitop-api` or directly
  on domain crates, never the reverse
- No circular dependencies (enforced by Cargo workspace resolver)

---

## 4. Key Type Definitions (Cross-Crate Domain Types)

All cross-crate types live in `aitop-core`. The following flow between crates:

| Type | Defined in | Used by |
|------|-----------|---------|
| `GpuInfo` | `aitop-core::hw::gpu` | hw, api, finetune, gui |
| `CpuInfo` | `aitop-core::hw::cpu` | hw, api, gui |
| `SystemInfo` | `aitop-core::hw::system` | hw, api, cli, gui |
| `ModelMetadata` | `aitop-core::model::metadata` | model-hub, inference, finetune, api |
| `ModelFormat` | `aitop-core::model::metadata` | model-hub, inference |
| `TrainingJob` | `aitop-core::training::job` | finetune, api, cli |
| `TrainingStatus` | `aitop-core::training::job` | finetune, api, cli, gui |
| `FinetuneOptions` | `aitop-finetune::options` | finetune, api, cli |
| `GenerationParams` | `aitop-inference::engine` | inference, chat, api |
| `AitopError` | `aitop-core::error` | everywhere |
| `AitopConfig` | `aitop-config::schema` | config, api, cli, gui |

---

## 5. Error Handling Strategy

### Libraries (`thiserror`)

Every lib crate defines its own error enum that wraps `aitop-core::AitopError`
or converts into it via `From`:

```rust
// In aitop-hw
#[derive(Debug, thiserror::Error)]
pub enum HwError {
    #[error("NVML initialization failed: {0}")]
    NvmlInit(String),
    #[error("GPU index {index} not found")]
    GpuNotFound { index: u32 },
    #[error(transparent)]
    Core(#[from] AitopError),
}

// Auto-convert to AitopError for API layer
impl From<HwError> for AitopError {
    fn from(e: HwError) -> Self {
        AitopError::Hardware(e.to_string())
    }
}
```

### Binaries (`anyhow`)

`aitop-cli` and `aitop-gui` use `anyhow::Result` at the top level for flexible
error reporting with `.context()`:

```rust
// In aitop-cli
fn main() -> anyhow::Result<()> {
    let config = AitopConfig::load(&config_path)
        .context("failed to load configuration")?;
    // ...
}
```

### API layer (Axum error responses)

`aitop-api` maps `AitopError` variants to HTTP status codes:

```rust
impl IntoResponse for AitopError {
    fn into_response(self) -> Response {
        let (status, message) = match &self {
            AitopError::ModelNotFound { .. } => (StatusCode::NOT_FOUND, self.to_string()),
            AitopError::Config(_) => (StatusCode::BAD_REQUEST, self.to_string()),
            AitopError::Inference(_) => (StatusCode::INTERNAL_SERVER_ERROR, self.to_string()),
            _ => (StatusCode::INTERNAL_SERVER_ERROR, "internal error".into()),
        };
        (status, Json(json!({ "error": message }))).into_response()
    }
}
```

### Rules

1. Never use `.unwrap()` or `.expect()` in production paths
2. Every `?` propagation should have `.context()` or `.map_err()` for traceability
3. `panic!()` is reserved for invariant violations that indicate logic bugs
4. All error types implement `std::error::Error` + `Send + Sync + 'static`

---

## 6. Testing Strategy

### Per-Crate Testing

| Crate | Unit Tests | Integration Tests | Notes |
|-------|-----------|-------------------|-------|
| `aitop-core` | Types, serialization, format conversion | - | Pure data, 100% coverage target |
| `aitop-hw` | Mock GPU/CPU backends | Real hardware detection | Use `mockall` for `GpuBackend` trait |
| `aitop-config` | Parse valid/invalid TOML | File loading from tempdir | `tempfile` crate |
| `aitop-model-hub` | Registry search parsing | HTTP download (wiremock) | `wiremock` for HF API mocking |
| `aitop-inference` | Sampling params, tokenization | Load GGUF + generate | Needs a small test model (~100MB) |
| `aitop-finetune` | Job state machine transitions | Subprocess orchestration | Mock training subprocess |
| `aitop-rag` | Chunking, embedding | Full ingest-retrieve cycle | In-memory SQLite vector store |
| `aitop-chat` | Session management, templates | Streaming chat flow | Mock inference engine |
| `aitop-dataset` | Schema validation, export formats | Full generation pipeline | Mock inference |
| `aitop-ml` | Algorithm correctness | Pipeline on sample data | Use linfa test datasets |
| `aitop-multinode` | Rank assignment logic | - | Hard to test without cluster |
| `aitop-setup` | Desired-state diffing | - | Use Docker for install tests |
| `aitop-api` | Route matching, error mapping | Full HTTP roundtrip | `axum::test` utilities |
| `aitop-cli` | Arg parsing | Subprocess E2E | `assert_cmd` crate |
| `aitop-gui` | Tauri command wiring | - | Playwright for GUI E2E |

### Testing Patterns

```rust
// 1. Use mockall for trait-based testing
#[cfg(test)]
mod tests {
    use mockall::mock;
    mock! {
        pub GpuBackendMock {}
        #[async_trait]
        impl GpuBackend for GpuBackendMock {
            async fn detect(&self) -> Result<Vec<GpuInfo>, AitopError>;
            async fn poll(&self, index: u32) -> Result<GpuInfo, AitopError>;
            fn compute_api(&self) -> GpuComputeApi;
        }
    }
}

// 2. Use tempfile for config tests
#[tokio::test]
async fn test_config_load() {
    let dir = tempfile::tempdir().unwrap();
    let config_path = dir.path().join("config.toml");
    std::fs::write(&config_path, VALID_TOML).unwrap();
    let config = AitopConfig::load(&config_path).unwrap();
    assert_eq!(config.api.port, 8080);
}

// 3. Use wiremock for HTTP tests
#[tokio::test]
async fn test_model_download() {
    let mock_server = MockServer::start().await;
    Mock::given(method("GET"))
        .and(path("/api/models/test-model"))
        .respond_with(ResponseTemplate::new(200).set_body_json(&model_meta))
        .mount(&mock_server)
        .await;
    // ...
}
```

### CI Pipeline

```yaml
# .github/workflows/ci.yml
test:
  steps:
    - cargo fmt --check
    - cargo clippy -- -D warnings
    - cargo test --workspace
    - cargo test --workspace -- --ignored  # integration tests
    - cargo audit
    - cargo deny check
```

### Coverage Target

Minimum 80% line coverage across the workspace, measured by `cargo-llvm-cov`.
`aitop-core` targets 95%+ (pure data types, easy to test exhaustively).

---

## 7. Architecture Decision Records

### ADR-001: Tauri over Electron

**Context**: AI TOP currently uses Electron (Chromium + Node.js), adding ~200MB
to the install and consuming significant RAM.

**Decision**: Use Tauri 2 for the GUI.

**Rationale**:
- Single binary, ~5MB overhead (uses system WebView)
- Direct Rust function calls, no HTTP serialization overhead
- Same web frontend capability (HTML/CSS/JS)
- Native system tray, menus, notifications

**Trade-off**: WebView rendering varies by platform (WebKit on Linux vs
Chromium-based on Windows/macOS). Mitigated by targeting modern CSS only.

### ADR-002: Candle + llama-cpp-rs Dual Backend

**Context**: The original uses Python `transformers` + `llama-cpp-python` for
inference. We need both HuggingFace model support and GGUF quantized models.

**Decision**: Support two inference backends behind the `InferenceEngine` trait.

**Rationale**:
- `llama-cpp-rs`: Best performance for quantized GGUF models, CUDA/ROCm/Metal
  acceleration, the workhorse for local LLM inference
- `candle`: Pure Rust, good for embedding models and smaller transformer tasks,
  no C++ build dependency

Users choose backend per model. GGUF models route to llama.cpp; safetensors
route to candle.

### ADR-003: PyO3 Bridge for Diffusion Models

**Context**: Text-to-image (Stable Diffusion) and text-to-video have no mature
pure-Rust implementations. The `diffusers` Python library is battle-tested.

**Decision**: Use PyO3 to call Python `diffusers` for image/video generation.
Mark this as an optional feature gate (`--features python-diffusion`).

**Rationale**:
- Avoids rewriting a complex, rapidly evolving ecosystem
- Users who only need text generation skip Python entirely
- Clear migration path: replace PyO3 bridge when Rust alternatives mature

### ADR-004: Declarative Setup over Shell Scripts

**Context**: 19 shell scripts handle conda, CUDA, ROCm, apt packages, and
various patches. They are fragile, not idempotent, and Linux-only.

**Decision**: Replace with `aitop-setup` crate using a declarative
desired-state model.

**Rationale**:
- Idempotent: safe to run repeatedly
- Diff-based: only installs what is missing
- Cross-platform: same binary works on Ubuntu 22.04/24.04, Fedora, Arch
- Testable: can unit-test the state diffing logic

---

## 8. Migration Order

Phase 1 (foundation):
1. `aitop-core` -- all domain types
2. `aitop-config` -- configuration
3. `aitop-hw` -- hardware detection

Phase 2 (model lifecycle):
4. `aitop-model-hub` -- download and manage models
5. `aitop-inference` -- load and run models

Phase 3 (applications):
6. `aitop-chat` -- chat interface
7. `aitop-rag` -- RAG pipeline
8. `aitop-dataset` -- dataset generation
9. `aitop-finetune` -- training orchestration
10. `aitop-ml` -- classical ML

Phase 4 (infrastructure):
11. `aitop-multinode` -- multi-node support
12. `aitop-setup` -- system provisioning

Phase 5 (interfaces):
13. `aitop-api` -- REST/WS server
14. `aitop-cli` -- command-line interface
15. `aitop-gui` -- Tauri desktop app

Each phase produces a working, testable artifact. Phase 1-2 can run in
~2 weeks of focused AI-assisted development. The full port targets 6-8 weeks.

---

## 9. Performance Targets

| Metric | Python Original | Rust Target | Technique |
|--------|----------------|-------------|-----------|
| Cold start | ~8s | <500ms | No interpreter startup |
| System info poll | ~200ms | <10ms | Direct sysfs/NVML reads |
| Model list scan | ~2s | <100ms | Parallel tokio tasks |
| GGUF load (7B) | ~12s | ~8s | mmap, zero-copy |
| Token/s (7B Q4) | ~35 tok/s | ~45 tok/s | llama.cpp native |
| API latency p99 | ~50ms | <5ms | Axum, no GIL |
| Binary size | 107MB + Python | ~15MB | Static linking, strip |
| RAM idle | ~400MB | <50MB | No Python runtime |

---

## 10. Security Considerations

1. **No hardcoded secrets**: Database password loaded from `AITOP_DB_PASSWORD`
   env var, never from config files
2. **API authentication**: Token-based auth middleware on all endpoints
3. **Input validation**: All user input validated at API boundary via `serde`
   deserialization + custom validators
4. **Path traversal prevention**: Model paths canonicalized and checked against
   allowed base directories
5. **Command injection prevention**: `aitop-setup` uses `tokio::process::Command`
   with explicit argument lists, never shell interpolation
6. **CORS**: Configurable origins, defaults to localhost only
7. **Rate limiting**: Token bucket per client IP on all endpoints
8. **Dependency auditing**: `cargo audit` + `cargo deny` in CI
