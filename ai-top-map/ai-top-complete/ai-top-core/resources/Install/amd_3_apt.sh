#!/bin/bash
# Due to Ubuntu 24.04 Didn't have python-3.10
# Install deadsnakes/ppa to install it avoid error
echo "install python3.10"
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.10-dev build-essential -y

# Function to check and install a package
check_and_install() {
    local package=$1
    local display_name=$2

    # Check if the package is installed
    dpkg -s $package &> /dev/null
    if [ $? -eq 0 ]; then
        echo "$display_name is installed"
    else
        echo "$display_name is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y $package
        if [ $? -eq 0 ]; then
            echo "$display_name installed successfully"
        else
            echo "Failed to install $display_name" >&2
        fi
    fi
}

# Check and install python3-pip
check_and_install python3-pip "python3-pip"

# Check and install libaio-dev
check_and_install libaio-dev "libaio-dev"

# Check and install numactl
check_and_install numactl "numactl"

echo "Finish."
exit 0
