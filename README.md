# Suricata Pi Overview

Suricata Pi is an automated installer that installs and configures Suricata on Raspberry Pi. Additionally, DNS & DHCP servers are installed to allow the Pi to route all LAN traffic through the IDS before being forwarded to the actual Gateway.

This allows for a "plug and play" / "inline" IDS without the need for additional wiring or MITM techniques. While this setup lacks a rule management interface and a fancy mobile app, this is an entirely viable solution for an open-sourced IDS with push notifications.

Going forward, I would like to implement additional scripts to use the DHCP information to alert users of new devices on the network, etc. Being "inline", Suricata could also be configured in prevention mode if desired (make sure you tune the rules first). Despite using free and open-source software, this setup provides set-it-and-forget-it Intrusion Detection and security alerts for the average home user (something most consumer-grade routers lack).

This script has been tested on **Ubuntu 20.04.3 LTS on Raspberry Pi 4**

Please note that this is a proof-of-concept project and may impact network performance. When tested on a Raspberry Pi 4 (4GB RAM) using the Gigabit Ethernet port, the network speeds remained well over 200mb/s but this may vary. It is also **ABSOLUTELY NECESSARY** that you disable your current DHCP server on the network prior to running the install. Having multiple DHCP servers fight for control over the network will almost certainly cripple it.

This script installs and configures the following components:

1. Suricata in IDS Mode
2. Evebox for viewing the alerts in a web interface
3. DHCP server to give out addresses and tell hosts to send DNS/Gateway traffic to the Pi
4. DNS server to resolve, cache, & forward DNS queries
5. Push notification scripts using IFTTT webhooks (Suricata Alerts & Disk Space Warnings)
7. Autostart capability on reboot
8. UFW firewall to secure network access to the Pi

> ***Note: The script MUST be run as root in its current form***

# Thoughts for The Future

My homelab has consisted primarily of a Dell Poweredge server running ESXI for the past year. I run a PFsense firewall, a Suricata IDS, and an Elastic Stack as a SIEM/log visualization hub. The Suricata Pi idea came well after I finished my server as a way to provide the same benefits to people who either cannot:

a) Afford a $300+ server

b) Fit one in their living space

c) Carry one back and forth to college (yeah, that's a true story, don't recommend.)

After finishing the install of Suricata Pi on my Raspberry Pi 4 (4GB RAM), I noticed Evebox and Suricata were only using about a gig of RAM and very little CPU. I decided to try and run the full Elastic Stack install to bring the Suricata logs into a much cleaner, feature-rich web-interface with Kibana. Filebeat would handle the log ingestion to Elasticsearch and Kibana would serve up the shiny graphs, etc. 

To my absolute disbelief, the Pi did it. Not only ran the stack, but did it without bursting into flames as I had suspected it would. It did max out the 4GB of RAM which is understandable with everything running at once (Suricata, Evebox, Elasticsearch, Filebeat, Kibana, DHCP, DNS, etc).

While I wouldn't personally run this full setup on the Pi unless I had the 8GB RAM version, it easily surpasses the proof-of-concept target and could be used in a home network to provide the full IDS and SIEM experience.

I'd love to say this project was motivated by a selfless urge to bring cybersec resources to the masses. That would be really cool but I'm not gonna lie, I just wanted to prove someone wrong who doubted I could do it. So reach for the stars, and maybe have a fire extinguisher handy just in case your Pi does actually burst into flames :)

> Note: If you want to try the Elastic Stack Install, Check Out My Installer: https://github.com/ben3636/elk-installer

