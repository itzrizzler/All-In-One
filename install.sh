#!/bin/bash

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error encountered. Exiting script."
        exit 1
    fi
}
sudo su
echo "Step 1: Updating the system"
echo "This will update your system packages and install nano (a text editor)."
echo "Please wait..."
apt update -y && sudo apt upgrade -y
echo "System update complete."

echo ""
echo "Step 2: Generating SSH key"
echo "This will generate an SSH key pair for secure authentication. Press Enter to continue."
echo "If asked for a passphrase, you can leave it empty (just press Enter)."
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
check_error
echo "SSH key generated."

echo ""
echo "Step 3: Changing SSH configuration"
echo "Next, you will edit the SSH configuration to allow password-based login."
echo "The script will open the file in nano editor."
echo "Add the following lines to the configuration file (if they are not already there):"
echo "  PubkeyAuthentication no"
echo "  PasswordAuthentication yes"
echo "  PermitRootLogin yes"
echo "  Port 22"
echo "After making changes, save the file by pressing CTRL+X, then Y, and Enter."
sudo nano /etc/ssh/sshd_config
check_error
echo "SSH configuration updated."

echo ""
echo "Step 4: Restarting SSH service"
echo "Now, we will restart the SSH service for the changes to take effect."
sudo systemctl restart sshd
check_error
echo "SSH service restarted."

echo ""
echo "Step 5: Changing your root password"
echo "You will now be prompted to change the root password."
echo "Enter your new password when asked, and confirm it."
passwd
check_error
echo "Password changed successfully."

echo ""
echo "Step 6: Restarting the VPS"
echo "The final step is to restart your VPS for all changes to apply."
echo "The script will now reboot your system."
sudo reboot
check_error
