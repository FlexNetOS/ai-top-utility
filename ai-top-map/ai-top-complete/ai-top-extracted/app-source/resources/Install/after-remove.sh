#!/bin/bash

# 遍歷 /home 目錄中的每個使用者目錄
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        user_data_path="$user_home/.config/gigabyte-ai-top-utility"

        # 檢查並移除使用者的配置目錄
        if [ -d "$user_data_path" ]; then
            rm -rf "$user_data_path"
            echo "Removed $user_data_path for user $user_home" >> /tmp/after-remove.log
        fi
    fi
done

# 嘗試刪除 root 使用者的配置目錄
root_data_path="/root/.config/gigabyte-ai-top-utility"
if [ -d "$root_data_path" ]; then
    rm -rf "$root_data_path"
    echo "Removed $root_data_path for root user" >> /tmp/after-remove.log
fi
