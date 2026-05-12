#!/bin/bash
# AI Training System Optimization Script
# For: Gigabyte TRX50 AI TOP + 2x RTX 5090 + Threadripper PRO 7965WX
# Usage: sudo bash ai-training-optimize.sh [start|stop|status]
#
# Research: ~/model-training-prep/research/gigabyte-ai-top.md

set -euo pipefail

MODE="${1:-start}"

status_report() {
    echo "=== GPU Status ==="
    nvidia-smi --query-gpu=name,pci.bus_id,temperature.gpu,power.draw,power.limit,utilization.gpu,memory.used,memory.total,pcie.link.gen.current,pcie.link.width.current,persistence_mode --format=csv
    echo ""
    echo "=== CPU Governor ==="
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo ""
    echo "=== Memory ==="
    free -h
    echo ""
    echo "=== Swap ==="
    swapon --show
    echo ""
    echo "=== Key Sysctl ==="
    sysctl vm.swappiness vm.max_map_count vm.dirty_bytes vm.dirty_background_bytes 2>/dev/null
    echo ""
    echo "=== THP ==="
    cat /sys/kernel/mm/transparent_hugepage/enabled
    echo ""
    echo "=== GPU Topology ==="
    nvidia-smi topo -m
}

if [[ "$MODE" == "start" ]]; then
    echo "=== Optimizing system for AI training ==="

    # 1. GPU Persistence Mode
    echo "[GPU] Enabling persistence mode..."
    nvidia-smi -pm 1

    # 2. GPU Power Limits (max stable)
    echo "[GPU] Setting power limits to 575W..."
    nvidia-smi -i 0 -pl 575
    nvidia-smi -i 1 -pl 575

    # 3. Lock GPU clocks for consistent performance
    echo "[GPU] Locking GPU clocks..."
    nvidia-smi -i 0 -lgc 2100,3105 2>/dev/null || echo "[GPU] Clock lock not supported on GPU0"
    nvidia-smi -i 1 -lgc 2100,3090 2>/dev/null || echo "[GPU] Clock lock not supported on GPU1"

    # 4. CPU Governor to performance
    echo "[CPU] Setting performance governor..."
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$gov" 2>/dev/null || true
    done

    # 5. Memory tuning
    echo "[MEM] Tuning kernel parameters..."
    sysctl -w vm.swappiness=10
    sysctl -w vm.max_map_count=2097152
    sysctl -w vm.dirty_bytes=4294967296
    sysctl -w vm.dirty_background_bytes=1073741824
    sysctl -w kernel.shmmax=274877906944
    sysctl -w kernel.shmall=67108864

    # 6. Transparent Huge Pages
    echo "[MEM] Setting THP to madvise..."
    echo madvise > /sys/kernel/mm/transparent_hugepage/enabled

    # 7. Disable deep CPU C-states for lowest latency
    echo "[CPU] Disabling deep C-states..."
    for state_dir in /sys/devices/system/cpu/cpu*/cpuidle/state*/; do
        state_name=$(cat "${state_dir}name" 2>/dev/null || echo "")
        if [[ "$state_name" != "POLL" && "$state_name" != "C1" ]]; then
            echo 1 > "${state_dir}disable" 2>/dev/null || true
        fi
    done

    # 8. NCCL environment for multi-GPU training
    echo "[NCCL] Writing environment variables to /tmp/nccl_env.sh..."
    cat > /tmp/nccl_env.sh << 'NCCL_EOF'
export NCCL_P2P_DISABLE=0
export NCCL_IB_DISABLE=1
export NCCL_SOCKET_IFNAME=eno1
export NCCL_DEBUG=WARN
export CUDA_DEVICE_ORDER=PCI_BUS_ID
NCCL_EOF
    chmod 644 /tmp/nccl_env.sh

    # 9. PCIe link speed check
    echo ""
    echo "=== PCIe Link Status ==="
    nvidia-smi --query-gpu=name,pci.bus_id,pcie.link.gen.current,pcie.link.gen.max,pcie.link.width.current --format=csv
    echo ""

    GEN0=$(nvidia-smi --query-gpu=pcie.link.gen.current --format=csv,noheader -i 0 | tr -d ' ')
    GEN1=$(nvidia-smi --query-gpu=pcie.link.gen.current --format=csv,noheader -i 1 | tr -d ' ')

    if [[ "$GEN0" -lt 4 ]]; then
        echo "!!! WARNING: GPU0 running at PCIe Gen $GEN0 (expected Gen 4) !!!"
        echo "!!! ACTION: Update BIOS to F5a+, set PCIe mode to Gen 4, disable ASPM !!!"
        echo "!!! See: ~/model-training-prep/research/gigabyte-ai-top.md section 5 !!!"
        echo ""
    fi

    if [[ "$GEN1" -lt 4 ]]; then
        echo "!!! WARNING: GPU1 running at PCIe Gen $GEN1 (expected Gen 4) !!!"
        echo ""
    fi

    echo "=== System optimized for AI training ==="
    echo ""
    echo "Next steps:"
    echo "  source /tmp/nccl_env.sh    # Load NCCL environment"
    echo "  sudo bash $0 status        # Check system status"
    echo "  sudo bash $0 stop          # Revert optimizations"

elif [[ "$MODE" == "stop" ]]; then
    echo "=== Reverting training optimizations ==="

    # Reset GPU clocks
    echo "[GPU] Resetting GPU clocks..."
    nvidia-smi -rgc 2>/dev/null || true
    nvidia-smi -rmc 2>/dev/null || true

    # Reset CPU governor to powersave
    echo "[CPU] Setting powersave governor..."
    for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo powersave > "$gov" 2>/dev/null || true
    done

    # Reset memory params to Pop!_OS defaults
    echo "[MEM] Resetting kernel parameters..."
    sysctl -w vm.swappiness=180
    sysctl -w vm.max_map_count=65530

    # Re-enable C-states
    echo "[CPU] Re-enabling C-states..."
    for cpu in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
        echo 0 > "$cpu" 2>/dev/null || true
    done

    # Clean up
    rm -f /tmp/nccl_env.sh

    echo "=== System reverted to default configuration ==="

elif [[ "$MODE" == "status" ]]; then
    status_report

else
    echo "AI Training System Optimization Script"
    echo ""
    echo "Usage: sudo bash $0 [start|stop|status]"
    echo ""
    echo "  start   - Apply all training optimizations"
    echo "  stop    - Revert to default system settings"
    echo "  status  - Show current GPU, CPU, memory status"
    exit 1
fi
