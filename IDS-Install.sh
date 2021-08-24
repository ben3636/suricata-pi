# Update
apt update && apt upgrade -y

# Install Suricata
add-apt-repository ppa:oisf/suricata-stable
apt update
apt-get install suricata -y

# Update Suricata // Enable Sources
suricata-update
suricata-update update-sources
suricata-update enable-source et/open 
suricata-update enable-source oisf/trafficid 
suricata-update enable-source ptresearch/attackdetection 
suricata-update enable-source sslbl/ssl-fp-blacklist 
suricata-update enable-source sslbl/ja3-fingerprints 
suricata-update enable-source etnetera/aggressive 
suricata-update enable-source tgreen/hunting
suricata-update

# Enable IP Forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p


# Enable Promisc Mode
apt install net-tools -y
ifconfig wlan0 promisc


# Install // Enable DNS Server
apt-get install bind9 -y
nano /etc/bind/named.conf.options # Add Forwarder
service bind9 restart


# unzip and drop in comm rules and snapshot (snort)
nano /etc/default/suricata # Add Below
service suricata start


# Install & Run Evebox
apt install unzip -y
wget https://evebox.org/files/release/latest/evebox-0.14.0-linux-arm64.zip
unzip evebox-0.14.0-linux-arm64.zip 
cd evebox-0.14.0-linux-arm64/ && ./evebox server -v -D . --datastore sqlite --input /var/log/suricata/eve.json --host 0.0.0.0








# Default config for Suricata

# set to yes to start the server in the init.d script
RUN=yes

# set to user that will run suricata in the init.d script (used for dropping privileges only)
RUN_AS_USER=

# Configuration file to load
SURCONF=/etc/suricata/suricata.yaml

# Listen mode: pcap, nfqueue, custom_nfqueue or af-packet
# depending on this value, only one of the two following options
# will be used (af-packet uses neither).
# Please note that IPS mode is only available when using nfqueue
LISTENMODE=af-packet

# Interface to listen on (for pcap mode)
IFACE=wlan0

# Queue number to listen on (for nfqueue mode)
NFQUEUE="-q 0"

# Queue numbers to listen on (for custom_nfqueue mode)
# Multiple queues can be specified
CUSTOM_NFQUEUE="-q 0 -q 1 -q 2 -q 3"

# Pid file
PIDFILE=/var/run/suricata.pid