#!/bin/bash
sudo apt install -y git # for LMM finetune
sudo apt-get install -y git-lfs # for downloading LLM model
sudo apt install -y pdsh # for multinode
sudo apt install -y openssh-server # for multinode
sudo apt-get install -y sshpass # for multinode
sudo apt install cmake -y # cmake version 3.22.1 for llama cpp
sudo apt install libstdc++-12-dev -y # For llama cpp
echo "sudo apt install libaio-dev....."
sudo apt install -y libaio-dev

# 定義 Miniforge 安裝目錄
MINIFORGE_DIR="/opt/miniforge3"
MINIFORGE_VERSION="25.3.1-0"
MINIFORGE_FILE="Miniforge3-Linux-x86_64.sh"
LLaMA_Factory="LLaMA-Factory"

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR

# 檢查 Miniforge 是否已安裝
if [ -d "$MINIFORGE_DIR" ]; then
    echo "Miniforge 已經安裝在 $MINIFORGE_DIR"
    # 添加 Miniforge 到當前會話的 PATH
    export PATH="$MINIFORGE_DIR/bin:$PATH"
    # 讓 conda 初始化
    source $MINIFORGE_DIR/bin/activate
    conda init
else
    echo "Miniforge 未安裝。正在進行安裝..." # Miniforge 預設使用 conda-forge，無商業限制
    # 下載 Miniforge（完全開源，預設使用 conda-forge）
    if [ ! -f "$SCRIPT_DIR/$MINIFORGE_FILE" ]; then
        wget --no-check-certificate https://github.com/conda-forge/miniforge/releases/download/$MINIFORGE_VERSION/$MINIFORGE_FILE -O /tmp/$MINIFORGE_FILE
    else
        echo "$MINIFORGE_FILE 已經存在。"
    fi
    # 使安裝腳本可執行
    chmod +x /tmp/$MINIFORGE_FILE
    # 執行安裝腳本
    sudo bash /tmp/$MINIFORGE_FILE -b -p $MINIFORGE_DIR
    # 添加 Miniforge 到當前會話的 PATH
    export PATH="$MINIFORGE_DIR/bin:$PATH"
    # 讓 conda 初始化
    source $MINIFORGE_DIR/bin/activate
    conda init
    echo "Miniforge 安裝完成並已添加到 PATH。"
    echo "Please run 'source ~/.bashrc' to update your PATH."
fi

# 定義 Miniforge 環境名稱
MINIFORGE_ENV="moellava_amd"

# Conda environment
if conda env list | grep -q "$MINIFORGE_ENV"; then
  echo "環境 $MINIFORGE_ENV 已經存在"
  echo "刪除舊的環境 $MINIFORGE_ENV"
  conda remove -n $MINIFORGE_ENV --all -y
  echo "重新建立環境 $MINIFORGE_ENV..."
  conda create -n $MINIFORGE_ENV python=3.10 -y
  echo "環境 $MINIFORGE_ENV 建立完成"
else
  echo "環境 $MINIFORGE_ENV 不存在，正在建立..."
  conda create -n $MINIFORGE_ENV python=3.10 -y
  echo "環境 $MINIFORGE_ENV 建立完成"
fi

echo "eval '$($MINIFORGE_DIR/bin/conda shell.bash hook)'"
eval "$($MINIFORGE_DIR/bin/conda shell.bash hook)"
echo "conda activate $MINIFORGE_ENV"
conda activate $MINIFORGE_ENV

echo "pip cache purge......"
pip uninstall -y unsloth
pip cache purge
pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git@dc26a7a0eb20c31549318396f53639ba8c01025e"

echo "pip install torch"
#pip3 install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/rocm5.7
pip3 install torch==2.9.1+rocm6.4 torchvision==0.24.1+rocm6.4 torchaudio==2.9.1+rocm6.4  --index-url https://download.pytorch.org/whl/rocm6.4

# 檢查 /opt 目錄下是否存在 rocm 版本化目錄
ROCM_DIR=$(ls -d /opt/rocm-* 2>/dev/null | head -n 1)
if [ -n "$ROCM_DIR" ]; then
    ROCM_VERSION=$(basename "$ROCM_DIR" | sed 's/rocm-//')
    echo "檢測到的 ROCm 版本: $ROCM_VERSION"
else
    ROCM_DIR = "/opt/rocm-6.4.1"
fi
# 設置環境變數，使用檢測到的版本和路徑
export ROCM_PATH="$ROCM_DIR"
export PATH="$PATH:$ROCM_DIR/bin:$ROCM_DIR/hip/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ROCM_DIR/lib:$ROCM_DIR/hip/lib"

echo "pip install -r $SCRIPT_DIR/$LLaMA_Factory/requirements_amd.txt  "
pip install -r $SCRIPT_DIR/$LLaMA_Factory/requirements_amd.txt
pip install omegaconf==2.3.0

echo "conda install -c conda-forge libstdcxx-ng=13"
conda install -c conda-forge libstdcxx-ng=13 -y

echo "ReInstall numpy...."
pip uninstall -y numpy
pip install numpy==1.26.4 --quiet


# Copy stage3.py to “~/.conda/envs/...
echo "patching deepspeed"
#cp -r $SCRIPT_DIR/cpp_extension_moellava_amd.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/torch/utils/cpp_extension.py
cp -r $SCRIPT_DIR/builder.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/swap_tensor/builder.py
cp $SCRIPT_DIR/builder.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/ops/op_builder
cp -r $SCRIPT_DIR/partitioned_param_swapper_amd.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/swap_tensor
cp $SCRIPT_DIR/stage3_amd.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/zero/stage3.py

echo "patching checkpoing file.........."
cp -r $SCRIPT_DIR/torch_checkpoint_engine.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/checkpoint_engine

echo "patching unsloth file.........."
cp -r $SCRIPT_DIR/cross_entropy_loss.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/kernels
cp -r $SCRIPT_DIR/rms_layernorm.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/kernels
cp -r $SCRIPT_DIR/llama.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/models
cp -r $SCRIPT_DIR/_utils.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/models


echo "Identify and set WSL mlock...."
if grep -qEi "(Microsoft|WSL)" /proc/version; then
    echo "WSL detected. Setting IPC lock capability..."
    sudo setcap cap_ipc_lock=+ep ~/.conda/envs/$MINIFORGE_ENV/bin/python3.10
fi


echo "Setting cache command........."
echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/tee /proc/sys/vm/drop_caches" \
| sudo tee /etc/sudoers.d/drop_caches >/dev/null \
&& sudo chmod 440 /etc/sudoers.d/drop_caches \
&& sudo visudo -cf /etc/sudoers.d/drop_caches


echo "Finish."
exit 0
