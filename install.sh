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

# Direct installation command
if [ "$1" = "--install" ]; then
    clear
    echo -e "${BLUE}Starting direct installation...${NC}"
    # Download and execute setup
    wget -O setup.sh https://raw.githubusercontent.com/Abdofaiz/faiz-vpn/main/setup.sh
    chmod +x setup.sh
    ./setup.sh
    rm setup.sh
    exit 0
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

# Download and install core services
echo -e "Installing core services..."

# SSH Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/ssh/ssh-setup.sh)

# Dropbear Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/dropbear/dropbear-setup.sh)

# XRAY Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/xray/xray-setup.sh)

# OpenVPN Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/openvpn/openvpn-setup.sh)

# L2TP Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/l2tp/l2tp-setup.sh)

# WebSocket Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/websocket/ws-setup.sh)

# SlowDNS Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/slowdns/slowdns-setup.sh)

# UDPGW Setup
bash <(curl -Ls https://raw.githubusercontent.com/Abdofaiz/cdn/main/udpgw/udpgw-setup.sh)

# Create menu scripts
echo -e "Creating menu scripts..."

# Main Menu
cat > /usr/local/bin/menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         MAIN MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e ""
echo -e "XRAY MENU"
echo -e " 1) Vmess Menu"
echo -e " 2) Vless Menu"
echo -e " 3) Trojan Menu"
echo -e ""
echo -e "SSH MENU"
echo -e " 4) SSH Menu"
echo -e ""
echo -e "SYSTEM MENU"
echo -e " 5) Running Services"
echo -e " 6) RAM Usage"
echo -e " 7) System Version"
echo -e " 8) Domain Settings"
echo -e " 9) Login Monitor"
echo -e ""
echo -e "MANAGEMENT MENU"
echo -e "10) Change Port"
echo -e "11) Backup Data"
echo -e "12) Restore Data"
echo -e "13) Webmin Panel"
echo -e "14) Speedtest"
echo -e "15) Auto Reboot"
echo -e ""
echo -e "ADDITIONAL MENU"
echo -e "16) Update Script"
echo -e "17) Install BBR"
echo -e "18) Clear Log"
echo -e "19) Clear Cache"
echo -e "20) Auto Kill Multi Login"
echo -e " 0) Exit"
echo -e ""
echo -e "${BLUE}=============================${NC}"
read -p "Select menu : " choice

case \$choice in
    1) vmess-menu ;;
    2) vless-menu ;;
    3) trojan-menu ;;
    4) ssh-menu ;;
    5) running ;;
    6) ram ;;
    7) version ;;
    8) add-host ;;
    9) login ;;
    10) port ;;
    11) backup ;;
    12) restore ;;
    13) webmin ;;
    14) speedtest ;;
    15) auto-reboot ;;
    16) update ;;
    17) bbr ;;
    18) clear-log ;;
    19) clear-cache ;;
    20) autokill ;;
    0) exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

chmod +x /usr/local/bin/menu

# Create additional menu scripts
for menu in ssh xray l2tp ws slowdns system status settings; do
    wget -O /usr/local/bin/${menu}-menu https://raw.githubusercontent.com/Abdofaiz/cdn/main/menu/${menu}-menu.sh
    chmod +x /usr/local/bin/${menu}-menu
done

# Create submenu scripts
echo -e "Creating submenu scripts..."

# 1. VMESS Menu
cat > /usr/local/bin/vmess-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}        VMESS MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) Create Account"
echo -e "2) Trial Account"
echo -e "3) Extend Account"
echo -e "4) Delete Account"
echo -e "5) Check User Login"
echo -e "6) Check Usage"
echo -e "7) Show Config"
echo -e "0) Exit"
read -p "Select menu : " choice
case \$choice in
    1) add-vmess ;;
    2) trial-vmess ;;
    3) renew-vmess ;;
    4) del-vmess ;;
    5) cek-vmess ;;
    6) usage-vmess ;;
    7) config-vmess ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# 2. VLESS Menu
cat > /usr/local/bin/vless-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}        VLESS MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) Create Account"
echo -e "2) Trial Account"
echo -e "3) Extend Account"
echo -e "4) Delete Account"
echo -e "5) Check User Login"
echo -e "6) Check Usage"
echo -e "7) Show Config"
echo -e "0) Exit"
read -p "Select menu : " choice
case \$choice in
    1) add-vless ;;
    2) trial-vless ;;
    3) renew-vless ;;
    4) del-vless ;;
    5) cek-vless ;;
    6) usage-vless ;;
    7) config-vless ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# 3. TROJAN Menu
cat > /usr/local/bin/trojan-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}       TROJAN MENU          ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) Create Account"
echo -e "2) Trial Account"
echo -e "3) Extend Account"
echo -e "4) Delete Account"
echo -e "5) Check User Login"
echo -e "6) Check Usage"
echo -e "7) Show Config"
echo -e "0) Exit"
read -p "Select menu : " choice
case \$choice in
    1) add-trojan ;;
    2) trial-trojan ;;
    3) renew-trojan ;;
    4) del-trojan ;;
    5) cek-trojan ;;
    6) usage-trojan ;;
    7) config-trojan ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# 4. SSH Menu
cat > /usr/local/bin/ssh-menu <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}         SSH MENU           ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) Create Account"
echo -e "2) Trial Account"
echo -e "3) Extend Account"
echo -e "4) Delete Account"
echo -e "5) Check User Login"
echo -e "6) List Member"
echo -e "7) Delete Expired"
echo -e "8) Auto Kill Multi Login"
echo -e "9) Check Multi Login"
echo -e "0) Exit"
read -p "Select menu : " choice
case \$choice in
    1) add-ssh ;;
    2) trial-ssh ;;
    3) renew-ssh ;;
    4) del-ssh ;;
    5) cek-ssh ;;
    6) member-ssh ;;
    7) delete-expired ;;
    8) autokill-menu ;;
    9) ceklim ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

# Set permissions for all menus
chmod +x /usr/local/bin/vmess-menu
chmod +x /usr/local/bin/vless-menu
chmod +x /usr/local/bin/trojan-menu
chmod +x /usr/local/bin/ssh-menu

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

# Create individual function scripts
echo -e "Creating function scripts..."

# System monitoring scripts
cat > /usr/local/bin/running <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    RUNNING SERVICES        ${NC}"
echo -e "${BLUE}=============================${NC}"

services=("ssh" "dropbear" "stunnel4" "xray" "nginx" "squid" "openvpn" "xl2tpd" "badvpn-udpgw")

for service in "\${services[@]}"; do
    status=\$(systemctl is-active \$service)
    if [ "\$status" = "active" ]; then
        echo -e "\$service : ${GREEN}Running${NC}"
    else
        echo -e "\$service : ${RED}Not Running${NC}"
    fi
done
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/ram <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}       RAM USAGE           ${NC}"
echo -e "${BLUE}=============================${NC}"

total=\$(free -m | grep Mem | awk '{print \$2}')
used=\$(free -m | grep Mem | awk '{print \$3}')
free=\$(free -m | grep Mem | awk '{print \$4}')
cache=\$(free -m | grep Mem | awk '{print \$6}')

echo -e "Total RAM    : \${total}MB"
echo -e "Used RAM     : \${used}MB"
echo -e "Free RAM     : \${free}MB"
echo -e "Cache        : \${cache}MB"
echo -e ""
echo -e "Top 5 RAM-using processes:"
ps aux | sort -rn -k 4 | head -5 | awk '{print \$4"% - "\$11}'
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/version <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     SYSTEM VERSION         ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "OS          : \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "Kernel      : \$(uname -r)"
echo -e "Arch        : \$(uname -m)"
echo -e "Script Ver  : \$(cat /etc/xray/version 2>/dev/null || echo 'Not installed')"
echo -e "XRAY Ver    : \$(xray -version 2>/dev/null | head -n1 || echo 'Not installed')"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/add-host <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    DOMAIN SETTINGS         ${NC}"
echo -e "${BLUE}=============================${NC}"

# Current domain
current=\$(cat /etc/xray/domain 2>/dev/null || echo 'Not set')
echo -e "Current Domain: \$current"
echo -e ""

# Add new domain
read -p "Enter new domain: " new_domain

# Verify domain
echo -e "Verifying domain..."
if host \$new_domain >/dev/null 2>&1; then
    echo \$new_domain > /etc/xray/domain
    echo -e "${GREEN}Domain updated successfully${NC}"
    
    # Update certificates
    echo -e "Updating SSL certificate..."
    systemctl stop nginx
    certbot certonly --standalone -d \$new_domain --non-interactive --agree-tos --email admin@\$new_domain
    systemctl start nginx
    
    echo -e "${GREEN}SSL certificate updated${NC}"
else
    echo -e "${RED}Domain \$new_domain is not valid or DNS not propagated${NC}"
fi
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/login <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     LOGIN MONITOR          ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "OpenSSH Login:"
data=\$(netstat -tnpa | grep 'ESTABLISHED.*sshd')
echo -e "\$data" | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c

echo -e "\nDropbear Login:"
data=\$(netstat -tnpa | grep 'ESTABLISHED.*dropbear')
echo -e "\$data" | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c

echo -e "\nXRAY Login:"
data=\$(netstat -tnpa | grep 'ESTABLISHED.*xray')
echo -e "\$data" | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c

echo -e "${BLUE}=============================${NC}"
EOF

# Set permissions
chmod +x /usr/local/bin/running
chmod +x /usr/local/bin/ram
chmod +x /usr/local/bin/version
chmod +x /usr/local/bin/add-host
chmod +x /usr/local/bin/login

# Management function scripts
cat > /usr/local/bin/port <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     PORT MANAGEMENT        ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "1) Change SSH Port"
echo -e "2) Change Dropbear Port"
echo -e "3) Change Stunnel Port"
echo -e "4) Change XRAY Port"
echo -e "5) Change OpenVPN Port"
echo -e "6) Change Squid Port"
echo -e "0) Exit"
read -p "Select menu : " port_choice

change_port() {
    service=\$1
    current=\$2
    echo -e "Current \$service port: \$current"
    read -p "New port: " new_port
    if [[ \$new_port =~ ^[0-9]+\$ ]] && [ \$new_port -ge 1 ] && [ \$new_port -le 65535 ]; then
        sed -i "s/\$current/\$new_port/g" \$3
        systemctl restart \$service
        echo -e "${GREEN}\$service port changed to \$new_port${NC}"
    else
        echo -e "${RED}Invalid port number${NC}"
    fi
}

case \$port_choice in
    1) change_port "ssh" "22" "/etc/ssh/sshd_config" ;;
    2) change_port "dropbear" "143" "/etc/default/dropbear" ;;
    3) change_port "stunnel4" "443" "/etc/stunnel/stunnel.conf" ;;
    4) change_port "xray" "8443" "/etc/xray/config.json" ;;
    5) change_port "openvpn" "1194" "/etc/openvpn/server.conf" ;;
    6) change_port "squid" "3128" "/etc/squid/squid.conf" ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
EOF

cat > /usr/local/bin/backup <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}      BACKUP DATA           ${NC}"
echo -e "${BLUE}=============================${NC}"

# Set backup directory
backup_dir="/root/backup"
mkdir -p \$backup_dir

# Create backup name with date
date_now=\$(date +%Y-%m-%d)
backup_name="backup_\$date_now.zip"

# Files to backup
echo -e "Creating backup..."
zip -r \$backup_dir/\$backup_name /etc/xray /etc/ssh /etc/stunnel /etc/openvpn /etc/shadowsocks

# Optional: Upload to cloud storage
read -p "Upload to cloud storage? [y/n]: " upload_choice
if [[ \$upload_choice =~ ^[Yy]\$ ]]; then
    # Add your cloud upload logic here
    echo -e "Uploading to cloud..."
fi

echo -e "${GREEN}Backup completed: \$backup_dir/\$backup_name${NC}"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/restore <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     RESTORE DATA           ${NC}"
echo -e "${BLUE}=============================${NC}"

backup_dir="/root/backup"

if [ ! -d "\$backup_dir" ]; then
    echo -e "${RED}No backup directory found${NC}"
    exit 1
fi

echo -e "Available backups:"
ls -1 \$backup_dir/*.zip 2>/dev/null || echo "No backups found"
echo -e ""

read -p "Enter backup name to restore: " backup_name

if [ -f "\$backup_dir/\$backup_name" ]; then
    echo -e "Restoring backup..."
    unzip -o \$backup_dir/\$backup_name -d /
    
    # Restart services
    systemctl restart ssh
    systemctl restart xray
    systemctl restart stunnel4
    systemctl restart openvpn
    
    echo -e "${GREEN}Restore completed${NC}"
else
    echo -e "${RED}Backup file not found${NC}"
fi
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/webmin <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     WEBMIN PANEL           ${NC}"
echo -e "${BLUE}=============================${NC}"

if ! command -v webmin >/dev/null 2>&1; then
    echo -e "Installing Webmin..."
    wget -O - http://www.webmin.com/jcameron-key.asc | apt-key add -
    echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
    apt update
    apt install -y webmin
    echo -e "${GREEN}Webmin installed${NC}"
else
    echo -e "Webmin is already installed"
fi

ip=\$(curl -s ifconfig.me)
echo -e "Access Webmin at: https://\$ip:10000"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/speedtest <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}      SPEEDTEST            ${NC}"
echo -e "${BLUE}=============================${NC}"

if ! command -v speedtest-cli >/dev/null 2>&1; then
    echo -e "Installing speedtest-cli..."
    apt install -y speedtest-cli
fi

echo -e "Running speedtest..."
speedtest-cli --simple
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/auto-reboot <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}     AUTO REBOOT            ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "1) Set auto-reboot time"
echo -e "2) Disable auto-reboot"
echo -e "0) Exit"
read -p "Select menu : " choice

case \$choice in
    1)
        read -p "Set auto-reboot time (00-23): " hour
        if [[ \$hour =~ ^[0-9]+\$ ]] && [ \$hour -ge 0 ] && [ \$hour -le 23 ]; then
            echo "0 \$hour * * * root /sbin/reboot" > /etc/cron.d/auto-reboot
            echo -e "${GREEN}Auto-reboot set to \$hour:00${NC}"
        else
            echo -e "${RED}Invalid hour${NC}"
        fi
        ;;
    2)
        rm -f /etc/cron.d/auto-reboot
        echo -e "${GREEN}Auto-reboot disabled${NC}"
        ;;
    0) menu ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
esac
echo -e "${BLUE}=============================${NC}"
EOF

# Set permissions
chmod +x /usr/local/bin/port
chmod +x /usr/local/bin/backup
chmod +x /usr/local/bin/restore
chmod +x /usr/local/bin/webmin
chmod +x /usr/local/bin/speedtest
chmod +x /usr/local/bin/auto-reboot

# User Management Functions
cat > /usr/local/bin/add-ssh <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    CREATE SSH ACCOUNT      ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Password : " Pass
read -p "Duration (days) : " masaaktif

IP=\$(curl -sS ipv4.icanhazip.com)
domain=\$(cat /etc/xray/domain)
ssl_port="443"
ssh_port="22"
ws_port="80"

useradd -e \`date -d "\$masaaktif days" +"%Y-%m-%d"\` -s /bin/false -M \$Login
echo -e "\$Pass\n\$Pass\n"|passwd \$Login &> /dev/null

echo -e "${BLUE}=============================${NC}"
echo -e "SSH Account Information"
echo -e "${BLUE}=============================${NC}"
echo -e "Username   : \$Login"
echo -e "Password   : \$Pass"
echo -e "IP         : \$IP"
echo -e "Domain     : \$domain"
echo -e "OpenSSH    : \$ssh_port"
echo -e "SSL/TLS    : \$ssl_port"
echo -e "WebSocket  : \$ws_port"
echo -e "Expiry     : \$masaaktif Days"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/add-vmess <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   CREATE VMESS ACCOUNT     ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Duration (days) : " masaaktif

domain=\$(cat /etc/xray/domain)
uuid=\$(cat /proc/sys/kernel/random/uuid)
exp=\`date -d "\$masaaktif days" +"%Y-%m-%d"\`

# Add user to XRAY config
sed -i '/#vmess$/a\### \$Login \$exp\
},{"id": "'"\$uuid"'","alterId": 0,"email": "'"\$Login"'"' /etc/xray/config.json

# Restart XRAY
systemctl restart xray

# Create link
vmess_link="vmess://\$(echo -n "{\"v\":\"2\",\"ps\":\"\$Login\",\"add\":\"\$domain\",\"port\":\"443\",\"id\":\"\$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"path\":\"/vmess\",\"type\":\"none\",\"host\":\"\$domain\",\"tls\":\"tls\"}" | base64 -w 0)"

echo -e "${BLUE}=============================${NC}"
echo -e "VMESS Account Information"
echo -e "${BLUE}=============================${NC}"
echo -e "Username   : \$Login"
echo -e "Domain     : \$domain"
echo -e "Port TLS   : 443"
echo -e "UUID       : \$uuid"
echo -e "Path       : /vmess"
echo -e "Expiry     : \$exp"
echo -e ""
echo -e "Link TLS   : \$vmess_link"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/add-vless <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   CREATE VLESS ACCOUNT     ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Duration (days) : " masaaktif

domain=\$(cat /etc/xray/domain)
uuid=\$(cat /proc/sys/kernel/random/uuid)
exp=\`date -d "\$masaaktif days" +"%Y-%m-%d"\`

# Add user to XRAY config
sed -i '/#vless$/a\### \$Login \$exp\
},{"id": "'"\$uuid"'","email": "'"\$Login"'"' /etc/xray/config.json

# Restart XRAY
systemctl restart xray

# Create links
vless_tls="vless://\$uuid@\$domain:443?path=/vless&security=tls&encryption=none&type=ws#\$Login"
vless_none="vless://\$uuid@\$domain:80?path=/vless&encryption=none&type=ws#\$Login"

echo -e "${BLUE}=============================${NC}"
echo -e "VLESS Account Information"
echo -e "${BLUE}=============================${NC}"
echo -e "Username   : \$Login"
echo -e "Domain     : \$domain"
echo -e "Port TLS   : 443"
echo -e "Port None  : 80"
echo -e "UUID       : \$uuid"
echo -e "Path       : /vless"
echo -e "Expiry     : \$exp"
echo -e ""
echo -e "Link TLS   : \$vless_tls"
echo -e "Link None  : \$vless_none"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/add-trojan <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   CREATE TROJAN ACCOUNT    ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Duration (days) : " masaaktif

domain=\$(cat /etc/xray/domain)
uuid=\$(cat /proc/sys/kernel/random/uuid)
exp=\`date -d "\$masaaktif days" +"%Y-%m-%d"\`

# Add user to XRAY config
sed -i '/#trojan$/a\### \$Login \$exp\
},{"password": "'"\$uuid"'","email": "'"\$Login"'"' /etc/xray/config.json

# Restart XRAY
systemctl restart xray

# Create link
trojan_link="trojan://\$uuid@\$domain:443?path=/trojan&security=tls&host=\$domain&type=ws&sni=\$domain#\$Login"

echo -e "${BLUE}=============================${NC}"
echo -e "Trojan Account Information"
echo -e "${BLUE}=============================${NC}"
echo -e "Username   : \$Login"
echo -e "Domain     : \$domain"
echo -e "Port       : 443"
echo -e "Password   : \$uuid"
echo -e "Path       : /trojan"
echo -e "Expiry     : \$exp"
echo -e ""
echo -e "Link       : \$trojan_link"
echo -e "${BLUE}=============================${NC}"
EOF

# Create delete user scripts
cat > /usr/local/bin/del-ssh <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   DELETE SSH ACCOUNT       ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login

if getent passwd \$Login > /dev/null 2>&1; then
    userdel -f \$Login
    echo -e "${GREEN}User \$Login deleted successfully${NC}"
else
    echo -e "${RED}User \$Login does not exist${NC}"
fi
EOF

cat > /usr/local/bin/del-vmess <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   DELETE VMESS ACCOUNT     ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login

if grep -q "### \$Login" "/etc/xray/config.json"; then
    sed -i "/### \$Login/,/\"email\": \"$Login\"/d" /etc/xray/config.json
    systemctl restart xray
    echo -e "${GREEN}User \$Login deleted successfully${NC}"
else
    echo -e "${RED}User \$Login does not exist${NC}"
fi
EOF

# Renewal Scripts
cat > /usr/local/bin/renew-ssh <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    RENEW SSH ACCOUNT       ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Days to add : " masaaktif

if getent passwd \$Login > /dev/null 2>&1; then
    exp_old=\$(chage -l \$Login | grep "Account expires" | awk -F": " '{print \$2}')
    exp_new=\$(date -d "\$exp_old + \$masaaktif days" +"%Y-%m-%d")
    chage -E \$exp_new \$Login
    echo -e "${GREEN}Account \$Login renewed until \$exp_new${NC}"
else
    echo -e "${RED}User \$Login does not exist${NC}"
fi
EOF

cat > /usr/local/bin/renew-vmess <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   RENEW VMESS ACCOUNT      ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Days to add : " masaaktif

if grep -q "### \$Login" "/etc/xray/config.json"; then
    exp_old=\$(grep -wA 1 "### \$Login" "/etc/xray/config.json" | tail -1 | awk -F' ' '{print \$2}')
    exp_new=\$(date -d "\$exp_old + \$masaaktif days" +"%Y-%m-%d")
    sed -i "s/### \$Login \$exp_old/### \$Login \$exp_new/g" /etc/xray/config.json
    systemctl restart xray
    echo -e "${GREEN}Account \$Login renewed until \$exp_new${NC}"
else
    echo -e "${RED}User \$Login does not exist${NC}"
fi
EOF

# Checking Scripts
cat > /usr/local/bin/cek-ssh <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    CHECK SSH LOGINS        ${NC}"
echo -e "${BLUE}=============================${NC}"

if [ -e "/var/log/auth.log" ]; then
    LOG="/var/log/auth.log"
elif [ -e "/var/log/secure" ]; then
    LOG="/var/log/secure"
fi

data=( \`ps aux | grep -i ssh | grep -i priv | awk '{print \$2}'\` );
echo -e "Current SSH Logins:"
echo -e "ID  |  Username  |  IP Address"
echo -e "${BLUE}=============================${NC}"
for pid in "\${data[@]}"
do
    cat \$LOG | grep -i ssh | grep -i "Accepted password" | grep "sshd[\$pid]" | tail -n1 | while read login ; do
        akun=\$(echo \$login | awk '{print \$9}')
        ip=\$(echo \$login | awk '{print \$11}')
        echo -e "\$pid | \$akun | \$ip"
    done
done
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/cek-vmess <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   CHECK VMESS LOGINS       ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "User | Connection | IP Address"
echo -e "${BLUE}=============================${NC}"
grep -E "email:" "/var/log/xray/access.log" | tail -n50 | awk '{print \$3" | "\$7" | "\$1}' | sort | uniq
echo -e "${BLUE}=============================${NC}"
EOF

# Trial Account Scripts
cat > /usr/local/bin/trial-ssh <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   CREATE TRIAL SSH         ${NC}"
echo -e "${BLUE}=============================${NC}"

# Generate random username and password
Login=trial\$(tr -dc 'a-z0-9' < /dev/urandom | head -c4)
Pass=\$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c8)
masaaktif="1" # 1 day trial

IP=\$(curl -sS ipv4.icanhazip.com)
domain=\$(cat /etc/xray/domain)

useradd -e \`date -d "\$masaaktif days" +"%Y-%m-%d"\` -s /bin/false -M \$Login
echo -e "\$Pass\n\$Pass\n"|passwd \$Login &> /dev/null

echo -e "${BLUE}=============================${NC}"
echo -e "Trial SSH Account"
echo -e "${BLUE}=============================${NC}"
echo -e "Username   : \$Login"
echo -e "Password   : \$Pass"
echo -e "IP         : \$IP"
echo -e "Domain     : \$domain"
echo -e "Expired    : \$masaaktif Day"
echo -e "${BLUE}=============================${NC}"
EOF

cat > /usr/local/bin/trial-vmess <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   CREATE TRIAL VMESS       ${NC}"
echo -e "${BLUE}=============================${NC}"

# Generate random username and UUID
Login=trial\$(tr -dc 'a-z0-9' < /dev/urandom | head -c4)
uuid=\$(cat /proc/sys/kernel/random/uuid)
masaaktif="1" # 1 day trial
domain=\$(cat /etc/xray/domain)
exp=\`date -d "\$masaaktif days" +"%Y-%m-%d"\`

# Add to XRAY config
sed -i '/#vmess$/a\### \$Login \$exp\
},{"id": "'"\$uuid"'","alterId": 0,"email": "'"\$Login"'"' /etc/xray/config.json
systemctl restart xray

# Create link
vmess_link="vmess://\$(echo -n "{\"v\":\"2\",\"ps\":\"\$Login\",\"add\":\"\$domain\",\"port\":\"443\",\"id\":\"\$uuid\",\"aid\":\"0\",\"net\":\"ws\",\"path\":\"/vmess\",\"type\":\"none\",\"host\":\"\$domain\",\"tls\":\"tls\"}" | base64 -w 0)"

echo -e "${BLUE}=============================${NC}"
echo -e "Trial VMESS Account"
echo -e "${BLUE}=============================${NC}"
echo -e "Username   : \$Login"
echo -e "Domain     : \$domain"
echo -e "Port       : 443"
echo -e "UUID       : \$uuid"
echo -e "Path       : /vmess"
echo -e "Expired    : \$exp"
echo -e ""
echo -e "Link       : \$vmess_link"
echo -e "${BLUE}=============================${NC}"
EOF

# Set permissions for new scripts
chmod +x /usr/local/bin/renew-ssh
chmod +x /usr/local/bin/renew-vmess
chmod +x /usr/local/bin/cek-ssh
chmod +x /usr/local/bin/cek-vmess
chmod +x /usr/local/bin/trial-ssh
chmod +x /usr/local/bin/trial-vmess

# VLESS and Trojan Management Scripts
cat > /usr/local/bin/renew-vless <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   RENEW VLESS ACCOUNT      ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Days to add : " masaaktif

if grep -q "### \$Login" "/etc/xray/config.json"; then
    exp_old=\$(grep -wA 1 "### \$Login" "/etc/xray/config.json" | tail -1 | awk -F' ' '{print \$2}')
    exp_new=\$(date -d "\$exp_old + \$masaaktif days" +"%Y-%m-%d")
    sed -i "s/### \$Login \$exp_old/### \$Login \$exp_new/g" /etc/xray/config.json
    systemctl restart xray
    echo -e "${GREEN}Account \$Login renewed until \$exp_new${NC}"
else
    echo -e "${RED}User \$Login does not exist${NC}"
fi
EOF

cat > /usr/local/bin/renew-trojan <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   RENEW TROJAN ACCOUNT     ${NC}"
echo -e "${BLUE}=============================${NC}"

read -p "Username : " Login
read -p "Days to add : " masaaktif

if grep -q "### \$Login" "/etc/xray/config.json"; then
    exp_old=\$(grep -wA 1 "### \$Login" "/etc/xray/config.json" | tail -1 | awk -F' ' '{print \$2}')
    exp_new=\$(date -d "\$exp_old + \$masaaktif days" +"%Y-%m-%d")
    sed -i "s/### \$Login \$exp_old/### \$Login \$exp_new/g" /etc/xray/config.json
    systemctl restart xray
    echo -e "${GREEN}Account \$Login renewed until \$exp_new${NC}"
else
    echo -e "${RED}User \$Login does not exist${NC}"
fi
EOF

# Usage Monitoring Scripts
cat > /usr/local/bin/usage <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    BANDWIDTH USAGE         ${NC}"
echo -e "${BLUE}=============================${NC}"

vnstat -m | grep -v "+" | grep -v "rx"
echo ""
echo -e "Daily Usage:"
vnstat -d | grep -v "+" | grep -v "rx"
echo -e "${BLUE}=============================${NC}"
EOF

# Auto-Kill Multi Login
cat > /usr/local/bin/autokill <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}   AUTO KILL MULTI LOGIN    ${NC}"
echo -e "${BLUE}=============================${NC}"
echo -e "1) Set Auto Kill"
echo -e "2) Set Maximum Login"
echo -e "3) Disable Auto Kill"
echo -e "0) Exit"
read -p "Select option : " option

case \$option in
    1)
        echo "*/1 * * * * root /usr/local/bin/kill-multi" > /etc/cron.d/kill-multi
        echo -e "${GREEN}Auto Kill enabled${NC}"
        ;;
    2)
        read -p "Maximum login allowed: " max
        echo \$max > /etc/xray/limit
        echo -e "${GREEN}Maximum login set to \$max${NC}"
        ;;
    3)
        rm -f /etc/cron.d/kill-multi
        echo -e "${GREEN}Auto Kill disabled${NC}"
        ;;
    0)
        menu
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        ;;
esac
EOF

# Kill Multi Login Script
cat > /usr/local/bin/kill-multi <<EOF
#!/bin/bash
MAX=\$(cat /etc/xray/limit)

if [ -z "\$MAX" ]; then
    echo "No limit set"
    exit 0
fi

# Check SSH
data=( \`ps aux | grep -i ssh | grep -i priv | awk '{print \$2}'\` );
for PID in "\${data[@]}"
do
    NUM=\`cat /var/log/auth.log | grep -i ssh | grep -i "Accepted password" | grep "sshd[\$PID]" | wc -l\`
    USER=\`cat /var/log/auth.log | grep -i ssh | grep -i "Accepted password" | grep "sshd[\$PID]" | tail -n1 | awk '{print \$9}'\`
    if [ \$NUM -gt \$MAX ]; then
        kill \$PID
        echo "\$USER Multi Login Killed"
    fi
done

# Check XRAY
for TYPE in vmess vless trojan; do
    cat /var/log/xray/access.log | grep -i \$TYPE | awk '{print \$3}' | sort | uniq -c | while read COUNT USER; do
        if [ \$COUNT -gt \$MAX ]; then
            sed -i "/\$USER/d" /etc/xray/config.json
            systemctl restart xray
            echo "\$USER Multi Login Killed"
        fi
    done
done
EOF

# Account Expiry Notification
cat > /usr/local/bin/notify-expired <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}  ACCOUNT EXPIRY CHECKER    ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "Checking SSH accounts..."
for user in \$(awk -F: '\$3 >= 1000 && \$1 != "nobody" {print \$1}' /etc/passwd); do
    exp=\$(chage -l \$user | grep "Account expires" | awk -F": " '{print \$2}')
    if [[ ! \$exp == "never" ]]; then
        exp_date=\$(date -d "\$exp" +%s)
        today=\$(date +%s)
        diff=\$(( (\$exp_date - \$today) / 86400 ))
        if [[ \$diff -le 7 && \$diff -gt 0 ]]; then
            echo -e "\$user will expire in \$diff days"
        elif [[ \$diff -le 0 ]]; then
            echo -e "\$user has expired"
            userdel -f \$user
        fi
    fi
done

echo -e "\nChecking XRAY accounts..."
for TYPE in vmess vless trojan; do
    cat /etc/xray/config.json | grep -A 1 "###" | grep -v "###" | while read user; do
        exp=\$(echo \$user | awk '{print \$2}')
        exp_date=\$(date -d "\$exp" +%s)
        today=\$(date +%s)
        diff=\$(( (\$exp_date - \$today) / 86400 ))
        if [[ \$diff -le 7 && \$diff -gt 0 ]]; then
            user=\$(echo \$user | awk '{print \$1}')
            echo -e "\$TYPE user \$user will expire in \$diff days"
        fi
    done
done
EOF

# Traffic Monitor
cat > /usr/local/bin/traffic <<EOF
#!/bin/bash
clear
echo -e "${BLUE}=============================${NC}"
echo -e "${YELLOW}    TRAFFIC MONITOR         ${NC}"
echo -e "${BLUE}=============================${NC}"

echo -e "Current Traffic:"
nethogs -v 1 -c 1
echo -e "${BLUE}=============================${NC}"
EOF

# Set permissions for all new scripts
chmod +x /usr/local/bin/renew-vless
chmod +x /usr/local/bin/renew-trojan
chmod +x /usr/local/bin/usage
chmod +x /usr/local/bin/autokill
chmod +x /usr/local/bin/kill-multi
chmod +x /usr/local/bin/notify-expired
chmod +x /usr/local/bin/traffic

# Add to crontab
echo "0 0 * * * root /usr/local/bin/notify-expired" > /etc/cron.d/notify-expired
echo "0 */6 * * * root /usr/local/bin/usage" > /etc/cron.d/usage
echo "*/5 * * * * root /usr/local/bin/traffic" > /etc/cron.d/traffic

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