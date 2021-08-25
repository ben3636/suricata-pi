# Update
apt update && apt upgrade -y

# Install Suricata
add-apt-repository ppa:oisf/suricata-stable
apt update
apt-get install suricata -y
nano /etc/suricata/suricata.yaml # Edit Home Net & Interface // Add /var/lib/suricata/*.rules

# Unpack Rules
mkdir /root/suricata-pi/snort-rules
tar -xvf /root/suricata-pi/snortrules-snapshot-2983.tar.gz -C /root/suricata-pi/snort-rules/
tar -xvf /root/suricata-pi/community-rules.tar.gz
mv suricata-pi/community-rules/community.rules /var/lib/suricata/rules/
mv suricata-pi/snort-rules/rules/*.rules /var/lib/suricata/rules/

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
wget https://github.com/ben3636/suricata-pi/blob/main/suricata
mv /root/suricata-pi/suricata /etc/default/suricata 
service suricata start


# Install & Run Evebox
apt install unzip -y
wget https://evebox.org/files/release/latest/evebox-0.14.0-linux-arm64.zip
unzip evebox-0.14.0-linux-arm64.zip 
cd evebox-0.14.0-linux-arm64/ && ./evebox server -v -D . --datastore sqlite --input /var/log/suricata/eve.json --host 0.0.0.0
