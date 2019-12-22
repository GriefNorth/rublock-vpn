#!/bin/sh

echo List generation
/usr/bin/blupdate.lua

echo Add more resources
# Sites
wget -q -O /tmp/urlblock https://raw.githubusercontent.com/blackcofee/rublock-list/master/urlblock
sed -i 's/.*/ipset=\/&\/rublock/' /tmp/urlblock
cat /tmp/urlblock >> /etc/rublock/rublock.dnsmasq

# IP
wget -q -O /tmp/ipblock https://raw.githubusercontent.com/blackcofee/rublock-list/master/ipblock
cat /tmp/ipblock >> /etc/rublock/rublock.ips

echo Clear the list
wget  -q -O /tmp/clear.sh https://raw.githubusercontent.com/blackcofee/rublock-list/master/clear.sh
chmod +x /tmp/clear.sh
/tmp/clear.sh

### Enter to rublock
cd /etc/rublock

### Add custom sites
# sed -i '$aipset=\/example.com\/rublock' rublock.dnsmasq

### Add custom ip
# sed -i '$a127.0.0.1' rublock.ips
# sed -i '$a127.0.0.1\/22' rublock.ips

echo Add ip to table
ipset flush rublock

for IP in $(cat /etc/rublock/rublock.ips) ; do
ipset -A rublock $IP
done

echo Restart dnsmasq
killall -q dnsmasq
/usr/sbin/dnsmasq
