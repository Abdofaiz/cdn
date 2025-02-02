#!/bin/bash
# Comprehensive VPS Installation Script

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

clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    VPS INSTALLATION SCRIPT    ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""

# System preparation
echo -e "Preparing system..."
timedatectl set-timezone Asia/Jakarta
apt update && apt upgrade -y
apt install -y wget curl git unzip jq build-essential net-tools

# Create required directories
mkdir -p /etc/xray
mkdir -p /var/log/xray
mkdir -p /usr/local/bin
mkdir -p /etc/cdn

# Install essential packages
echo -e "Installing essential packages..."
apt install -y \
    nginx \
    squid \
    vnstat \
    fail2ban \
    iptables \
    iptables-persistent \
    socat \
    openssl \
    netcat \
    python3 \
    python3-pip \
    cron \
    openssh-server \
    stunnel4

# Setup menu system
echo -e "Setting up menu system..."
cd /usr/local/bin
wget -q -O menu-master.zip https://github.com/Abdofaiz/faiz-vpn/archive/refs/heads/main.zip
unzip -qq menu-master.zip
cp -rf faiz-vpn-main/menu/* /usr/local/bin/
rm -rf faiz-vpn-main menu-master.zip

# Set permissions
chmod +x /usr/local/bin/*
chown root:root /usr/local/bin/*

# Create symbolic links
for script in /usr/local/bin/*; do
    name=$(basename $script)
    ln -sf $script /usr/bin/$name 2>/dev/null
done

# Add to PATH
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

# Download and install core services
echo -e "Installing core services..."

# SSH Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/ssh/ssh-setup.sh)

# Dropbear Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/dropbear/dropbear-setup.sh)

# XRAY Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/xray/xray-setup.sh)

# OpenVPN Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/openvpn/openvpn-setup.sh)

# L2TP Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/l2tp/l2tp-setup.sh)

# WebSocket Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/websocket/ws-setup.sh)

# SlowDNS Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/slowdns/slowdns-setup.sh)

# UDPGW Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/menu/udpgw/udpgw-setup.sh)

# Setup auto-start service
cat > /etc/systemd/system/vps-startup.service <<EOF
[Unit]
Description=VPS Startup Script
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vps-startup
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create startup script
cat > /usr/local/bin/vps-startup <<EOF
#!/bin/bash
# Restore iptables
iptables-restore < /etc/iptables/rules.v4

# Start all services
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart openvpn*
systemctl restart xray
systemctl restart xl2tpd
systemctl restart nginx
systemctl restart slowdns-server
systemctl restart badvpn-udpgw

# Clear expired users
/usr/local/bin/delete-expired
EOF

chmod +x /usr/local/bin/vps-startup
systemctl enable vps-startup

# Setup auto delete expired users
echo "0 0 * * * root /usr/local/bin/delete-expired" >> /etc/crontab

# Final setup
echo -e "${GREEN}Installation completed!${NC}"
echo -e "Use 'menu' command to access VPS management menu"
echo -e "Use 'update-scripts' to manually update all scripts"
echo -e "Default ports:"
echo -e "SSH: 22, 443"
echo -e "Dropbear: 143, 109"
echo -e "Stunnel: 445, 777"
echo -e "OpenVPN: 1194 (TCP), 2200 (UDP)"
echo -e "XRAY: 8443, 2083, 2087, 2096"
echo -e "L2TP: 1701, 500, 4500"
echo -e "WebSocket: 80"
echo -e "SlowDNS: 53, 5300"
echo -e "UDPGW: 7300"

# Reboot confirmation
read -p "System needs to reboot. Reboot now? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
fi