####################################################################################
# On optiplex-two – install & configure SNMP for LibreNMS on Ubuntu 24.04 LTS Server
####################################################################################

# 1) Install packages
sudo apt update
sudo apt install -y snmp snmpd

# 2) Backup default config
sudo cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak.$(date +%s)

# 3) Minimal LibreNMS-friendly config
sudo tee /etc/snmp/snmpd.conf >/dev/null << 'EOF'
agentAddress udp:161
rocommunity homelab 192.168.200.14

sysLocation Homelab
sysContact Thomas <[email protected]>
sysName optiplex-two
EOF

# 4) (Optional) UFW firewall rule
sudo ufw allow 161/udp 2>/dev/null || true

# 5) Restart SNMP daemon
sudo systemctl restart snmpd
sudo systemctl status snmpd
###############################################################################
# On optiplex-docker – verify SNMP from LibreNMS server
###############################################################################
OPT2_IP="192.168.200.14"      # replace with target server IP
COMMUNITY="homelab"           # any name you want

ping -c 3 "$OPT2_IP"

snmpwalk -v2c -c "$COMMUNITY" "$OPT2_IP" 1.3.6.1.2.1.1
snmpwalk -v2c -c "$COMMUNITY" "$OPT2_IP" 1.3.6.1.2.1.25.2.3
snmpwalk -v2c -c "$COMMUNITY" "$OPT2_IP" 1.3.6.1.4.1.2021.4
snmpwalk -v2c -c "$COMMUNITY" "$OPT2_IP" 1.3.6.1.2.1.2.2
###############################################################################
# Then, in LibreNMS UI:
# Devices → Add Device
#   Hostname:   use static server IP
#   SNMP v2c, Community: homelab, Port: 161
###############################################################################
