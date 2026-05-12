# Sub-3B Parameter Model Candidates for Fine-Tuning

**Research Date**: 2026-02-13
**Hardware Target**: 2x NVIDIA RTX 5090 (32GB each, 64GB total), AMD Threadripper PRO 7965WX (48 threads), 503GB RAM
**CUDA**: 13.1, Driver 590.48.01
**Goal**: Fine-tune a sub-3B model for system administration, AI orchestration, tool/function calling, and code generation tasks

---

## Top 5 Ranked Recommendations

### #1: Qwen3-1.7B (RECOMMENDED)

| Attribute | Value |
|-----------|-------|
| **Parameters** | 1.7B |
| **Architecture** | Dense decoder-only Transformer, GQA, qk-layernorm |
| **Context Length** | 32,768 tokens (extendable to 128K via YaRN) |
| **License** | Apache 2.0 (full commercial use) |
| **HuggingFace** | [Qwen/Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B) |
| **Instruct** | [Qwen/Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B) (unified thinking/non-thinking) |
| **Base** | [Qwen/Qwen3-1.7B-Base](https://huggingface.co/Qwen/Qwen3-1.7B-Base) |
| **Ollama** | `ollama pull qwen3:1.7b` |
| **GGUF** | [Qwen/Qwen3-1.7B-GGUF](https://huggingface.co/Qwen/Qwen3-1.7B-GGUF), [unsloth/Qwen3-1.7B-GGUF](https://huggingface.co/unsloth/Qwen3-1.7B-GGUF) |
| **Unsloth** | [unsloth/Qwen3-1.7B](https://huggingface.co/unsloth/Qwen3-1.7B) |

**Why #1:**
- Matches Qwen2.5-3B-Base performance at nearly half the parameters
- Unique dual-mode: seamless switching between **thinking mode** (complex reasoning, math, coding) and **non-thinking mode** (efficient general dialogue) within a single model
- Trained on massive data (part of the Qwen3 series trained with advanced curriculum)
- Agent and tool-use friendly architecture out of the box
- Apache 2.0 license -- no restrictions on commercial use or derivative naming
- Excellent fine-tuning support via Unsloth (2x faster, 70% less VRAM, 8x longer context)
- Broad multilingual support (100+ languages)
- Distil Labs benchmark: Qwen3-0.6B showed 3rd highest tunability; the 1.7B is the sweet spot for quality vs. efficiency

**Strengths:**
- Best reasoning ability in sub-2B class
- Thinking/non-thinking mode is unique for agent workflows
- Tool/function calling design built into architecture
- Strong code generation despite being a general model
- 128K context achievable with YaRN extension

**Weaknesses:**
- Not code-specialized (Qwen2.5-Coder is better for pure code tasks)
- Relatively new (May 2025), fewer community fine-tunes than older models
- 1.7B still limits complex multi-step reasoning compared to 4B+

**Fine-tuning frameworks:** Unsloth, Transformers + TRL, Axolotl, LLaMA-Factory
**VRAM estimate (QLoRA):** ~3-4 GB (trivial on RTX 5090)
**VRAM estimate (full fine-tune fp16):** ~8-10 GB

---

### #2: Qwen2.5-Coder-1.5B

| Attribute | Value |
|-----------|-------|
| **Parameters** | 1.5B |
| **Architecture** | Dense Transformer, GQA, vocab 151,646 |
| **Context Length** | 32,768 tokens |
| **License** | Apache 2.0 (full commercial use) |
| **HuggingFace** | [Qwen/Qwen2.5-Coder-1.5B](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B) |
| **Instruct** | [Qwen/Qwen2.5-Coder-1.5B-Instruct](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct) |
| **Ollama** | `ollama pull qwen2.5-coder:1.5b` |
| **GGUF** | [Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF) |
| **Unsloth** | [unsloth/Qwen2.5-Coder-1.5B-Instruct](https://huggingface.co/unsloth/Qwen2.5-Coder-1.5B-Instruct) |

**Why #2:**
- Purpose-built for code -- trained on 5.5 trillion tokens including source code, text-code grounding, and synthetic data
- Best code generation quality in the sub-2B class by a significant margin
- Ideal for learning sysadmin tasks since it understands shell scripts, config files, YAML, Python, and infrastructure-as-code natively
- Same Apache 2.0 license freedom as Qwen3

**Strengths:**
- Superior code generation, code reasoning, and code fixing at this scale
- Understands 92+ programming languages
- Excellent for Bash/shell scripting, Kubernetes manifests, Dockerfiles, CI/CD
- Very small VRAM footprint for fine-tuning
- Unsloth notebooks available for instant fine-tuning

**Weaknesses:**
- Weaker at general instruction following compared to Qwen3-1.7B
- No dedicated tool/function calling training
- Smaller context than Qwen3 when extended
- Code-first design means less conversational ability

**Fine-tuning frameworks:** Unsloth, Transformers + TRL, Axolotl
**VRAM estimate (QLoRA):** ~2-3 GB
**VRAM estimate (full fine-tune fp16):** ~6-8 GB

---

### #3: SmolLM3-3B

| Attribute | Value |
|-----------|-------|
| **Parameters** | 3.0B (at the limit) |
| **Architecture** | Decoder-only Transformer, GQA + NoPE (3:1 ratio) |
| **Context Length** | 64K native, extendable to 128K via YARN |
| **License** | Apache 2.0 |
| **HuggingFace** | [HuggingFaceTB/SmolLM3-3B](https://huggingface.co/HuggingFaceTB/SmolLM3-3B) |
| **Instruct** | SmolLM3-3B (unified; instruct-tuned for reasoning and tool use) |
| **Base** | [HuggingFaceTB/SmolLM3-3B-Base](https://huggingface.co/HuggingFaceTB/SmolLM3-3B-Base) |
| **Ollama** | `ollama pull smollm3:3b` (check availability) |
| **Unsloth** | Expected support (Hugging Face native) |

**Why #3:**
- Trained on 11.2T tokens -- massive training budget for a 3B model
- Native tool calling and agent support with schema-driven I/O
- Dual-mode reasoning (`/think` and `/no_think`) similar to Qwen3
- Performance close to Mistral-7B on many benchmarks at half the parameters
- Fully open recipe (architecture decisions, training methodology published)
- 6 languages: English, French, Spanish, German, Italian, Portuguese

**Strengths:**
- Best tool/function calling in the 3B class
- Longest native context (64K) of any model on this list
- Deterministic output mode for agent integration
- Strong reasoning and math capabilities
- Fully reproducible training recipe

**Weaknesses:**
- At the 3B boundary (may be slightly over for strict "sub-3B")
- Newer model (July 2025) -- less community fine-tuning ecosystem
- Not code-specialized
- Larger VRAM footprint than 1.5-1.7B models

**Fine-tuning frameworks:** Transformers + TRL, Axolotl, alignment-handbook
**VRAM estimate (QLoRA):** ~5-6 GB
**VRAM estimate (full fine-tune fp16):** ~14-16 GB

---

### #4: Llama-3.2-3B-Instruct

| Attribute | Value |
|-----------|-------|
| **Parameters** | 3.2B |
| **Architecture** | Dense Transformer (Llama architecture), GQA |
| **Context Length** | 128K tokens |
| **License** | Llama 3.2 Community License (commercial with naming requirement) |
| **HuggingFace** | [meta-llama/Llama-3.2-3B-Instruct](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct) |
| **Base** | [meta-llama/Llama-3.2-3B](https://huggingface.co/meta-llama/Llama-3.2-3B) |
| **Ollama** | `ollama pull llama3.2:3b` |
| **Unsloth** | [unsloth/Llama-3.2-3B-Instruct](https://huggingface.co/unsloth/Llama-3.2-3B-Instruct) |

**Why #4:**
- Llama architecture is the most widely supported across all fine-tuning frameworks
- Highest tunability ranking in Distil Labs benchmarks (both 1B and 3B variants)
- 128K native context -- longest on this list
- Massive community: thousands of fine-tunes, LoRA adapters, and tutorials available
- Meta's ecosystem ensures long-term support

**Strengths:**
- Most community fine-tunes and LoRA adapters available
- Highest tunability (most improvement from fine-tuning per Distil Labs)
- 128K context natively
- Extremely well-supported by Unsloth, Axolotl, LLaMA-Factory, and every major framework
- Strong instruction following baseline

**Weaknesses:**
- Slightly above 3B (3.2B parameters)
- Llama Community License requires "Llama" prefix in derivative model names
- Weaker code generation than Qwen2.5-Coder
- No native tool calling support (must be fine-tuned for it)
- Outperformed by Qwen3 on raw benchmarks

**Fine-tuning frameworks:** Unsloth, Transformers + TRL, Axolotl, LLaMA-Factory, PEFT
**VRAM estimate (QLoRA):** ~5-6 GB
**VRAM estimate (full fine-tune fp16):** ~14-16 GB

---

### #5: Gemma-3-1B-IT

| Attribute | Value |
|-----------|-------|
| **Parameters** | 1.0B |
| **Architecture** | Dense Transformer (Gemma architecture) |
| **Context Length** | 32K tokens |
| **License** | Gemma Terms of Use (permissive, commercial OK) |
| **HuggingFace** | [google/gemma-3-1b-it](https://huggingface.co/google/gemma-3-1b-it) |
| **Base** | [google/gemma-3-1b-pt](https://huggingface.co/google/gemma-3-1b-pt) |
| **Ollama** | `ollama pull gemma3:1b` |
| **Unsloth** | Supported (Gemma 3 fine-tuning 1.6x faster, 60% less VRAM) |

**Why #5:**
- Google's research-grade model with excellent architecture
- FunctionGemma derivative available for function calling (270M specialist)
- Strong math, reasoning, and instruction following for 1B
- Well-documented fine-tuning pipeline from Google (QLoRA + full fine-tune guides)
- Unsloth optimized for Gemma 3

**Strengths:**
- Smallest model on the list at 1B -- fastest to fine-tune
- FunctionGemma ecosystem for tool/function calling
- Well-documented by Google with official fine-tuning notebooks
- Good balance of reasoning and instruction following
- Permissive commercial license

**Weaknesses:**
- 1B limits overall quality ceiling
- Weaker code generation than Qwen2.5-Coder
- Less community momentum than Llama or Qwen
- FunctionGemma (270M) is separate and extremely small
- Limited multilingual support compared to Qwen3

**Fine-tuning frameworks:** Unsloth, Transformers + TRL, Google's official notebooks
**VRAM estimate (QLoRA):** ~2 GB
**VRAM estimate (full fine-tune fp16):** ~4-5 GB

---

## Honorable Mentions

### StarCoder2-3B

| Attribute | Value |
|-----------|-------|
| **Parameters** | 3.0B |
| **Architecture** | Transformer, GQA, sliding window attention (4,096) |
| **Context Length** | 16,384 tokens |
| **License** | BigCode OpenRAIL-M (commercial with restrictions) |
| **HuggingFace** | [bigcode/starcoder2-3b](https://huggingface.co/bigcode/starcoder2-3b) |
| **Ollama** | `ollama pull starcoder2:3b` |

- Trained on 3+ trillion tokens of code across 17 languages
- Outperforms DeepSeek-Coder-1.3B and StableCode-3B on most code benchmarks
- Good for pure code completion but weaker at instruction following
- Older model (Feb 2024) -- superseded by Qwen2.5-Coder in most benchmarks
- Shorter context (16K) limits usefulness for large codebases

### DeepSeek-Coder-1.3B

| Attribute | Value |
|-----------|-------|
| **Parameters** | 1.3B |
| **Architecture** | Dense Transformer |
| **Context Length** | 16,384 tokens |
| **License** | DeepSeek License (research + commercial) |
| **HuggingFace** | [deepseek-ai/deepseek-coder-1.3b-instruct](https://huggingface.co/deepseek-ai/deepseek-coder-1.3b-instruct) |
| **Ollama** | `ollama pull deepseek-coder:1.3b` |

- Trained on 87% code and 13% natural language
- Very small and fast, good for constrained environments
- Outperformed by Qwen2.5-Coder-1.5B and StarCoder2-3B on most benchmarks
- Older model -- DeepSeek has shifted focus to larger models (V2, R1)

### SmolLM2-1.7B-Instruct

| Attribute | Value |
|-----------|-------|
| **Parameters** | 1.7B |
| **Architecture** | Dense Transformer |
| **Context Length** | 8,192 tokens |
| **License** | Apache 2.0 |
| **HuggingFace** | [HuggingFaceTB/SmolLM2-1.7B-Instruct](https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct) |
| **Ollama** | `ollama pull smollm2:1.7b` |

- Trained on 11T tokens (impressive data budget for size)
- Predecessor to SmolLM3 -- superseded but still solid
- SFT + DPO training pipeline
- Short context (8K) is a significant limitation
- Lower benchmark scores than Qwen3-1.7B across the board

### Qwen3-0.6B

| Attribute | Value |
|-----------|-------|
| **Parameters** | 0.6B |
| **Architecture** | Dense Transformer, GQA, qk-layernorm |
| **Context Length** | 32,768 tokens |
| **License** | Apache 2.0 |
| **HuggingFace** | [Qwen/Qwen3-0.6B](https://huggingface.co/Qwen/Qwen3-0.6B) |
| **Ollama** | `ollama pull qwen3:0.6b` |

- Most downloaded tiny text generation model on HuggingFace (Dec 2025)
- Among the most downloaded text generation models on Hugging Face
- 3rd highest tunability in Distil Labs benchmarks
- Agent and tool-use friendly design
- Excellent for experimentation before scaling to 1.7B
- Limited quality ceiling due to 0.6B size

### EXAONE-3.5-2.4B-Instruct

| Attribute | Value |
|-----------|-------|
| **Parameters** | 2.4B |
| **Architecture** | Dense Transformer |
| **Context Length** | 32,768 tokens |
| **License** | EXAONE AI Model License 1.1 - **NC (Non-Commercial)** |
| **HuggingFace** | [LGAI-EXAONE/EXAONE-3.5-2.4B-Instruct](https://huggingface.co/LGAI-EXAONE/EXAONE-3.5-2.4B-Instruct) |

- Strong reasoning and bilingual (EN/KO) capabilities
- **Non-commercial license** -- disqualifies for production use
- Good for research and experimentation only

### FunctionGemma-270M-IT

| Attribute | Value |
|-----------|-------|
| **Parameters** | 0.27B |
| **Architecture** | Gemma 3 270M, fine-tuned for function calling |
| **Context Length** | 32K tokens |
| **License** | Gemma Terms of Use (commercial OK) |
| **HuggingFace** | [google/functiongemma-270m-it](https://huggingface.co/google/functiongemma-270m-it) |

- Purpose-built for function calling (natural language -> structured API calls)
- 85% accuracy on mobile actions after fine-tuning (up from 58% baseline)
- Designed for edge/on-device agents
- Too small for general tasks but excellent as a function-calling specialist
- Can be paired with a larger model for a two-model architecture

---

## Comparison Matrix

| Model | Params | Context | License | Code | Instruct | Tool Use | Ollama | Tunability |
|-------|--------|---------|---------|------|----------|----------|--------|------------|
| **Qwen3-1.7B** | 1.7B | 32K-128K | Apache 2.0 | Good | Excellent | Built-in | Yes | High |
| **Qwen2.5-Coder-1.5B** | 1.5B | 32K | Apache 2.0 | Excellent | Fair | None | Yes | High |
| **SmolLM3-3B** | 3.0B | 64K-128K | Apache 2.0 | Good | Very Good | Built-in | Check | High |
| **Llama-3.2-3B** | 3.2B | 128K | Llama CL | Fair | Good | None | Yes | Highest |
| **Gemma-3-1B** | 1.0B | 32K | Gemma ToU | Fair | Good | Via FuncGemma | Yes | Medium |
| StarCoder2-3B | 3.0B | 16K | OpenRAIL-M | Very Good | Poor | None | Yes | Medium |
| DeepSeek-Coder-1.3B | 1.3B | 16K | DS License | Good | Poor | None | Yes | Medium |
| SmolLM2-1.7B | 1.7B | 8K | Apache 2.0 | Fair | Fair | None | Yes | Medium |
| Qwen3-0.6B | 0.6B | 32K | Apache 2.0 | Fair | Good | Built-in | Yes | High |
| EXAONE-3.5-2.4B | 2.4B | 32K | NC only | Fair | Good | None | No | Medium |
| FunctionGemma-270M | 0.27B | 32K | Gemma ToU | None | None | Excellent | No | High |

---

## Fine-Tuning Strategy Recommendations

### For Your Use Case (Sysadmin + AI Orchestration)

**Primary recommendation**: Fine-tune **Qwen3-1.7B** with a LoRA/QLoRA adapter using a curated dataset of:
- System administration commands and explanations (Bash, systemd, networking)
- AI orchestration patterns (MCP tool calls, agent coordination, API routing)
- Infrastructure-as-code (Kubernetes YAML, Helm charts, Docker/Podman)
- Tool/function calling examples (structured JSON output)

**Secondary (code specialist)**: Fine-tune **Qwen2.5-Coder-1.5B** for pure code generation tasks:
- Shell scripts, Python automation, config file generation
- Code completion for DevOps/SRE workflows

**Dual-model architecture**: Consider running both:
1. Qwen3-1.7B for reasoning, planning, and tool orchestration
2. Qwen2.5-Coder-1.5B for code generation and completion
Both fit easily in a single RTX 5090 with room to spare.

### Fine-Tuning Framework Recommendation

**Unsloth** is the recommended framework for your hardware:
- 2x faster training speed
- 70% less VRAM usage
- 8x longer context fine-tuning possible
- Native support for all top-5 models
- QLoRA with dynamic 4-bit quantization (negligible accuracy loss)
- Easy export to GGUF, ONNX, vLLM formats

**Recommended hyperparameters (starting point):**
```python
# LoRA config
r = 16              # LoRA rank
lora_alpha = 16     # scaling factor
lora_dropout = 0.05
target_modules = ["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"]

# Training config
learning_rate = 2e-4
num_train_epochs = 3
per_device_train_batch_size = 4
gradient_accumulation_steps = 4
max_seq_length = 2048  # start here, scale up as needed
warmup_ratio = 0.03
weight_decay = 0.01
```

### RTX 5090 Capacity

With 2x RTX 5090 (64GB total VRAM):
- **QLoRA any sub-3B model**: Trivial (~3-6 GB), can train multiple models simultaneously
- **Full fine-tune fp16 any sub-3B model**: Easy (~8-16 GB single GPU)
- **Full fine-tune + long context (32K+)**: Feasible with gradient checkpointing
- **Multi-GPU training**: Use DeepSpeed ZeRO-2 or FSDP for distributed training across both GPUs

---

## Already Installed Locally

Models you already have that appear on this list:
- `granite-micro` (~3.4B) -- slightly over 3B, IBM model, not in top 5 but usable
- `phi4-mini` (~3.8B) -- over 3B, strong reasoning but 3.8B params
- `qwen2.5-coder:7b` (7B) -- over 3B, but the 1.5B variant is recommended above

**Action items:**
1. Pull `qwen3:1.7b` via Ollama for immediate testing
2. Pull `qwen2.5-coder:1.5b` via Ollama as code specialist
3. Download Unsloth-optimized versions from HuggingFace for fine-tuning
4. Prepare training dataset from system logs, configs, and orchestration patterns

---

## Sources

- [Distil Labs: 12 Small Language Model Benchmark](https://www.distillabs.ai/blog/we-benchmarked-12-small-language-models-across-8-tasks-to-find-the-best-base-model-for-fine-tuning)
- [BentoML: Best Open-Source SLMs 2026](https://www.bentoml.com/blog/the-best-open-source-small-language-models)
- [Unsloth Fine-Tuning Guide](https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/what-model-should-i-use)
- [Qwen3 Technical Report](https://qwenlm.github.io/blog/qwen3/)
- [Qwen2.5-Coder Collection](https://huggingface.co/collections/Qwen/qwen25-coder)
- [SmolLM3-3B HuggingFace](https://huggingface.co/HuggingFaceTB/SmolLM3-3B)
- [Llama 3.2 HuggingFace](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct)
- [Gemma 3 Fine-Tuning Guide](https://ai.google.dev/gemma/docs/core/huggingface_text_finetune_qlora)
- [FunctionGemma](https://huggingface.co/google/functiongemma-270m-it)
- [StarCoder2-3B](https://huggingface.co/bigcode/starcoder2-3b)
- [EXAONE-3.5-2.4B](https://huggingface.co/LGAI-EXAONE/EXAONE-3.5-2.4B-Instruct)
- [NVIDIA Blog: Fine-Tuning with Unsloth on RTX](https://blogs.nvidia.com/blog/rtx-ai-garage-fine-tuning-unsloth-dgx-spark/)
- [Clarifai: Top 10 Reasoning Models 2026](https://www.clarifai.com/blog/top-10-open-source-reasoning-models-in-2026)
- [Medium: Top Open-Source LLMs 2025](https://medium.com/@sulbha.jindal/top-open-source-llms-small-and-mid-range-in-2025-ff8ea8df8738)
