#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Display a welcome message
echo "Please ensure you are running this script as root."
echo "This script is created by Rizzler and sponsored by RizzlerCloud."

# Prompt for system update and upgrade
read -p "Do you want to update and upgrade the system first? (y/n): " update_upgrade

if [[ "$update_upgrade" == "y" || "$update_upgrade" == "Y" ]]; then
    sudo apt update && sudo apt upgrade -y
    echo "System updated and upgraded."
fi

# Prompt for hostname change
read -p "Do you want to change the hostname? (y/n): " change_hostname

if [[ "$change_hostname" == "y" || "$change_hostname" == "Y" ]]; then
    read -p "Enter the new hostname: " new_hostname
    hostnamectl set-hostname $new_hostname
fi

# Prompt for enabling root login
read -p "Do you want to enable root login? (y/n): " enable_root_login

if [[ "$enable_root_login" == "y" || "$enable_root_login" == "Y" ]]; then
    # Edit authorized_keys file
    sed -i '/no-port-forwarding/d' /root/.ssh/authorized_keys

    # Edit SSH configuration
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

    # Restart SSH service
    systemctl restart sshd

    echo "Root login enabled. Please restart the system to apply changes."
else
    echo "Root login not enabled."
fi

# Prompt for swap file creation
read -p "Do you want to create a swap file? (y/n): " create_swap

if [[ "$create_swap" == "y" || "$create_swap" == "Y" ]]; then
    read -p "Enter the size of the swap file (e.g., 1G for 1 gigabyte, 512M for 512 megabytes): " size

    # Append 'G' if no unit is specified
    if [[ ! $size =~ ^[0-9]+[MG]$ ]]; then
        size="${size}G"
    fi

    # Validate size input
    if [[ ! $size =~ ^[0-9]+[MG]$ ]]; then
        echo "Invalid size. Please specify size in megabytes (M) or gigabytes (G)."
        exit 1
    fi

    # Create swap file
    echo "Creating a swap file of size $size..."
    sudo fallocate -l "$size" /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Error creating swap file. Please ensure you have sufficient disk space."
        exit 1
    fi

    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Failed to format swap file. It may be corrupted or too small."
        exit 1
    fi

    sudo swapon /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Failed to enable swap file."
        exit 1
    fi

    # Update /etc/fstab
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    # Update system configuration
    sudo sysctl vm.swappiness=10
    sudo sysctl vm.vfs_cache_pressure=50
    sudo bash -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"
    sudo bash -c "echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf"

    echo "Swap file created and system configuration updated."
else
    echo "Swap file creation skipped."
fi
