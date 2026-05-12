#!/bin/bash

sudo apt install -y ffmpeg
sudo apt install libstdc++-12-dev -y # For llama cpp
sudo apt install cmake -y # cmake version 3.22.1 for llama cpp
sudo apt install -y libopenblas-dev libomp-dev # ML MMSeg example

# 定義 Miniforge 安裝目錄
MINIFORGE_DIR="/opt/miniforge3"
MINIFORGE_FILE="Miniforge3-Linux-x86_64.sh"

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR

export PATH="$MINIFORGE_DIR/bin:$PATH"
source $MINIFORGE_DIR/bin/activate
conda init

# 定義 Miniforge 環境名稱
MINIFORGE_ENV="lmmllava"

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

echo "pip install --upgrade pip "
pip install --upgrade pip  # enable PEP 660 support

echo "pip cache purge......"
ipip cache purge

echo "pip install packages ......"
pip install diffusers==0.32.0
pip install transformers==4.55.0
pip install bitsandbytes==0.45.2
pip install accelerate==1.6.0
pip install imageio-ffmpeg==0.5.1
echo "Uninstall opencv-python packages......."
pip uninstall -y opencv-python
pip install opencv-python==4.10.0.84
pip install llama_index==0.12.19
pip install llama-index-core==0.12.19
pip install huggingface_hub==0.34.4
pip install langdetect==1.0.9
pip install docx2txt==0.8
pip install llama-index-llms-huggingface==0.4.2
pip install llama-index-embeddings-huggingface==0.5.1
pip install chromadb==0.6.3
pip install chroma-hnswlib==0.7.6
pip install llama-index-vector-stores-chroma==0.4.1
pip install soundfile==0.12.1
pip install librosa==0.10.2.post1
pip install ipython==8.28.0
pip install open-clip-torch==2.26.1

echo "ReInstall numpy...."
pip uninstall -y numpy
pip install numpy==1.26.4 --quiet

echo "ReInstall Torch..."
pip install torch==2.9.1+cu130 torchvision==0.24.1+cu130 torchaudio==2.9.1+cu130 --index-url https://download.pytorch.org/whl/cu130

echo "llama_cpp packages...."
pip install "sentencepiece>=0.1.98,<=0.2.0"
pip install protobuf==5.26.0
pip install "pytest>=5.2,<6.0"

echo "Install llama cpp python...."
# Enviroment
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export LD=/usr/bin/ld
export CUDACXX=/usr/local/cuda/bin/nvcc
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=89;120"
pip install llama-cpp-python==0.3.16 --no-cache --verbose

echo "ML packages................"
pip install nbformat==5.10.4 
pip install rfc3987==1.3.8
pip install unidecode==1.4.0 

echo "conda install -c conda-forge libstdcxx-ng=12"
conda install -c conda-forge libstdcxx-ng=12 -y

echo "Finish."
exit 0
