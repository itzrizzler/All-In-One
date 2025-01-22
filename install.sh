#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Display a welcome message
echo "Welcome to the System Configuration Script."
echo "Created by Rizzler and sponsored by RizzlerCloud."

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
    fallocate -l "$size" /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Error creating swap file. Please ensure you have sufficient disk space."
        exit 1
    fi

    chmod 600 /swapfile
    mkswap /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Failed to format swap file. It may be corrupted or too small."
        exit 1
    fi

    swapon /swapfile
    if [[ $? -ne 0 ]]; then
        echo "Failed to enable swap file."
        exit 1
    fi

    # Update /etc/fstab
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

    # Update system configuration
    sysctl vm.swappiness=10
    sysctl vm.vfs_cache_pressure=50
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
    echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf

    echo "Swap file created and system configuration updated."
fi

# Prompt for system update and upgrade
read -p "Do you want to update and upgrade the system? (y/n): " update_upgrade

if [[ "$update_upgrade" == "y" || "$update_upgrade" == "Y" ]]; then
    echo "Updating and upgrading system..."
    apt update && apt upgrade -y
    if [[ $? -ne 0 ]]; then
        echo "Error updating and upgrading system. Please check logs for details."
    else
        echo "System updated and upgraded successfully."
    fi
fi

# Prompt for hostname change
read -p "Do you want to change the hostname? (y/n): " change_hostname

if [[ "$change_hostname" == "y" || "$change_hostname" == "Y" ]]; then
    read -p "Enter the new hostname: " new_hostname
    hostnamectl set-hostname "$new_hostname"
    echo "Hostname changed to $new_hostname."
fi

# Prompt for enabling root login
read -p "Do you want to enable root login and allow public key authentication? (y/n): " enable_root_login

if [[ "$enable_root_login" == "y" || "$enable_root_login" == "Y" ]]; then
    # Ensure the root authorized_keys file exists
    mkdir -p /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys

    # Configure SSH for root login and public key authentication
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # Restart SSH service to apply changes
    systemctl restart sshd
    if [[ $? -ne 0 ]]; then
        echo "Failed to restart SSH service. Please check your SSH configuration."
        exit 1
    fi

    echo "Root login and public key authentication enabled successfully."
else
    echo "Root login not enabled."
fi

echo "Script execution completed."
