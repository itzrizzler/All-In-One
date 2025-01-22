# System Configuration Script

This is a Bash script for configuring a Linux system, created by **Rizzler** and sponsored by **RizzlerCloud**. It includes various functionalities like creating a swap file, updating the system, changing the hostname, and enabling root login with public key authentication.

1. **Run the script**: Execute the following command to download and run the script: ```bash bash <(curl -s https://raw.githubusercontent.com/itzrizzler/ServerConfg/refs/heads/main/install.sh) ```
   
## Features

1. **Create Swap File**  
   Prompt to create a swap file of user-defined size. Automatically formats and activates the swap file.

2. **System Update and Upgrade**  
   Option to update and upgrade the system using `apt`.

3. **Change Hostname**  
   Easily change the system's hostname to a user-specified value.

4. **Enable Root Login**  
   - Enables root login via SSH.
   - Removes specific restrictions in `/root/.ssh/authorized_keys`.
   - Ensures public key authentication is enabled.
   - Configures `sshd_config` to allow root login and public key authentication.

5. **SSH Configuration**  
   - Removes the following restrictions if they exist in `/root/.ssh/authorized_keys`:  
     ```text
     no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10"
     ```
   - Sets up secure permissions for `/root/.ssh/authorized_keys`.

## Requirements

- A Linux-based system.
- Root privileges to execute the script.
