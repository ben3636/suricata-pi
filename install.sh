#!/bin/bash

###---TO DO // Notes---###
# Load fn
# Disk space push notif // response action
# Push notifications via IFTTT

# Threshold.conf syntax:
  #|| # Suppression Description
  #|| suppress gen_id 1, sig_id 2017926, track by_{src/dst}, ip 192.168.3.2

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
echo "Please change the following..."
echo
echo "1. Change $HOME_NET"
echo "2. Change 'af_packet' Interface"
echo "3. Add '/var/lib/suricata/rules/*.rules' to ruleset"
echo "4. Uncomment threshold file"
sleep 10
nano /etc/suricata/suricata.yaml # Edit Home Net & Interface // Add /var/lib/suricata/*.rules

# Unpack Additional Rules
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

# Setup Push Notifications for Suricata
mv /root/suricata-pi/ifttt /root
chmod +x /root/ifttt/suri-push.bash
clear
echo "Copy the text below and paste it into the crontab file when it opens and then save/exit..."
sleep 5
echo
echo "*/5 * * * * /root/ifttt/suri-push.bash"
sleep 15
crontab -e

# Install Service File
mv /root/suricata-pi/suricata /etc/default/suricata 
service suricata start
service suricata enable

# Install Suricata Auto Updater
chmod +x /root/suricata-pi/suricata-auto-update
mv /root/suricata-pi/suricata-auto-update /etc/cron.daily

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
service bind9 enable


# Install // Enable DHCP Server
clear
echo "!!!---WARNING: YOU MUST DISABLE YOUR CURRENT DHCP SERVER ON THE NETWORK BEFORE CONTINUING!---!!!"
echo
echo "Failing to do so will likely create a denial of service scenario and wreak absolute fucking havoc on your network"
sleep 15
echo
echo -n "Type 'yes' once this is complete and press enter: "
read choice </dev/tty
while [[ $choice == "" ]] || [[ $choice != "yes" ]]
do
  echo
  echo -n "Type 'yes' once this is complete and press enter: "
  read choice </dev/tty
done
clear
echo "Installing DHCP Server..."
echo
sleep 10
apt install isc-dhcp-server -y
clear
echo "DHCP Server has Gateway/DNS set to '192.168.1.254'"
echo
echo "Please set this as your static IP or change those values in '/etc/dhcp/dhcpd.conf'
sleep 10
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.bak
mv /root/suricata-pi/dhcpd.conf /etc/dhcp/
clear
echo "Please specify the IPv4 Interface for DHCP to Listen on..."
sleep 10
nano /etc/default/isc-dhcp-server
service isc-dhcp-server start
service isc-dhcp-server enable


# Install Evebox
clear
echo "Installing Evebox..."
echo
sleep 5
apt install unzip -y
wget https://evebox.org/files/release/latest/evebox-0.14.0-linux-arm64.zip
unzip evebox-0.14.0-linux-arm64.zip 
mv /root/suricata-pi/evebox-0.14.0-linux-arm64/evebox /root
mv /root/suricata-pi/evebox.yaml /root


# Enable Evebox Authentication & TLS
clear
echo "Now to enable TLS & Authentication for Evebox..."
echo
echo
sleep 10
echo

echo -n "Enter a username: "
read username </dev/tty
while [[ $username == "" ]]
do
  echo
  echo -n "Enter a username: "
  read username </dev/tty
done
echo
echo
echo
evebox config -D /root users add --username $username
echo
echo
echo
echo "Now to set up TLS..."
echo
sleep 5
echo "Please enter a temporary password for the private key (we'll remove it in the next step)
sleep 15
clear
openssl genrsa -aes128 -out eve.pem 2048
openssl rsa -in eve.pem -out eve.pem
echo
echo
echo
echo "For the cert details, you can enter as much or as little information as you want"
sleep 15
openssl req -new -days 365 -key eve.pem -out eve.csr
openssl x509 -in eve.csr -out eve-cert.pem -req -signkey eve.pem -days 365


# Install Autostart Script in Hourly Cron
chmod +x /root/suricata-pi/pids-auto-start
mv /root/suricata-pi/pids-auto-start /etc/cron.hourly


# Finish and Start Web Interface
clear
echo "Install Completed!"
echo
echo "Starting Evebox...Web Interface Will Be Available on Port 5636"
sleep 10
date=$(date)
echo "Install Completed......$date" >> /root/Pi-IDS.log
/etc/cron.hourly/pids-auto-start

