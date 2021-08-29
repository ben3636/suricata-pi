#!/bin/bash

# Threshold.conf syntax:
  #|| # Suppression Description
  #|| suppress gen_id 1, sig_id 2017926, track by_{src/dst}, ip 192.168.3.2


function load(){
  for i in range {1..5}
  do
    echo "."
    echo
    sleep .5
  done
}

if [[ $(whoami) != "root" ]]
then
  echo "Error: This script must be run as root!"
  exit 1
fi
clear
cd /root

echo "Running pre-flight checks..."
sleep 5
load
echo "Please set a static IP address for this machine if you have not done so already..."
sleep 5
load
echo "This includes setting a static Gateway and DNS Server..."
sleep 5
load
echo -n "Please confirm this has already been done by typing 'yes' and hitting enter: "
read confirm </dev/tty
while [[ $confirm == "" ]] || [[ $confirm != "yes" ]]
do
  echo
  echo -n "Please confirm this has already been done by typing 'yes' and hitting enter: "
  read confirm </dev/tty
done

# Update
clear
echo "Updating..."
load
apt update && apt upgrade -y

# Show Interfaces
clear
echo "Please note the interfaces on the system and take note of which one will be used for DNS/DHCP/Suricata..."
sleep 15
load
/usr/sbin/ifconfig
sleep 15
load

# Install Suricata
clear
echo "Installing Suricata..."
sleep 5
load
add-apt-repository ppa:oisf/suricata-stable
apt update
apt-get install suricata -y
clear
echo "Please change the following..."
sleep 5
load
echo "1. Change \$HOME_NET"
echo "2. Change 'af_packet' Interface"
echo "3. Add '/var/lib/suricata/rules/*.rules' to ruleset"
echo "4. Uncomment threshold file"
sleep 20
nano /etc/suricata/suricata.yaml # Edit Home Net & Interface // Add /var/lib/suricata/*.rules
apt install net-tools -y
clear
echo "Please set/verify the interface for Suricata in the service file..."
sleep 10
load
nano /root/suricata-pi/suricata

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

# Setup Push Notifications for Suricata & Disk Space
mv /root/suricata-pi/ifttt /root
chmod +x /root/ifttt/suri-push.bash

chmod +x /root/suricata-pi/reset-suri-sent
mv /root/suricata-pi/reset-suri-sent /etc/cron.daily

chmod +x /root/ifttt/disk-space
mv /root/ifttt/disk-space /etc/cron.hourly
clear
echo "Copy the text below and paste it into the crontab file when it opens and then save/exit..."
sleep 5
echo
echo "*/5 * * * * /root/ifttt/suri-push.bash"
sleep 15
crontab -e

# Install Service File
mv /root/suricata-pi/suricata /etc/default/ 
service suricata start
service suricata enable

# Install Suricata Auto Updater
chmod +x /root/suricata-pi/suricata-auto-update
mv /root/suricata-pi/suricata-auto-update /etc/cron.daily

# Enable IP Forwarding
clear
echo "Configuring Interfaces..."
sleep 5
load
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Enable Promisc Mode
interface=$(/usr/sbin/ifconfig | grep ":" | awk ' { print $1 } ' | grep ":" | grep -v "lo:" | sed s/":"//g)
ifconfig $interface promisc

# Install // Enable DNS Server
clear
echo "Installing DNS Server..."
sleep 5
load
apt-get install bind9 -y
nano /etc/bind/named.conf.options # Add Forwarder
service bind9 restart
service bind9 enable

# Install // Enable DHCP Server If Elected
clear
echo "Please determine if you need to install the DHCP server on the Pi..."
sleep 5
load
echo "If you can modify the parameters on the current router (set the Gateway/DNS values to the static IP of this Pi), do that and skip the DHCP install..."
sleep 15
load
echo "Some home routers will not allow you to do this. If this is the case, you will need to disable the current DHCP server on the router and install one here..."
sleep 15
load
echo -n "Do you need to install a new DHCP server now? (yes/no): "
read install </dev/tty
while [[ $install == "" ]] && [[ $install != "yes" ]] && [[ $install != "no" ]]
do
  echo
  echo -n "Do you need to install a new DHCP server now? (yes/no): "
  read install </dev/tty
done
if [[ $install == "yes" ]]
then
  clear
  echo "!!!---WARNING: YOU MUST DISABLE YOUR CURRENT DHCP SERVER ON THE NETWORK BEFORE CONTINUING!---!!!"
  load
  echo "Failing to do so will likely create a denial of service scenario and wreak absolute fucking havoc on your network..."
  sleep 15
  load
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
  sleep 5
  load
  apt install isc-dhcp-server -y
  clear
  echo "DHCP Server has Gateway/DNS set to '192.168.1.254'..."
  load
  echo "Please set this as your static IP or change those values in '/etc/dhcp/dhcpd.conf'..."
  sleep 10
  load
  echo "Please check the parameters in the DHCP server config and make any needed adjustments..."
  sleep 10
  load
  nano /root/suricata-pi/dhcpd.conf
  cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.bak
  mv /root/suricata-pi/dhcpd.conf /etc/dhcp/
  clear
  echo "Please specify the IPv4 Interface for DHCP to Listen on..."
  sleep 10
  nano /etc/default/isc-dhcp-server
  service isc-dhcp-server start
  service isc-dhcp-server enable
elif [[ $install == "no" ]]
then
  load
  echo "Skipping DHCP Server Installation..."
  sleep 5
  clear
fi

# Verify IFTTT Webhook
clear
echo "Please update the push notification scripts with your custom IFTTT Webhook address..."
sleep 15
load
echo "Modify only the IFTTT URL instances, making additional changes may break the script..."
sleep 10
load
nano /root/ifttt/suri-push.bash
nano /etc/cron.hourly/disk-space

# Install Evebox
clear
echo "Installing Evebox..."
sleep 5
load
apt install unzip -y
wget https://evebox.org/files/release/latest/evebox-0.14.0-linux-arm64.zip
unzip evebox-0.14.0-linux-arm64.zip 
mv /root/evebox-0.14.0-linux-arm64/evebox /root
mv /root/suricata-pi/evebox.yaml /root

# Enable Evebox Authentication & TLS
clear
echo "Now to enable TLS & Authentication for Evebox..."
load
sleep 5
echo

echo -n "Enter a username: "
read username </dev/tty
while [[ $username == "" ]]
do
  echo
  echo -n "Enter a username: "
  read username </dev/tty
done
load
evebox config -D /root users add --username $username
clear
echo "Setting up TLS..."
sleep 5
load
echo "Please enter a temporary password for the private key - We will remove it in the next step..."
sleep 15
load
openssl genrsa -aes128 -out eve.pem 2048
openssl rsa -in eve.pem -out eve.pem
load
clear
echo "For the cert details, you can enter as much or as little information as you wish..."
sleep 15
load
openssl req -new -days 365 -key eve.pem -out eve.csr
openssl x509 -in eve.csr -out eve-cert.pem -req -signkey eve.pem -days 365

# Install Autostart Script in Hourly Cron
chmod +x /root/suricata-pi/pids-auto-start
mv /root/suricata-pi/pids-auto-start /etc/cron.hourly

# Finish and Start Web Interface
clear
echo "Install Completed!"
load
echo "Starting Evebox...Web Interface Will Be Available on Port 5636"
sleep 10
date=$(date)
echo "Install Completed......$date" >> /root/Pi-IDS.log
/etc/cron.hourly/pids-auto-start

