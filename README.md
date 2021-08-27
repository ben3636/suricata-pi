# Suricata Pi

Suricata Pi is an automated installer that installs and configures suricata on Raspberry Pi. Additionally, DNS & DHCP servers are also installed to allow the Pi to route all LAN traffic through the IDS before being forwarded onto the actual Gateway.

Please note that this is a proof-of-concept project and may impact network performance. It is also **ABSOLUTELY NECESSARY** that you disable your current DHCP server on the network prior to activating the script. Having multiple DHCP servers fight for control over the network will almost certainly cripple your network.

This script installs and configures the following components:

1. Suricata in IDS Mode
2. Evebox for the web interface for alerts management 
3. DHCP server to give out addresses and tell hosts to send DNS/Gateway traffic to the Pi
4. DNS server to resolve, cache, & forward DNS queries
5. Push notification scripts using IFTTT webhooks
6. Autostart capability for Evebox, Suricata, & DHCP/DNS Server
