# Suricata Pi

Suricata Pi is an automated installer that installs and configures Suricata on Raspberry Pi. Additionally, DNS & DHCP servers are installed to allow the Pi to route all LAN traffic through the IDS before being forwarded to the actual Gateway.

This allows for a "plug and play" / "inline" IDS without the need for additional wiring or MITM techniques. While this setup lacks a rules management interface and a fancy mobile app, this is an entirely viable solution for an open-sourced IDS with push notifications.

Going forward, I would like to implement additional scripts to use the DHCP information to alert users of new devices on the network, etc. Despite using free and open-source software, this setup provides set-it-and-forget-it Intrusion Detection and security alerts for the average home user (something most consumer-grade routers lack).

This script has been tested on **Ubuntu 20.04.3 LTS on Raspberry Pi 4**

Please note that this is a proof-of-concept project and may impact network performance. It is also **ABSOLUTELY NECESSARY** that you disable your current DHCP server on the network prior to activating the script. Having multiple DHCP servers fight for control over the network will almost certainly cripple your network.

This script installs and configures the following components:

1. Suricata in IDS Mode
2. Evebox for the web interface for alerts management 
3. DHCP server to give out addresses and tell hosts to send DNS/Gateway traffic to the Pi
4. DNS server to resolve, cache, & forward DNS queries
5. Push notification scripts using IFTTT webhooks (Suricata Alerts & Disk Space Warnings)
7. Autostart capability on reboot

> ***Note: The script MUST be run as root in its current form***
