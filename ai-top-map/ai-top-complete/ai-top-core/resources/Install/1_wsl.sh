#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR
CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos"
CUDA_VERSION="12-8"
OS_TYPE="ubuntu2204"
CPU_TYPE="x86_64"
CUDA_DEB_FILE="cuda-keyring_1.1-1_all.deb"

check_and_add_to_path() {
    local dir=$1
    if ! grep -q "$dir" ~/.bashrc; then
        echo "export PATH=\$PATH:$dir" >> ~/.bashrc
        echo "Added $dir to PATH in ~/.bashrc. Please run 'source ~/.bashrc' to update your PATH."
    else
        echo "$dir is already in PATH."
    fi
}

# 檢查 nvidia-smi 是否可用
if ! command -v nvidia-smi &> /dev/null; then
    NVIDIA_SMI_PATH=$(find /usr /bin /usr/local /usr/local/cuda -name nvidia-smi 2>/dev/null | head -n 1)
    if [ -z "$NVIDIA_SMI_PATH" ]; then
        echo "nvidia-smi not found!" >&2
    elif ! $NVIDIA_SMI_PATH &> /dev/null; then
        echo "nvidia-smi is installed but not working correctly." >&2
    else
        NVIDIA_SMI_DIR=$(dirname $NVIDIA_SMI_PATH)
        check_and_add_to_path "$NVIDIA_SMI_DIR"
    fi
else
    echo "nvidia-smi is already in PATH and working correctly."
fi

# 檢查是否為 WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    echo "Running on WSL"
    OS_TYPE="wsl-ubuntu"
fi

# 檢查 nvcc 是否可用
if ! command -v nvcc &> /dev/null; then
    NVCC_PATH=$(find /usr /usr/local /usr/local/cuda* -name nvcc 2>/dev/null | head -n 1)
    if [ -z "$NVCC_PATH" ]; then
        echo "nvcc not found! Installing CUDA toolkit..."

        if [ ! -f "/tmp/$CUDA_DEB_FILE" ]; then
            echo "Downloading $CUDA_DEB_FILE..."
            wget ${CUDA_REPO_URL}/${OS_TYPE}/${CPU_TYPE}/${CUDA_DEB_FILE} -O /tmp/$CUDA_DEB_FILE
            if [ $? -ne 0 ]; then
                echo "Failed to download $CUDA_DEB_FILE" >&2
                exit 1
            fi
        else
            echo "$CUDA_DEB_FILE already exists."
        fi

        sudo apt-key del 7FA2AF80 2>/dev/null
        sudo dpkg -i /tmp/$CUDA_DEB_FILE
        if [ $? -ne 0 ]; then
            echo "Failed to install $CUDA_DEB_FILE" >&2
            exit 2
        fi

        sudo apt-get update
        sudo apt-get -y install cuda-toolkit-$CUDA_VERSION
        if [ $? -ne 0 ]; then
            echo "Failed to install CUDA toolkit" >&2
            exit 3
        fi

        NVCC_PATH=$(find /usr /usr/local /usr/local/cuda* -name nvcc 2>/dev/null | head -n 1)
        if [ -z "$NVCC_PATH" ]; then
            echo "nvcc installation failed or nvcc not found after installation!" >&2
            exit 4
        fi
    else
        echo "nvcc is installed but not in PATH."
    fi
    NVCC_DIR=$(dirname $NVCC_PATH)
    check_and_add_to_path "$NVCC_DIR"
    echo "nvcc is installed and working correctly. Please run 'source ~/.bashrc' to update your PATH."
else
    echo "nvcc is already in PATH and working correctly."
fi
echo "Finish."
exit 0
