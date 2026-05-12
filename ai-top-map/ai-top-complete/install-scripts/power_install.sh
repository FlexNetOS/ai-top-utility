#!/bin/bash

# 1. Add udev rule for USB device

# Define the rule you want to add
UDEV_RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="0414", ATTR{idProduct}=="7a5f", MODE="0666", GROUP="plugdev"'

# The udev rules file path
UDEV_FILE="/etc/udev/rules.d/99-usb.rules"

# Check if the rule is already present in the file
if grep -Fxq "$UDEV_RULE" $UDEV_FILE
then
    echo "The udev rule already exists in $UDEV_FILE."
else
    echo "Adding the udev rule to $UDEV_FILE..."
    # Add the rule to the file (requires sudo)
    echo $UDEV_RULE | sudo tee -a $UDEV_FILE > /dev/null
    
    # Reload udev rules
    echo "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    echo "The rule has been added and udev rules have been reloaded."
fi


# 2. Adjust permissions for the USB device

# Get the Bus and Device numbers for the USB device with ID 0414:7a5f
BUS_DEVICE=$(lsusb | grep '0414:7a5f' | awk '{print $2"/"$4}' | sed 's/://')

if [ -z "$BUS_DEVICE" ]; then
    echo "USB device with ID 0414:7a5f not found."
    exit 1
fi

# Display the device information
echo "Found device at /dev/bus/usb/$BUS_DEVICE"

# Adjust permissions
sudo chmod 666 /dev/bus/usb/$BUS_DEVICE

# Confirm permissions were changed
ls -l /dev/bus/usb/$BUS_DEVICE


# 3. Add the current user to the plugdev group

# Get the current user
CURRENT_USER=$(whoami)

# Add the user to the plugdev group
echo "Adding user $CURRENT_USER to the plugdev group..."
sudo usermod -aG plugdev $CURRENT_USER

# Check if the user was added successfully
if groups $CURRENT_USER | grep &>/dev/null '\bplugdev\b'; then
    echo "$CURRENT_USER has been added to the plugdev group."
    echo "Please log out and log back in to apply the changes."
else
    echo "Failed to add $CURRENT_USER to the plugdev group."
fi

echo "Finish."
exit 0

