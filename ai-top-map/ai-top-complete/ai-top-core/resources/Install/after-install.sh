#!/bin/bash

echo "Running after-install.sh" >> /var/log/gigabyte-ai-top-utility_install.log

# 確保腳本以 sudo 權限運行
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root" >> /var/log/gigabyte-ai-top-utility_install.log
  exit
fi

# 獲取當前使用者名稱
USERNAME=$(who | awk '{print $1}')  # 使用 whoami 確保獲取的是真正登錄的使用者
echo "Now user：$USERNAME" >> /var/log/gigabyte-ai-top-utility_install.log

# 設定 main 程序的路徑
MAIN_PATH="/path/to/main"


# 判斷是 wsl環境
if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
  APP_DIR="/opt/gigabyte-ai-top-utility"
else
  APP_DIR="/opt/gigabyte-ai-top-utility"
fi

INSTALL_DIR="$APP_DIR/resources/app.asar.unpacked/resources/Install"
SCRIPTS_DIR="$APP_DIR/resources/app.asar.unpacked/resources/scripts"
LLAMA_FACTORY_DIR="$INSTALL_DIR/LLaMA-Factory"
VideoLLaVA_DIR="$INSTALL_DIR/Video-LLaVA"

# 給腳本添加執行權限

# 檢測系統架構和版本，設定對應的 main 程序
if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then
  # ARM64 架構
  MAIN_EXECUTABLE="mainArm64"
  echo "Detected ARM64 architecture, using mainArm64" >> /var/log/gigabyte-ai-top-utility_install.log
else
  # x86_64 架構，檢測 Ubuntu 版本
  UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null)
  if [ "$UBUNTU_VERSION" = "24.04" ]; then
    MAIN_EXECUTABLE="main2404"
    echo "Detected Ubuntu 24.04, using main2404" >> /var/log/gigabyte-ai-top-utility_install.log
  else
    MAIN_EXECUTABLE="main"
    echo "Detected Ubuntu $UBUNTU_VERSION (or other), using main" >> /var/log/gigabyte-ai-top-utility_install.log
  fi
fi

# 設定 main 程序的路徑
MAIN_PATH="$SCRIPTS_DIR/$MAIN_EXECUTABLE"

# 給對應的腳本添加執行權限
sudo chmod +x "$MAIN_PATH"
echo "Adding execute permission to scripts" >> /var/log/gigabyte-ai-top-utility_install.log

# 修正 .desktop 檔案，確保使用 --no-sandbox
DESKTOP_FILE="/usr/share/applications/gigabyte-ai-top-utility.desktop"

if [ -f "$DESKTOP_FILE" ]; then
    echo "Modifying desktop file to use --no-sandbox" >> /var/log/gigabyte-ai-top-utility_install.log
    sudo sed -i 's|Exec=.*|Exec=/opt/gigabyte-ai-top-utility/gigabyte-ai-top-utility --no-sandbox|' "$DESKTOP_FILE"
fi

# 安裝完成
echo "Installation completed" >> /var/log/gigabyte-ai-top-utility_install.log

exit 0
