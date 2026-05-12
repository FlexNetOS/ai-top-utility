# Model Download Status

**Date**: 2026-02-13
**System**: flexnetos (AMD Threadripper PRO 7965WX, 2x RTX 5090)

---

## Downloads Completed

### 1. Qwen3-1.7B (Primary - General/Orchestration)

| Field | Value |
|-------|-------|
| **Ollama Tag** | `qwen3:1.7b` |
| **Ollama ID** | `8f68893c685c` |
| **Disk Size** | 1.4 GB |
| **Status** | Downloaded and verified |
| **Smoke Test** | PASSED |
| **Response** | "Kubernetes is an open-source platform for automating the deployment, scaling, and management of containerized applications through orchestration of containers, self-healing, and service discovery." |

**Performance (smoke test):**
| Metric | Value |
|--------|-------|
| Total duration | 5.59s (includes 4.74s model load) |
| Prompt eval rate | 1,166.16 tokens/s |
| Generation rate | 478.11 tokens/s |
| Prompt tokens | 24 |
| Generated tokens | 327 (includes thinking tokens) |

Note: Qwen3 used thinking mode by default despite `/no_think` in prompt. The model engaged internal reasoning before producing the final answer. Thinking mode can be disabled via system prompt or the `enable_thinking=False` parameter.

---

### 2. Qwen2.5-Coder-1.5B (Secondary - Code Specialist)

| Field | Value |
|-------|-------|
| **Ollama Tag** | `qwen2.5-coder:1.5b` |
| **Ollama ID** | `d7372fd82851` |
| **Disk Size** | 986 MB |
| **Status** | Downloaded and verified |
| **Smoke Test** | PASSED |
| **Response** | "Kubernetes is an open-source platform designed for automating the deployment, scaling, and management of containerized applications across multiple nodes." |

**Performance (smoke test):**
| Metric | Value |
|--------|-------|
| Total duration | 8.78s (includes 8.60s model load) |
| Prompt eval rate | 348.92 tokens/s |
| Generation rate | 550.37 tokens/s |
| Prompt tokens | 39 |
| Generated tokens | 27 |

Note: Qwen2.5-Coder produced a direct, concise answer without thinking overhead. Higher generation rate than Qwen3-1.7B for pure text output (550 vs 478 tok/s), though Qwen3 had more raw tokens including reasoning chain.

---

## Full Ollama Model Inventory

| Model | ID | Size | Modified |
|-------|-----|------|----------|
| qwen2.5-coder:1.5b | d7372fd82851 | 986 MB | Just downloaded |
| qwen3:1.7b | 8f68893c685c | 1.4 GB | Just downloaded |
| snowflake-arctic-embed:33m | e8db018629b4 | 67 MB | 34 hours ago |
| nomic-embed-text:latest | 0a109f422b47 | 274 MB | 34 hours ago |
| qwen3-4b:latest | 0348762504b8 | 2.5 GB | 2 days ago |
| phi4-mini:latest | 242ebe44995d | 2.5 GB | 2 days ago |
| granite-micro:latest | f1f0929d6345 | 2.1 GB | 2 days ago |
| deepseek-r1:70b | d37b54d01a76 | 42 GB | 2 days ago |
| qwen2.5-coder:32b | b92d6a0bd47e | 19 GB | 2 days ago |
| qwen2.5-coder:7b | dae161e27b0e | 4.7 GB | 4 days ago |

**Total Ollama disk usage**: ~74.9 GB across 10 models

---

## HuggingFace Models (for Fine-Tuning)

### 3. unsloth/Qwen3-1.7B (HuggingFace cached)

| Field | Value |
|-------|-------|
| **HF Repo** | `unsloth/Qwen3-1.7B` |
| **Model Class** | Qwen3ForCausalLM |
| **Vocab Size** | 151,643 |
| **4-bit GPU Memory** | 1.35 GB |
| **Status** | Downloaded, cached, dry-run PASSED |

### 4. unsloth/Qwen2.5-Coder-1.5B-Instruct (HuggingFace cached)

| Field | Value |
|-------|-------|
| **HF Repo** | `unsloth/Qwen2.5-Coder-1.5B-Instruct` |
| **Model Class** | Qwen2ForCausalLM |
| **Vocab Size** | 151,643 |
| **4-bit GPU Memory** | ~1.2 GB |
| **Status** | Downloaded, cached, verified |

---

## Fine-Tuning Environment Status

| Component | Version | Status | Notes |
|-----------|---------|--------|-------|
| **Python venv** | 3.12.3 | READY | `~/model-training-prep/training/.venv/` |
| **PyTorch** | 2.10.0+cu130 | READY | CUDA 13.0 build (compatible with 13.1 toolkit) |
| **Unsloth** | 2026.2.1 | READY | Fast patching enabled |
| **Transformers** | 4.57.6 | READY | |
| **TRL** | 0.24.0 | READY | SFTTrainer available |
| **PEFT** | 0.18.1 | READY | LoRA/QLoRA support |
| **bitsandbytes** | 0.49.1 | READY | 4-bit quantization |
| **Accelerate** | 1.12.0 | READY | Multi-GPU support |
| **xformers** | 0.0.34 | READY | Memory-efficient attention |
| **Triton** | 3.6.0 | READY | Kernel compilation |
| **Ollama models** | -- | READY | Both target models downloaded and verified |
| **HuggingFace models** | -- | READY | Both cached in 4-bit for fine-tuning |
| **Training script** | -- | READY | `~/model-training-prep/training/train.py` |
| **Training dataset** | -- | PLACEHOLDER | Waiting on doc-collector and config-auditor |

---

## GPU Verification

| Property | Value |
|----------|-------|
| GPU 0 | NVIDIA GeForce RTX 5090 (31.4 GB) |
| GPU 1 | NVIDIA GeForce RTX 5090 (31.4 GB) |
| Total VRAM | 62.7 GB |
| CUDA Toolkit | 13.1 (nvcc), PyTorch uses cu130 |
| cuDNN | 9.15.01 |
| BF16 Support | YES |
| Compute Capability | sm_120 (Blackwell) |

---

## Dry-Run Results (Qwen3-1.7B)

| Metric | Value |
|--------|-------|
| Model loaded (4-bit) | 1.35 GB GPU memory |
| LoRA trainable params | 17,432,576 / 1,052,238,848 (1.66%) |
| GPU memory after LoRA | 1.41 GB allocated, 1.43 GB reserved |
| Template format | ChatML (im_start/im_end) |
| Thinking mode | Automatically inserts `<think>` tags |
| Status | All checks passed |

---

## Training Script

**Location**: `~/model-training-prep/training/train.py`

**Usage**:
```bash
source ~/model-training-prep/training/.venv/bin/activate

# Dry run (verify setup):
python train.py --model qwen3 --dry-run

# Train Qwen3-1.7B:
python train.py --model qwen3

# Train Qwen2.5-Coder-1.5B:
python train.py --model coder

# Custom settings:
python train.py --model qwen3 --epochs 5 --lr 1e-4 --max-seq-length 8192

# Train and export to GGUF:
python train.py --model qwen3 --export-gguf
```

**Default LoRA Config**:
- Rank: 16, Alpha: 32, Dropout: 0.05
- Target modules: q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj
- RSLoRA: enabled
- Gradient checkpointing: Unsloth optimized

**Default Training Config**:
- Epochs: 3, LR: 2e-4 (cosine scheduler)
- Batch: 4, Grad accum: 4 (effective batch: 16)
- Precision: BF16, Optimizer: AdamW 8-bit
- Max seq length: 4096

---

## Dataset Format

The training script accepts JSONL files with either format:

**Conversation format** (preferred):
```json
{"messages": [{"role": "system", "content": "..."}, {"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]}
```

**Instruction format** (auto-converted):
```json
{"instruction": "...", "input": "...", "output": "..."}
```

**Dataset location**: `~/model-training-prep/training/dataset.jsonl`

---

## Next Steps

1. ~~Install Unsloth and dependencies~~ DONE
2. ~~Download HuggingFace format models~~ DONE
3. ~~Create training script~~ DONE
4. ~~Verify GPU access and dry-run~~ DONE
5. **Prepare training dataset** from collected docs and config audits (waiting on doc-collector + config-auditor)
6. **Run fine-tuning** on RTX 5090
7. **Export fine-tuned adapters** to GGUF for Ollama deployment
8. **Test fine-tuned models** via Ollama
