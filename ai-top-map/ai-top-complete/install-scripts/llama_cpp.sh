#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo $SCRIPT_DIR

sudo apt install cmake -y
sudo apt install libcurl4-openssl-dev -y

echo "Download the model conversion package....."
cd ~
rm -rf Utility_dont_remove
mkdir Utility_dont_remove
cd Utility_dont_remove
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
git fetch origin c22473b580807929fd9e3a3344a48e8cfbe6c88f
git checkout c22473b580807929fd9e3a3344a48e8cfbe6c88f

echo "Build the model conversion package....."
cmake -B build
cmake --build build --config Release -j 4


echo "Finish."
exit 0
