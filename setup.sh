#!/bin/bash
# Automated VPS Setup Script

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check root
if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Create directories
echo -e "Creating directories..."
mkdir -p /usr/local/bin
mkdir -p /etc/xray
mkdir -p /var/log/xray
mkdir -p /etc/cdn

# Download all menu scripts
echo -e "Downloading menu scripts..."
cd /usr/local/bin
wget -q -O menu-master.zip https://github.com/Abdofaiz/faiz-vpn/archive/refs/heads/main.zip
unzip -qq menu-master.zip
cp -rf faiz-vpn-main/menu/* /usr/local/bin/
rm -rf faiz-vpn-main menu-master.zip

# Set permissions
echo -e "Setting permissions..."
chmod +x /usr/local/bin/*
chown root:root /usr/local/bin/*

# Create symbolic links
echo -e "Creating symbolic links..."
for script in /usr/local/bin/*; do
    name=$(basename $script)
    ln -sf $script /usr/bin/$name 2>/dev/null
done

# Add to PATH
echo -e "Updating PATH..."
echo 'export PATH="/usr/local/bin:$PATH"' > /etc/profile.d/custom-path.sh
source /etc/profile.d/custom-path.sh

# Create auto-update script
cat > /usr/local/bin/update-scripts <<EOF
#!/bin/bash
cd /usr/local/bin
wget -q -O menu-master.zip https://github.com/Abdofaiz/faiz-vpn/archive/refs/heads/main.zip
unzip -qq menu-master.zip
cp -rf faiz-vpn-main/menu/* /usr/local/bin/
rm -rf faiz-vpn-main menu-master.zip
chmod +x /usr/local/bin/*
echo -e "${GREEN}Scripts updated successfully!${NC}"
EOF
chmod +x /usr/local/bin/update-scripts

# Add auto-update to cron
echo "0 0 * * * root /usr/local/bin/update-scripts >/dev/null 2>&1" > /etc/cron.d/autoupdate-scripts

# Create menu command
echo -e "Creating menu command..."
cat > /usr/local/bin/menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         MAIN MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) SSH & OpenVPN Menu"
echo -e "2) XRAY Menu"
echo -e "3) System Menu"
echo -e "4) Status Menu"
echo -e "5) Tools Menu"
echo -e "0) Exit"
echo -e ""
read -p "Select option: " choice

case \$choice in
    1) ssh-menu ;;
    2) xray-menu ;;
    3) system-menu ;;
    4) status-menu ;;
    5) tools-menu ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF
chmod +x /usr/local/bin/menu

echo -e "${GREEN}Installation completed!${NC}"
echo -e "Use 'menu' command to access VPS management menu"
echo -e "Use 'update-scripts' to manually update all scripts"
echo -e "${BLUE}=============================${NC}"

# Initial setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/install.sh) 