# AMDgpu-dkms rocm downloads and installation
sudo apt install -y "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
# See prerequisites. Adding current user to Video and Render groups
sudo usermod -a -G render,video $LOGNAME

# WSL uses ROCm-6.4.1 | Linux uses ROCm-7.1
if uname -r | grep -qi "microsoft"; then
    wget https://repo.radeon.com/amdgpu-install/6.4.1/ubuntu/noble/amdgpu-install_6.4.60401-1_all.deb
    sudo dpkg -i amdgpu-install_6.4.60401-1_all.deb
    sudo amdgpu-install --usecase=rocm,wsl --no-dkms -y            # ← 官方參數是 --no-dkms
else
    wget https://repo.radeon.com/amdgpu-install/7.1/ubuntu/noble/amdgpu-install_7.1.70100-1_all.deb
    sudo apt install ./amdgpu-install_7.1.70100-1_all.deb
    sudo amdgpu-install --usecase=rocm,dkms,hip -y                      # 預設含 DKMS
fi             

echo "Installation finished......."
sudo reboot
