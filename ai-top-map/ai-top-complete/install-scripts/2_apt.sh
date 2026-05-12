#!/bin/bash

# Due to Ubuntu 24.04 Didn't have python-3.10
# Install deadsnakes/ppa to install it avoid error
echo "install python3.10"
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.10-dev build-essential -y

# 檢查 pip3 是否已安裝
if command -v pip3 &> /dev/null; then
    echo "python3-pip 已安裝"
else
    echo "python3-pip 未安裝。正在進行安裝..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
    if [ $? -eq 0 ]; then
        echo "python3-pip 安裝成功"
    else
        echo "python3-pip 安裝失敗" >&2
    fi
fi

# 檢查 libaio-dev 是否已安裝
dpkg -s libaio-dev &> /dev/null
if [ $? -eq 0 ]; then
    echo "libaio-dev 已安裝"
else
    echo "libaio-dev 未安裝。正在進行安裝..."
    sudo apt-get update
    sudo apt-get install -y libaio-dev
    if [ $? -eq 0 ]; then
        echo "libaio-dev 安裝成功"
    else
        echo "libaio-dev 安裝失敗" >&2
    fi
fi
echo "Finish."
exit 0
