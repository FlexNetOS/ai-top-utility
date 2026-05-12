# Gigabyte AI TOP Utility & Linux AI Training Optimization Guide

**System**: Gigabyte TRX50 AI TOP Motherboard
**CPU**: AMD Ryzen Threadripper PRO 7965WX 24-Cores (48 threads)
**GPU**: 2x NVIDIA GeForce RTX 5090 (32GB VRAM each, 64GB total)
**RAM**: 503GB DDR5 ECC R-DIMM
**OS**: Pop!_OS 24.04 LTS (Kernel 6.18.7)
**NVIDIA Driver**: 590.48.01 | CUDA 13.1
**Researched**: 2026-02-13

---

## Table of Contents

1. [Gigabyte AI TOP Utility - What Is It?](#1-gigabyte-ai-top-utility---what-is-it)
2. [AI TOP Utility - Platform Support & Linux Availability](#2-ai-top-utility---platform-support--linux-availability)
3. [AI TOP Utility Features (v4.2.0)](#3-ai-top-utility-features-v420)
4. [AI TOP Utility Limitations](#4-ai-top-utility-limitations)
5. [Critical Finding: GPU0 PCIe Gen 1 Issue](#5-critical-finding-gpu0-pcie-gen-1-issue)
6. [Linux Native Alternative Stack](#6-linux-native-alternative-stack)
7. [GPU Power Management (nvidia-smi)](#7-gpu-power-management-nvidia-smi)
8. [CUDA MPS for Multi-GPU](#8-cuda-mps-for-multi-gpu)
9. [Fan Control on Linux](#9-fan-control-on-linux)
10. [Memory & Swap Optimization](#10-memory--swap-optimization)
11. [NUMA & CPU Configuration](#11-numa--cpu-configuration)
12. [BIOS Settings for AI Training](#12-bios-settings-for-ai-training)
13. [Complete Optimization Script](#13-complete-optimization-script)
14. [Current System Audit](#14-current-system-audit)

---

## 1. Gigabyte AI TOP Utility - What Is It?

Gigabyte AI TOP is an **AI model training and inference platform** bundled with Gigabyte's AI TOP series motherboards. It was introduced at COMPUTEX 2024 and updated to version 4.0 at CES 2026.

**It is NOT a hardware tuning/overclocking utility.** Despite the name suggesting system optimization, AI TOP is a **no-code AI workflow application** focused on:

- Local LLM/LMM fine-tuning (up to 405B-685B parameter models)
- Dataset creation and management (auto-structured Q&A from raw data)
- Model conversion (.safetensors/.bin to GGUF with quantization: FP32, FP16, BF16, 8-bit, FP4)
- Local inference (Hugging Face Transformers, llama.cpp, Quick Transformers)
- RAG-based model selection and validation
- Pre-built ML workflows (agriculture, industrial, healthcare, business)
- Real-time hardware monitoring during training
- Memory offloading to system RAM and SSDs for large models
- Multi-node optimization for multi-GPU VRAM reduction
- SSD auto-mounting for NVMe storage pools

**AI TOP does NOT manage**: GPU power limits, fan curves, BIOS settings, CPU tuning, or system-level hardware configuration. Those are handled by separate tools documented below.

### AI TOP Product Ecosystem

| Product | Type | Description |
|---------|------|-------------|
| TRX50 AI TOP | Motherboard | This system's board - flagship AI training platform |
| Z890 AI TOP | Motherboard | Intel consumer AI board |
| B850 AI TOP | Motherboard | AMD consumer AI board |
| AI TOP 500 TRX50 | Pre-built PC | Full workstation with AI TOP software |
| AI TOP ATOM | Pre-built PC | NVIDIA GB10-based AI supercomputer |
| AI TOP Utility | Software | The AI workflow application (v4.2.0 current) |

---

## 2. AI TOP Utility - Platform Support & Linux Availability

| Aspect | Details |
|--------|---------|
| **Primary OS** | Linux (native) |
| **Windows Support** | Via WSL2 on Windows 11 |
| **Interface** | GUI (graphical, no-code) |
| **CLI/API** | Not documented; no known CLI or REST API |
| **Download** | https://www.gigabyte.com/Support/Utility/Motherboard?kw=AI+TOP |
| **Current Version** | 4.2.0 |
| **Hardware Lock** | Designed for AI TOP hardware, may work on other Gigabyte boards |

**Key takeaway**: AI TOP Utility runs natively on Linux. It is a GUI application for AI model management, not a system tuning tool. For our purposes (optimizing the system for AI training), we need the Linux alternative stack described below.

---

## 3. AI TOP Utility Features (v4.2.0)

### Model Management
- Download models directly from Hugging Face (70+ supported open-source LLMs)
- Supported models: Llama 2/3, Gemma 2, Baichuan 2, Distill-GPT2, GLM4, and more
- Model conversion: .safetensors/.bin to GGUF
- Quantization: FP32, FP16, BF16, 8-bit, FP4

### Fine-Tuning
- Standard to High Precision fine-tuning modes
- Dataset Creator: transforms unstructured data into Q&A training pairs
- Real-time progress monitoring with hardware utilization graphs
- Validation: in-app model testing after fine-tuning

### Inference
- Local inference with no cloud dependency
- Backends: Hugging Face Transformers, llama.cpp, Quick Transformers
- RAG integration for context-aware inference
- LLM (text) and LMM (image/video) generation

### Hardware Optimization
- Memory offloading to system RAM and NVMe SSDs
- Multi-node GPU optimization (reduces per-GPU VRAM usage)
- Automatic NVMe SSD mounting
- Real-time hardware monitoring (GPU temp, VRAM, utilization)
- Supports training up to 685B-parameter models via memory management

### Industry Templates (v4.0+)
- Agriculture: crop/fruit image classification
- Industrial: quality control object detection
- Healthcare: medical image segmentation
- Business: document OCR automation

---

## 4. AI TOP Utility Limitations

- **No CLI or API** - GUI-only, cannot be scripted or automated
- **No hardware tuning** - does not control power limits, fan curves, or clocks
- **No BIOS management** - cannot configure PCIe, memory timings, or CPU settings
- **No custom framework support** - uses its own fine-tuning pipeline, not PyTorch/JAX directly
- **Gigabyte hardware optimized** - may not work or may be limited on non-AI-TOP boards
- **Overlaps with existing tools** - for advanced users, tools like `unsloth`, `axolotl`, `transformers`, `llama.cpp`, and `ollama` provide more flexibility and scriptability

### Recommendation

For this workstation, the AI TOP Utility is **supplementary, not primary**. The system already has Ollama (v0.15.6), llama.cpp, and a full Python ML stack. AI TOP is useful for its:
- Convenient model download/conversion pipeline
- Visual hardware monitoring during training
- Memory offloading for very large models (400B+)

For everything else (GPU power management, fan control, system tuning, scriptable training), use the native Linux tools below.

---

## 5. Critical Finding: GPU0 PCIe Gen 1 Issue (CORRECTED)

### Current PCIe Link Status (DETECTED ISSUE)

```
GPU0 (41:00.0): PCIe Gen 1 x16 (2.5 GT/s) — should be Gen 5 x16 (32 GT/s) << SEVERELY DEGRADED
GPU1 (81:00.0): PCIe Gen 5 x16 (32 GT/s) — correct
Max supported: Gen 5 x16 (32 GT/s) for both (LnkCap confirms)
```

**GPU0 is running at PCIe Gen 1 (2.5 GT/s) instead of Gen 5 (32 GT/s).** This is a 12.8x bandwidth bottleneck. Both GPUs are Gen 5 capable (LnkCap: 32GT/s). GPU1 proves Gen 5 works on this board. Likely caused by PCIe signal integrity issues or a BIOS slot config error.

### Impact

| Mode | Bandwidth | Impact on AI Training |
|------|-----------|----------------------|
| PCIe Gen 1 x16 | ~4 GB/s | **Critical bottleneck** — 12.8x slower than Gen 5 |
| PCIe Gen 5 x16 | ~64 GB/s | Full bandwidth, no bottleneck (GPU1 already achieves this) |
| PCIe Gen 5 x16 | ~64 GB/s | Max spec (may have stability issues) |

For AI training workloads that shuffle large tensors between CPU and GPU memory, Gen 1 is ~12.8x slower than Gen 5. This directly impacts:
- Model loading time
- Gradient synchronization in multi-GPU training (NCCL/P2P)
- CPU-GPU data transfer during training batches
- Memory offloading performance

### Fix

1. **Update BIOS to F5a or newer** - Gigabyte released BIOS F5a specifically to fix PCIe lane initialization issues with RTX 50 series cards
2. **BIOS: Set PCIe slot to Gen 5 mode** (or Auto after BIOS update) - GPU1 proves Gen 5 works on this board
3. **BIOS: Disable ASPM** (Active State Power Management) for the affected slot - Prevents power-saving from downgrading link speed
4. **Reseat GPU0** physically - PCIe contact issues can cause fallback to lower gen
5. **Verify after boot**: `nvidia-smi --query-gpu=pcie.link.gen.current,pcie.link.width.current --format=csv`

### Verification Commands

```bash
# Check current PCIe link speed for both GPUs
nvidia-smi --query-gpu=name,pci.bus_id,pcie.link.gen.current,pcie.link.gen.max,pcie.link.width.current --format=csv

# Detailed PCIe link status via lspci
sudo lspci -vv -s 41:00.0 | grep -E "LnkSta:|LnkCap:"
sudo lspci -vv -s 81:00.0 | grep -E "LnkSta:|LnkCap:"

# Check if ASPM is active (should show "Disabled" for training)
sudo lspci -vv -s 41:00.0 | grep ASPM
```

---

## 6. Linux Native Alternative Stack

Since AI TOP does not handle system-level hardware optimization, here is the complete Linux stack for tuning this system for AI training:

| Tool | Purpose | Status on This System |
|------|---------|----------------------|
| `nvidia-smi` | GPU power limits, clocks, monitoring | Installed (590.48.01) |
| `nvidia-persistenced` | GPU persistence mode | Active (systemd) |
| `nvidia-settings` | GPU config, Coolbits, fan control (X11) | Installed |
| `nvtop` / `gpustat` | Real-time GPU monitoring | Check if installed |
| `lm-sensors` + `fancontrol` | System fan monitoring/control | Config lib installed, needs `sensors-detect` |
| `liquidctl` | AIO/pump cooler control | Not installed |
| `GreenWithEnvy (GWE)` | GUI GPU fan/OC control | Not installed (deprecated, X11-only) |
| `ipmitool` | IPMI/BMC management | Not installed (TRX50 consumer boards lack BMC) |
| `numactl` | NUMA topology control | Not installed (SHOULD BE) |
| `cpupower` / `cpufreq` | CPU governor management | Available (currently: powersave) |
| `sysctl` | Kernel parameter tuning | Available |
| `nvidia-cuda-mps-control` | CUDA Multi-Process Service | Available via CUDA toolkit |

### Packages to Install

```bash
# Essential for AI training optimization
sudo apt install -y numactl cpufrequtils lm-sensors liquidctl nvtop

# Configure lm-sensors
sudo sensors-detect --auto

# Optional: GPU monitoring
pip install gpustat
```

---

## 7. GPU Power Management (nvidia-smi)

### Current GPU Power Configuration

| Parameter | GPU0 (41:00.0) | GPU1 (81:00.0) |
|-----------|----------------|----------------|
| Current Power Limit | 575W | 575W |
| Default Power Limit | 575W | 575W |
| Min Power Limit | 400W | 400W |
| Max Power Limit | **600W** | 575W |
| Persistence Mode | Enabled | Enabled |
| Current Temp (idle) | 34C | 40C |
| Fan Speed (idle) | 0% | 0% |
| VRAM Total | 32,607 MiB | 32,607 MiB |
| VRAM Used (idle) | 5,558 MiB | 3,368 MiB |
| Max SM Clock | 3,105 MHz | 3,090 MHz |
| Max Memory Clock | 14,001 MHz | 14,001 MHz |
| PCIe Gen (current) | **Gen 2** | Gen 4 |
| PCIe Width | x16 | x16 |

**Note**: GPU0 has a higher max power limit (600W vs 575W), suggesting it may be a different SKU or has different firmware. GPU0 also has higher idle VRAM usage (5.5GB vs 3.4GB), indicating it is the display-connected GPU.

### Power Management Commands

```bash
# Set power limit for training (recommended: keep at default 575W for stability)
sudo nvidia-smi -i 0 -pl 575
sudo nvidia-smi -i 1 -pl 575

# For efficiency-focused training (lower power, ~5-10% perf reduction)
sudo nvidia-smi -i 0 -pl 500
sudo nvidia-smi -i 1 -pl 500

# Maximum power (GPU0 only, has 600W headroom)
sudo nvidia-smi -i 0 -pl 600

# Enable persistence mode (already enabled on this system)
sudo nvidia-smi -pm 1

# Lock GPU clocks for consistent performance during training
sudo nvidia-smi -i 0 -lgc 2100,3105
sudo nvidia-smi -i 1 -lgc 2100,3090

# Lock memory clocks
sudo nvidia-smi -i 0 -lmc 14001
sudo nvidia-smi -i 1 -lmc 14001

# Reset clocks after training
sudo nvidia-smi -rgc
sudo nvidia-smi -rmc

# Set compute mode to EXCLUSIVE_PROCESS for training
sudo nvidia-smi -i 0 -c EXCLUSIVE_PROCESS
sudo nvidia-smi -i 1 -c EXCLUSIVE_PROCESS

# Reset to DEFAULT mode when done
sudo nvidia-smi -i 0 -c DEFAULT
sudo nvidia-smi -i 1 -c DEFAULT
```

### Monitoring During Training

```bash
# Real-time monitoring (updates every 1 second)
watch -n 1 nvidia-smi

# CSV logging to file during training
nvidia-smi --query-gpu=timestamp,gpu_name,pci.bus_id,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,power.draw,clocks.sm,clocks.mem,pcie.link.gen.current --format=csv -l 5 > /tmp/gpu_training_log.csv &

# Detailed power sampling
nvidia-smi -q -d POWER

# Process-level GPU usage
nvidia-smi pmon -s um -d 1
```

---

## 8. CUDA MPS for Multi-GPU

CUDA Multi-Process Service (MPS) allows multiple CUDA processes to share a single GPU context, reducing context-switching overhead. This is useful for:
- Running multiple small training jobs on one GPU
- MPI-based distributed training
- Inference serving with multiple clients

### Important: MPS is Per-GPU

MPS does not handle multi-GPU coordination directly. For multi-GPU **training**, use:
- **PyTorch DDP** (DistributedDataParallel) - recommended for training
- **NCCL** (NVIDIA Collective Communications Library) - used by DDP for GPU-GPU communication
- **DeepSpeed** / **FSDP** - for large model training with memory optimization

### MPS Setup (Per-GPU, for Multi-Process Inference)

```bash
# Create directories
mkdir -p /tmp/nvidia-mps-gpu0 /tmp/nvidia-mps-gpu1
mkdir -p /tmp/nvidia-mps-log-gpu0 /tmp/nvidia-mps-log-gpu1

# GPU0 MPS server
export CUDA_VISIBLE_DEVICES=0
export CUDA_MPS_PIPE_DIRECTORY=/tmp/nvidia-mps-gpu0
export CUDA_MPS_LOG_DIRECTORY=/tmp/nvidia-mps-log-gpu0
nvidia-cuda-mps-control -d

# GPU1 MPS server (in separate shell)
export CUDA_VISIBLE_DEVICES=1
export CUDA_MPS_PIPE_DIRECTORY=/tmp/nvidia-mps-gpu1
export CUDA_MPS_LOG_DIRECTORY=/tmp/nvidia-mps-log-gpu1
nvidia-cuda-mps-control -d

# Stop MPS
echo quit | nvidia-cuda-mps-control
```

### Multi-GPU Training (PyTorch DDP)

```bash
# 2-GPU training with torchrun
torchrun --nproc_per_node=2 train.py

# With specific GPU selection
CUDA_VISIBLE_DEVICES=0,1 torchrun --nproc_per_node=2 train.py

# NCCL environment variables for optimization
export NCCL_P2P_DISABLE=0          # Enable P2P (direct GPU-GPU transfer)
export NCCL_IB_DISABLE=1           # Disable InfiniBand (not available)
export NCCL_SOCKET_IFNAME=eno1     # Use primary network interface
export NCCL_DEBUG=INFO             # Debug logging
```

### GPU Topology Impact on Training

Current topology (from `nvidia-smi topo -m`):
```
GPU0 <-> GPU1: NODE (traverses PCIe + interconnect within NUMA node)
Both GPUs: CPU Affinity 0-47, NUMA 0
```

This means GPU-GPU communication goes through the CPU's PCIe root complex, not NVLink. For multi-GPU training:
- **P2P transfers** will use PCIe, bandwidth limited to ~32 GB/s per direction (Gen 4 x16)
- **Gradient synchronization** overhead is moderate - suitable for data-parallel training
- **Model parallelism** across GPUs will have higher latency than NVLink systems
- **Recommendation**: Prefer data parallelism (duplicate model, split batches) over model parallelism (split model across GPUs)

---

## 9. Fan Control on Linux

### Current State
- Both GPUs report 0% fan speed at idle (fans off below ~40C, normal for RTX 5090)
- System fans are motherboard-controlled (no IPMI/BMC on consumer TRX50)
- No `lm-sensors` configured yet

### Option A: nvidia-settings + Coolbits (X11 Required)

```bash
# Add Coolbits to Xorg config (enables manual fan control)
# Create or edit /etc/X11/xorg.conf.d/20-nvidia.conf:
Section "Device"
    Identifier "Device0"
    Driver "nvidia"
    BusID "PCI:65:0:0"   # GPU0 (0x41 = 65 decimal)
    Option "Coolbits" "12"
EndSection

Section "Device"
    Identifier "Device1"
    Driver "nvidia"
    BusID "PCI:129:0:0"  # GPU1 (0x81 = 129 decimal)
    Option "Coolbits" "12"
EndSection

# After reboot/restart X11:
# Set GPU0 fan speed to 80%
nvidia-settings -a "[gpu:0]/GPUFanControlState=1" -a "[fan:0]/GPUTargetFanSpeed=80"

# Set GPU1 fan speed to 80%
nvidia-settings -a "[gpu:1]/GPUFanControlState=1" -a "[fan:1]/GPUTargetFanSpeed=80"

# Return to automatic fan control
nvidia-settings -a "[gpu:0]/GPUFanControlState=0"
nvidia-settings -a "[gpu:1]/GPUFanControlState=0"
```

**Caveat**: NVIDIA driver 465+ requires root access for cooler control. On Wayland (Pop!_OS default), nvidia-settings fan control may not work. Use X11 session or headless mode.

### Option B: nvidia-smi Fan Control (Driver 590+)

Starting with newer drivers, nvidia-smi may support fan control directly:

```bash
# Check if fan control is supported
nvidia-smi -q -d FAN

# Note: Direct fan speed control via nvidia-smi is limited on consumer GPUs.
# The GPU firmware manages fan curves automatically.
# For training, the default automatic fan curve is generally adequate -
# RTX 5090 fans will ramp to 60-80% under sustained load.
```

### Option C: System Fan Control (lm-sensors + fancontrol)

```bash
# Detect sensors
sudo sensors-detect --auto

# View current temps
sensors

# Configure fancontrol (for motherboard-managed fans)
sudo pwmconfig  # Interactive setup
sudo systemctl enable fancontrol
sudo systemctl start fancontrol
```

### Option D: liquidctl (for AIO/Pump Coolers)

If using an AIO liquid cooler on the CPU:

```bash
# Install
sudo apt install liquidctl

# List devices
sudo liquidctl list

# Set pump speed
sudo liquidctl set pump speed 100

# Set fan curve
sudo liquidctl set fan speed 20 30 30 50 35 70 40 90 45 100
```

### Recommended Fan Strategy for Training

- **GPU fans**: Leave on automatic. RTX 5090 has excellent thermal management and will self-regulate. Only override if temps exceed 85C sustained.
- **CPU fan**: Set to maximum during training. Threadripper PRO will generate significant heat under load.
- **Case fans**: Maximize airflow. AI training is a sustained thermal load, not burst.

---

## 10. Memory & Swap Optimization

### Current Configuration

| Parameter | Current Value | Recommended for AI Training |
|-----------|---------------|----------------------------|
| Total RAM | 503GB | Excellent - supports very large models |
| Swap (partition) | 4GB (/dev/dm-0) | Too small for AI workloads |
| Swap (zram) | 16GB (/dev/zram0, zstd) | Good for general use, not ideal for training |
| Total Swap | 20GB | Should be 64-128GB for large model training |
| vm.swappiness | 180 | **Too high** - aggressively swaps to zram, bad for GPU training |
| vm.dirty_ratio | 0 | Using bytes-based instead |
| vm.dirty_background_ratio | 0 | Using bytes-based instead |
| THP | madvise | Correct for AI workloads |
| HugePages | 0 reserved | OK (THP handles this) |
| zswap | Disabled | OK (zram is active instead) |

### Issues to Fix

**1. vm.swappiness = 180 is problematic for AI training**

A swappiness of 180 (with zram) aggressively compresses and swaps memory, which adds CPU overhead and latency. During AI training, you want all tensors in physical RAM, not compressed in zram.

```bash
# For AI training sessions, lower swappiness
sudo sysctl vm.swappiness=10

# To make permanent, add to /etc/sysctl.d/99-ai-training.conf:
vm.swappiness=10
```

**2. Consider larger swap for memory-offloaded training**

For training models larger than 64GB VRAM (combined) with CPU offloading:

```bash
# Create a 128GB swap file on NVMe for overflow
sudo fallocate -l 128G /swapfile-ai
sudo chmod 600 /swapfile-ai
sudo mkswap /swapfile-ai
sudo swapon -p 1 /swapfile-ai  # Lower priority than zram

# Add to /etc/fstab:
# /swapfile-ai none swap sw,pri=1 0 0
```

**3. Disable zram during training (optional)**

If you want maximum RAM availability and don't need zram:

```bash
# Temporarily disable zram
sudo swapoff /dev/zram0

# Re-enable after training
sudo swapon /dev/zram0
```

### Memory Tuning for AI Training

```bash
# /etc/sysctl.d/99-ai-training.conf

# Reduce swap pressure during training
vm.swappiness=10

# Increase dirty page limits for large I/O (dataset loading)
vm.dirty_bytes=4294967296          # 4GB
vm.dirty_background_bytes=1073741824  # 1GB

# Increase max memory map areas (required for large models)
vm.max_map_count=2097152

# Increase shared memory limits (for multi-process training)
kernel.shmmax=274877906944         # 256GB
kernel.shmall=67108864             # 256GB in pages

# Network tuning (for distributed training)
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=1048576
net.core.wmem_default=1048576
```

Apply without reboot:
```bash
sudo sysctl -p /etc/sysctl.d/99-ai-training.conf
```

---

## 11. NUMA & CPU Configuration

### Current State

- **NUMA**: Single NUMA node (node 0, all 48 threads)
  - Threadripper PRO 7965WX typically has 1 NUMA node unless NPS (Nodes Per Socket) is changed in BIOS
- **CPU Governor**: `powersave` -- **SHOULD BE `performance` FOR TRAINING**
- **numactl**: Not installed -- **SHOULD BE INSTALLED**

### Fix CPU Governor

```bash
# Immediately set to performance mode
sudo cpupower frequency-set -g performance

# Or for all CPUs explicitly
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $cpu
done

# Make permanent via systemd
sudo systemctl enable --now cpupower
# Edit /etc/default/cpupower: GOVERNOR="performance"
```

**Impact**: `powersave` governor reduces CPU frequency during "idle" periods, which during AI training means the CPU may not boost fast enough for data preprocessing, tokenization, and gradient operations. `performance` keeps all cores at maximum frequency.

### Install and Configure numactl

```bash
sudo apt install -y numactl

# Check NUMA topology
numactl --hardware

# Pin training process to NUMA node 0 (all memory local)
numactl --cpunodebind=0 --membind=0 python train.py

# For multi-GPU, bind each process to appropriate CPU cores
# GPU0 process: cores 0-23
taskset -c 0-23 python train_gpu0.py &
# GPU1 process: cores 24-47
taskset -c 24-47 python train_gpu1.py &
```

### BIOS NPS (Nodes Per Socket) Setting

For the Threadripper PRO 7965WX:
- **NPS=1** (default): All memory unified, single NUMA node - **best for most AI training**
- **NPS=2**: Split into 2 NUMA nodes - can help if GPUs are on different PCIe root complexes
- **NPS=4**: 4 NUMA nodes - generally worse for AI training, more cross-node traffic

**Recommendation**: Keep NPS=1 unless profiling shows NUMA contention.

---

## 12. BIOS Settings for AI Training

### Critical BIOS Settings (Gigabyte TRX50 AI TOP)

Access BIOS: Press DEL during POST.

| Setting | Location | Recommended | Why |
|---------|----------|-------------|-----|
| **PCIe Slot Mode** | Settings > IO Ports | Gen 4 (not Auto/Gen 5) | Fix PCIe Gen 2 fallback issue on GPU0 |
| **ASPM** | Settings > IO Ports > PCIe | Disabled | Prevents PCIe link speed downgrade |
| **Above 4G Decoding** | Settings > IO Ports | Enabled | Required for GPUs with >4GB VRAM |
| **Resizable BAR** | Settings > IO Ports | Enabled | Improves CPU-GPU memory access |
| **SR-IOV** | Settings > IO Ports | Disabled (unless using vGPU) | Adds overhead if not needed |
| **IOMMU/AMD-Vi** | Settings > AMD CBS | Enabled | Required for proper PCIe passthrough |
| **NPS** | Settings > AMD CBS > DF | NPS1 | Single NUMA node, unified memory |
| **Memory Profile** | Tweaker > XMP/EXPO | Enable EXPO profile | Run memory at rated speed |
| **ECC** | Tweaker > Memory | Enabled | Data integrity for long training runs |
| **CPU Power Limit (PPT)** | Tweaker > PBO | Auto or Manual (350W+) | Allow full CPU boost during training |
| **PBO (Precision Boost Overdrive)** | Tweaker > AMD CBS | Enabled | Allow CPU to boost above base clocks |
| **C-States** | Tweaker > AMD CBS > CPU | Disabled during training | Prevents CPU latency from power states |
| **Global C-state Control** | Settings > AMD CBS > CPU | Disabled | Same as above |
| **PCIe Bifurcation** | Settings > IO Ports | x16 (default) | Keep full x16 per GPU, board supports x8x8 if needed |
| **Fan Control** | Settings > Smart Fan | Aggressive/Full Speed | Maximum cooling for sustained loads |
| **ErP** | Settings > Platform Power | Disabled | Prevents aggressive power saving |

### PCIe Bifurcation on TRX50 AI TOP

The TRX50 AI TOP supports x8x8 bifurcation per slot. For the 2x RTX 5090 setup:
- **Slot 1** (GPU0): x16 mode (full bandwidth)
- **Slot 3** (GPU1): x16 mode (full bandwidth)
- The board has 76 PCIe 5.0 lanes total from the CPU
- 4x PCIe 5.0 x16 slots + 4x PCIe 5.0 x4 M.2 slots

---

## 13. Complete Optimization Script

Save as `/home/flexnetos/model-training-prep/configs/ai-training-optimize.sh`:

```bash
#!/bin/bash
# AI Training System Optimization Script
# For: Gigabyte TRX50 AI TOP + 2x RTX 5090 + Threadripper PRO 7965WX
# Usage: sudo bash ai-training-optimize.sh [start|stop]

set -euo pipefail

MODE="${1:-start}"

if [[ "$MODE" == "start" ]]; then
    echo "=== Optimizing system for AI training ==="

    # 1. GPU Persistence Mode
    echo "[GPU] Enabling persistence mode..."
    nvidia-smi -pm 1

    # 2. GPU Power Limits (max stable)
    echo "[GPU] Setting power limits..."
    nvidia-smi -i 0 -pl 575
    nvidia-smi -i 1 -pl 575

    # 3. Lock GPU clocks for consistent performance
    echo "[GPU] Locking GPU clocks..."
    nvidia-smi -i 0 -lgc 2100,3105
    nvidia-smi -i 1 -lgc 2100,3090

    # 4. CPU Governor
    echo "[CPU] Setting performance governor..."
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$gov"
    done

    # 5. Memory tuning
    echo "[MEM] Tuning kernel parameters..."
    sysctl -w vm.swappiness=10
    sysctl -w vm.max_map_count=2097152
    sysctl -w vm.dirty_bytes=4294967296
    sysctl -w vm.dirty_background_bytes=1073741824
    sysctl -w kernel.shmmax=274877906944
    sysctl -w kernel.shmall=67108864

    # 6. Disable zram (optional - frees ~16GB overhead)
    # Uncomment if you want maximum RAM:
    # echo "[MEM] Disabling zram..."
    # swapoff /dev/zram0 2>/dev/null || true

    # 7. Transparent Huge Pages
    echo "[MEM] Setting THP to madvise..."
    echo madvise > /sys/kernel/mm/transparent_hugepage/enabled

    # 8. Disable CPU C-states for lowest latency
    echo "[CPU] Disabling deep C-states..."
    for cpu in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
        echo 1 > "$cpu" 2>/dev/null || true
    done
    # Keep C0 and C1 enabled
    for cpu in /sys/devices/system/cpu/cpu*/cpuidle/state0/disable; do
        echo 0 > "$cpu" 2>/dev/null || true
    done

    # 9. PCIe link speed check
    echo ""
    echo "=== PCIe Link Status ==="
    nvidia-smi --query-gpu=name,pci.bus_id,pcie.link.gen.current,pcie.link.width.current --format=csv
    echo ""

    GEN0=$(nvidia-smi --query-gpu=pcie.link.gen.current --format=csv,noheader -i 0 | tr -d ' ')
    if [[ "$GEN0" -lt 4 ]]; then
        echo "WARNING: GPU0 is running at PCIe Gen $GEN0 instead of Gen 4!"
        echo "ACTION REQUIRED: Update BIOS to F5a+ and set PCIe mode to Gen 4"
        echo "See: ~/model-training-prep/research/gigabyte-ai-top.md section 5"
    fi

    # 10. NCCL optimization for multi-GPU
    echo "[NCCL] Setting environment variables..."
    export NCCL_P2P_DISABLE=0
    export NCCL_IB_DISABLE=1
    export NCCL_SOCKET_IFNAME=eno1
    echo "export NCCL_P2P_DISABLE=0" > /tmp/nccl_env.sh
    echo "export NCCL_IB_DISABLE=1" >> /tmp/nccl_env.sh
    echo "export NCCL_SOCKET_IFNAME=eno1" >> /tmp/nccl_env.sh

    echo ""
    echo "=== System optimized for AI training ==="
    echo "Source NCCL vars: source /tmp/nccl_env.sh"
    echo "To revert: sudo bash $0 stop"

elif [[ "$MODE" == "stop" ]]; then
    echo "=== Reverting training optimizations ==="

    # Reset GPU clocks
    nvidia-smi -rgc
    nvidia-smi -rmc

    # Reset CPU governor
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo powersave > "$gov"
    done

    # Reset memory params
    sysctl -w vm.swappiness=180
    sysctl -w vm.max_map_count=65530

    # Re-enable zram
    # swapon /dev/zram0 2>/dev/null || true

    # Re-enable C-states
    for cpu in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
        echo 0 > "$cpu" 2>/dev/null || true
    done

    echo "=== System reverted to default ==="
else
    echo "Usage: sudo bash $0 [start|stop]"
    exit 1
fi
```

---

## 14. Current System Audit

### What is Already Correct

- Persistence mode: Enabled (both GPUs)
- NVIDIA driver: 590.48.01 (current stable)
- CUDA: 13.1 (current)
- THP: madvise (correct for ML workloads)
- GPU power limits: At default 575W (correct)
- VRAM: 32GB per GPU, 64GB total (excellent)
- RAM: 503GB DDR5 ECC (excellent)
- zram: 16GB with zstd compression (functional)
- Both GPUs on NUMA node 0 (correct, single node)

### What Needs Fixing (Priority Order)

| Priority | Issue | Fix | Impact |
|----------|-------|-----|--------|
| **CRITICAL** | GPU0 at PCIe Gen 2 | BIOS update to F5a+ and set Gen 4 mode | 4x bandwidth improvement |
| **HIGH** | CPU governor = powersave | Set to `performance` | Up to 30% CPU throughput |
| **HIGH** | vm.swappiness = 180 | Set to 10 for training | Prevents memory thrashing |
| **HIGH** | numactl not installed | `apt install numactl` | Enables NUMA-aware process pinning |
| **MEDIUM** | vm.max_map_count = default | Set to 2097152 | Required for large model mmap |
| **MEDIUM** | No GPU clock locking | Lock clocks during training | Consistent performance |
| **MEDIUM** | lm-sensors not configured | Run sensors-detect | Temperature monitoring |
| **LOW** | No dedicated swap file | Create 128GB swap on NVMe | Overflow for huge models |
| **LOW** | ASPM possibly enabled | Disable in BIOS | Prevents PCIe speed drops |
| **LOW** | C-states enabled | Disable for training | Reduces CPU latency |

### Quick Fix Commands

```bash
# Fix the HIGH priority items immediately (no reboot needed):
sudo sysctl -w vm.swappiness=10
sudo apt install -y numactl
for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee "$gov"
done
sudo sysctl -w vm.max_map_count=2097152

# The CRITICAL PCIe issue requires a BIOS update + reboot.
```

---

## Sources

- [Gigabyte AI TOP Product Page](https://www.gigabyte.com/Consumer/ai-top/)
- [Gigabyte TRX50 AI TOP Motherboard](https://www.gigabyte.com/Motherboard/TRX50-AI-TOP)
- [Gigabyte AI TOP at CES 2026](https://www.prnewswire.com/news-releases/gigabyte-showcases-practical-ai-top-utility-for-local-ai-applications-at-ces-2026-302661790.html)
- [AI TOP Utility Download](https://www.gigabyte.com/Support/Utility/Motherboard?kw=AI+TOP)
- [AI TOP Utility 4.2.0 User Manual](https://manuals.plus/m/10bf5e7f71cac66f509967243143182eebff696adb4dffe82274d593380e6c5b)
- [AI TOP Utility 4.0 Release](https://www.techporn.ph/gigabyte-releases-ai-top-utility-version-4/)
- [Gigabyte PCIe Lanes Fix for RTX 50 Series](https://www.hwcooling.net/en/gigabyte-fixes-pcie-lanes-issue-on-boards-with-geforce-rtx-50/)
- [RTX 5090 PCIe Compatibility Issues](https://www.ofzenandcomputing.com/rtx-5090-fe-pcie-5-0-compatibility-issues-reported-owners-find-workaround-force-pcie-4-0-mode/)
- [TRX50 AI TOP PCIe Slot Discussion](https://forum.level1techs.com/t/gigabyte-trx50-ai-top-the-pciex16-slot-can-only-support-a-graphics-card-or-an-nvme-ssd/237195)
- [RTX 5090 Idle Power on Linux](https://forums.developer.nvidia.com/t/geforce-rtx-5090-idle-power-consumption/355465)
- [RTX 5090 AI Workloads Analysis](https://digitalspaceport.com/5090-for-ai-workloads-meta-analysis/)
- [TRX50 AI TOP BIOS Manual](https://download.gigabyte.com/FileList/Manual/mb_manual_trx50-bios_e.pdf)
- [NVIDIA MPS Documentation](https://docs.nvidia.com/deploy/mps/index.html)
- [Multi-GPU Linux Setup Guide](https://towardsdatascience.com/how-to-setup-a-multi-gpu-linux-machine-for-deep-learning-in-2024-df561a2d3328/)
- [GreenWithEnvy GitLab](https://gitlab.com/leinardi/gwe)
- [NVIDIA Coolbits - ArchWiki](https://wiki.archlinux.org/title/NVIDIA/Tips_and_tricks)
- [Gigabyte AI TOP Avadirect Review](https://www.avadirect.com/blog/unleashing-the-power-of-ai-with-the-gigabyte-trx50-ai-top-motherboard/)
