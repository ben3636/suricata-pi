#!/bin/bash

# Update
clear
echo "Updating..."
echo
sleep 5
apt update && apt upgrade -y

# Install Suricata
clear
echo "Installing Suricata..."
echo
sleep 5
add-apt-repository ppa:oisf/suricata-stable
apt update
apt-get install suricata -y
clear
echo "Please change $HOME_NET and the 'af_packet' Interface"
sleep 10
nano /etc/suricata/suricata.yaml # Edit Home Net & Interface // Add /var/lib/suricata/*.rules

# Unpack Rules
mkdir /root/suricata-pi/snort-rules
tar -xvf /root/suricata-pi/snortrules-snapshot-2983.tar.gz -C /root/suricata-pi/snort-rules/
tar -xvf /root/suricata-pi/community-rules.tar.gz
mv /root/suricata-pi/community-rules/community.rules /var/lib/suricata/rules/
mv /root/suricata-pi/snort-rules/rules/*.rules /var/lib/suricata/rules/

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


# Install Additional Rules
mv /root/suricata-pi/suricata /etc/default/suricata 
service suricata start

# Enable IP Forwarding
clear
echo "Configuring Interfaces..."
echo
sleep 5
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p


# Enable Promisc Mode
apt install net-tools -y
ifconfig wlan0 promisc


# Install // Enable DNS Server
clear
echo "Installing DNS Server..."
echo
sleep 5
apt-get install bind9 -y
nano /etc/bind/named.conf.options # Add Forwarder
service bind9 restart


# Install & Run Evebox
clear
echo "Installing Evebox..."
echo
sleep 5
apt install unzip -y
wget https://evebox.org/files/release/latest/evebox-0.14.0-linux-arm64.zip
unzip evebox-0.14.0-linux-arm64.zip 
clear
echo "Install Completed!"
echo
echo "Starting Evebox...Web Interface Will Be Available on Port 5636"
sleep 10
cd evebox-0.14.0-linux-arm64/ && ./evebox server -v -D . --datastore sqlite --input /var/log/suricata/eve.json --host 0.0.0.0

