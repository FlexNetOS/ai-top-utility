sudo apt install -y git # for LMM finetune
sudo apt-get install -y git-lfs # for downloading LLM model
sudo apt install ffmpeg -y

# 定義 Miniforge 安裝目錄
MINIFORGE_DIR="/opt/miniforge3"
MINIFORGE_VERSION="25.3.1-0"
MINIFORGE_FILE="Miniforge3-25.3.1-0-Linux-aarch64.sh"
# 檢查 Miniforge 是否已安裝
if [ -d "$MINIFORGE_DIR" ]; then
    echo "Miniforge at >>>> $MINIFORGE_DIR"
    export PATH="$MINIFORGE_DIR/bin:$PATH"
    source $MINIFORGE_DIR/bin/activate
    conda init
else
    echo "Miniforge not exist..."

    # 下載必要文件
    if [ ! -f "./$MINIFORGE_FILE" ]; then
        wget --no-check-certificate https://github.com/conda-forge/miniforge/releases/download/$MINIFORGE_VERSION/$MINIFORGE_FILE -O /tmp/$MINIFORGE_FILE
    else
        echo "$MINIFORGE_FILE exist."
    fi

    chmod +x /tmp/$MINIFORGE_FILE
    sudo bash /tmp/$MINIFORGE_FILE -b -p $MINIFORGE_DIR
    export PATH="$MINIFORGE_DIR/bin:$PATH"
    source $MINIFORGE_DIR/bin/activate
    conda init
    echo "Miniforge install success."
    echo "Please run 'source ~/.bashrc' to update your PATH."
fi

export CONDA_ENVS_DIRS="$HOME/.conda/envs"
export CONDA_PKGS_DIRS="$HOME/.conda/pkgs"

# 定義 Miniforge 環境名稱
MINIFORGE_ENV="lmmllava"

# Conda environment
if conda env list | grep -q "$MINIFORGE_ENV"; then
  echo "$MINIFORGE_ENV exist."
  echo "Delete old $MINIFORGE_ENV"
  conda remove -n $MINIFORGE_ENV --all -y
  echo "Create new $MINIFORGE_ENV..."
  conda create -n $MINIFORGE_ENV python=3.10 -y
  echo "$MINIFORGE_ENV create success!"
else
  echo "$MINIFORGE_ENV not exist."
  conda create -n $MINIFORGE_ENV python=3.10 -y
  echo "$MINIFORGE_ENV create success!"
fi

echo "eval '$($MINIFORGE_DIR/bin/conda shell.bash hook)'"
eval "$($MINIFORGE_DIR/bin/conda shell.bash hook)"
echo "conda activate $MINIFORGE_ENV"
conda activate $MINIFORGE_ENV

conda install -n lmmllava -c conda-forge libstdcxx-ng=13.3.0 -y

#Install list
echo "Installing Python Packages..."
pip cache purge

CUDA_VERSION=13.0
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export LD=/usr/bin/ld
export CUDACXX=/usr/local/cuda-$CUDA_VERSION/bin/nvcc
export PATH=/usr/local/cuda-$CUDA_VERSION/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
export CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=121"
pip install llama-cpp-python==0.3.16 --no-cache --verbose

pip3 install torch==2.8.0+cu129 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129
pip install pydantic==2.12.0
pip install transformers==4.55.0
pip install peft==0.17.0
pip install diffusers==0.35.0
pip install protobuf==6.31.1
pip install sentencepiece==0.2.0
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

echo "Setting cache command........."
echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/tee /proc/sys/vm/drop_caches" \
| sudo tee /etc/sudoers.d/drop_caches >/dev/null \
&& sudo chmod 440 /etc/sudoers.d/drop_caches \
&& sudo visudo -cf /etc/sudoers.d/drop_caches


pip install unidecode==1.4.0
pip install nbformat==5.10.4


echo "finish"
exit 0