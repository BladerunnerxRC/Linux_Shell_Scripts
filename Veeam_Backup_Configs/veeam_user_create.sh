#!/bin/bash
#
# Veeam Linux Prep Script
# Creates a dedicated Veeam service account with passwordless sudo
# Designed for Ubuntu/Debian systems
#

set -e

VE_USER="veeam"

echo "=== Veeam Linux Prep Script ==="

# 1. Create the user if it doesn't exist
if id "$VE_USER" &>/dev/null; then
    echo "[INFO] User '$VE_USER' already exists."
else
    echo "[INFO] Creating user '$VE_USER'..."
    sudo useradd -m -s /bin/bash "$VE_USER"
    echo "[INFO] Set a password for '$VE_USER':"
    sudo passwd "$VE_USER"
fi

# 2. Add to sudo group
echo "[INFO] Adding '$VE_USER' to sudo group..."
sudo usermod -aG sudo "$VE_USER"

# 3. Configure passwordless sudo
SUDO_FILE="/etc/sudoers.d/99-$VE_USER"

echo "[INFO] Configuring passwordless sudo..."
echo "$VE_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee "$SUDO_FILE" >/dev/null
sudo chmod 440 "$SUDO_FILE"

# 4. Validate sudo works
echo "[INFO] Validating sudo access..."
sudo -u "$VE_USER" sudo whoami | grep -q "root" \
    && echo "[OK] Passwordless sudo validated." \
    || { echo "[ERROR] Passwordless sudo failed."; exit 1; }

# 5. Ensure SSH login is allowed
echo "[INFO] Ensuring SSH login is allowed for '$VE_USER'..."
sudo sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo systemctl reload sshd

echo "=== Completed successfully ==="
echo "The '$VE_USER' account is now ready for Veeam Managed Server integration."
