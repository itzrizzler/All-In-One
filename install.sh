#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Prompt for hostname change
read -p "Do you want to change the hostname? (y/n): " change_hostname

if [[ "$change_hostname" == "y" || "$change_hostname" == "Y" ]]; then
    read -p "Enter the new hostname: " new_hostname
    hostnamectl set-hostname $new_hostname
fi

# Edit authorized_keys file
sed -i '/no-port-forwarding/d' /root/.ssh/authorized_keys

# Edit SSH configuration
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart sshd

echo "Hostname changed and root login enabled. Please restart the system to apply changes."
