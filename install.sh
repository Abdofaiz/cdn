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
mkdir -p /etc/autoscript

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

# Download and install core services
echo -e "Installing core services..."

# SSH Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/ssh/ssh-setup.sh)

# Dropbear Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/dropbear/dropbear-setup.sh)

# XRAY Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/xray/xray-setup.sh)

# OpenVPN Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/openvpn/openvpn-setup.sh)

# L2TP Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/l2tp/l2tp-setup.sh)

# WebSocket Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/websocket/ws-setup.sh)

# SlowDNS Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/slowdns/slowdns-setup.sh)

# UDPGW Setup
bash <(curl -Ls https://raw.githubusercontent.com/yourusername/autoscript/main/udpgw/udpgw-setup.sh)

# Create menu scripts
echo -e "Creating menu scripts..."

# Main Menu
cat > /usr/local/bin/menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         MAIN MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) SSH & OpenVPN Menu"
echo -e "2) XRAY Menu"
echo -e "3) L2TP Menu"
echo -e "4) WebSocket Menu"
echo -e "5) SlowDNS Menu"
echo -e "6) System Menu"
echo -e "7) Status Menu"
echo -e "8) Settings Menu"
echo -e "0) Exit"
echo -e ""
read -p "Select option: " choice

case \$choice in
    1) ssh-menu ;;
    2) xray-menu ;;
    3) l2tp-menu ;;
    4) ws-menu ;;
    5) slowdns-menu ;;
    6) system-menu ;;
    7) status-menu ;;
    8) settings-menu ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

chmod +x /usr/local/bin/menu

# Create additional menu scripts
for menu in ssh xray l2tp ws slowdns system status settings; do
    wget -O /usr/local/bin/${menu}-menu https://raw.githubusercontent.com/yourusername/autoscript/main/menu/${menu}-menu.sh
    chmod +x /usr/local/bin/${menu}-menu
done

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