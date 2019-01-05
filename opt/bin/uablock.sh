#!/bin/sh

echo Download Lists 
wget -O /opt/etc/rublock.dnsmasq https://raw.githubusercontent.com/blackcofee/uablock-list/master/urlblock
wget -O /opt/etc/rublock.ips https://raw.githubusercontent.com/blackcofee/uablock-list/master/ipblock

echo Generation Block List
cd /opt/etc/
sed -i 's/.*/ipset=\/&\/rublock/' rublock.dnsmasq

echo Restart dnsmasq
restart_dhcpd
restart_firewall
