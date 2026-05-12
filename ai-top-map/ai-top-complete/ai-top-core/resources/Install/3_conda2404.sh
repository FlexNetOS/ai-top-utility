#!/bin/bash
sudo apt install -y git # for LMM finetune
sudo apt-get install -y git-lfs # for downloading LLM model
sudo apt install -y pdsh # for multinode
sudo apt install -y openssh-server # for multinode
sudo apt-get install -y sshpass # for multinode

# 定義 Miniforge 安裝目錄
MINIFORGE_DIR="/opt/miniforge3"
MINIFORGE_VERSION="25.3.1-0"
MINIFORGE_FILE="Miniforge3-Linux-x86_64.sh"
LLaMA_Factory="LLaMA-Factory"

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR

# Set cuda path
echo "Export cuda c++ library "
export CUDA_HOME="/usr/local/cuda"
export LIBRARY_PATH="/usr/local/cuda/lib64:$LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
echo "Echo the variables to confirm they were set correctly"
echo "CUDA_HOME_PATH is set to: $CUDA_HOME"
echo "LIBRARY_PATH is set to: $LIBRARY_PATH"
echo "LD_LIBRARY_PATH is set to: $LD_LIBRARY_PATH"

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
MINIFORGE_ENV="moellava"


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

#echo "Install compilers (gcc and g++) for building and compiling C/C++ code with conda packages"
#conda install -c conda-forge gcc_linux-64 -y
#conda install -c conda-forge gxx_linux-64 -y

echo "pip cache purge......"
pip uninstall -y unsloth
pip cache purge
pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git@dc26a7a0eb20c31549318396f53639ba8c01025e"

echo "pip install -r $SCRIPT_DIR/$LLaMA_Factory/requirements.txt"
pip install -r $SCRIPT_DIR/$LLaMA_Factory/requirements.txt
echo "pip install omegaconf....."
pip install omegaconf==2.3.0

pip uninstall -y torch
pip uninstall -y torchaudio
pip uninstall -y torchvision

echo "pip install pytorch....."
pip install torch==2.10.0+cu130 torchvision==0.25.0+cu130 torchaudio==2.10.0+cu130 --index-url https://download.pytorch.org/whl/cu130

#echo "pip install flash-attn==2.6.1"
# pip install flash-attn==2.6.1

echo "conda install -c conda-forge libstdcxx-ng=13"
conda install -c conda-forge libstdcxx-ng=13 -y

echo "patching stage3.py"
cp -r $SCRIPT_DIR/stage3_2404.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/zero/stage3.py
cp -r $SCRIPT_DIR/stage_1_and_2_2404.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/zero/stage_1_and_2.py
cp -r $SCRIPT_DIR/cpp_extension_moellava.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/torch/utils/cpp_extension.py
#cp -r $SCRIPT_DIR/builder_nv.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/swap_tensor/builder.py
#cp -r $SCRIPT_DIR/op_builder.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/ops/op_builder/builder.py
cp -r $SCRIPT_DIR/partitioned_param_swapper_2404.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/swap_tensor/partitioned_param_swapper.py
#cp -r $SCRIPT_DIR/elastic_agent.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/elasticity
#cp -r $SCRIPT_DIR/engine.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime

echo "patching checkpoing file.........."
cp -r $SCRIPT_DIR/torch_checkpoint_engine.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/deepspeed/runtime/checkpoint_engine

echo "patching unsloth file.........."
cp -r $SCRIPT_DIR/cross_entropy_loss.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/kernels
cp -r $SCRIPT_DIR/rms_layernorm.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/kernels
cp -r $SCRIPT_DIR/llama.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/models
cp -r $SCRIPT_DIR/_utils.py ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/unsloth/models

echo "Install NCCL"
# Install NCCL
pip uninstall -y nvidia-nccl-cu12
sudo rm -rf /usr/local/nccl
sudo apt remove --purge -y libnccl2 libnccl-dev
# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#git config --global --add safe.directory "/opt/gigabyte-ai-top-utility/resources/app.asar.unpacked/resources/Install/nccl"
cd ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/
git clone --branch master --single-branch --depth 1 https://github.com/NVIDIA/nccl.git nccl && cd nccl && git fetch --unshallow && git checkout 3ea7eedf3b9b94f1d9f99f4e55536dfcbd23c1ca
#cp $SCRIPT_DIR/device.h ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/nccl/src/include
cd ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/nccl
make -j src.build
#make -j src.build NVCC_GENCODE="-gencode=arch=compute_120,code=sm_120"
sudo apt install -y build-essential devscripts debhelper fakeroot
make pkg.debian.build
ls build/pkg/deb/
cd ~/.conda/envs/$MINIFORGE_ENV/lib/python3.10/site-packages/nccl/build/pkg/deb/
sudo dpkg -i libnccl2_2.27.5-1+cuda12.9_amd64.deb
sudo dpkg -i libnccl2_2.27.5-1+cuda12.9_amd64.deb
sudo apt --fix-broken install -y
dpkg-query --showformat='${Package} ${Version}\n' --show libnccl2 libnccl-dev 


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
