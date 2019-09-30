#!/bin/sh

echo List generation
/opt/bin/blupdate.lua

echo Add more resources
# Sites
wget -O /tmp/urlblock https://raw.githubusercontent.com/blackcofee/rublock-list/master/urlblock
sed -i 's/.*/ipset=\/&\/rublock/' /tmp/urlblock
cat /tmp/urlblock >> /opt/etc/rublock/rublock.dnsmasq

# IP
wget -O /tmp/ipblock https://raw.githubusercontent.com/blackcofee/rublock-list/master/ipblock
cat /tmp/ipblock >> /opt/etc/rublock/rublock.ips

echo Clear the list
cd /opt/etc/rublock
sed -i '/pornhub.com/d' rublock.dnsmasq
sed -i '/youtube.com/d; /googleusercontent.com/d' rublock.dnsmasq
sed -i '/lkan/d; /lcan/d; /1x/d' rublock.dnsmasq
sed -i '/asino/d; /azino/d' rublock.dnsmasq
sed -i '/bet/d; /city/d; /leon/d' rublock.dnsmasq
sed -i '/stav/d; /slot/d; /dosug/d' rublock.dnsmasq

### Add custom sites
# cd /opt/etc/rublock/rublock.dnsmasq
# sed -i '$aipset=\/example.com\/rublock' rublock.dnsmasq

### Add custom ip
# cd /opt/etc/rublock/rublock.dnsmasq
# sed -i '$a127.0.0.1' rublock.ips
# sed -i '$a127.0.0.1\/22' rublock.ips

echo Add ip to table
ipset flush rublock

for IP in $(cat /opt/etc/rublock/rublock.ips) ; do
ipset -A rublock $IP
done

echo Restart dnsmasq
killall -q dnsmasq
/usr/sbin/dnsmasq
