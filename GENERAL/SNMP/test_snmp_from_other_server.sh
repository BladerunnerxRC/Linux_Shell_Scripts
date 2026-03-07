OPT2_IP="192.168.200.14"
COMMUNITY="homelab"

# Make sure host is up
ping -c 3 "$OPT2_IP"

# Basic SNMP system info
snmpwalk -v2c -c "$COMMUNITY" "$OPT2_IP" 1.3.6.1.2.1.1
