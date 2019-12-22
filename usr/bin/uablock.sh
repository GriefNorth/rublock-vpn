
#!/bin/sh

echo Download Lists 
wget -q -O /etc/rublock/rublock.dnsmasq https://raw.githubusercontent.com/blackcofee/uablock-list/master/urlblock
wget -q -O /etc/rublock/rublock.ips https://raw.githubusercontent.com/blackcofee/uablock-list/master/ipblock

echo Generation Block List
cd /etc/rublock
sed -i 's/.*/ipset=\/&\/rublock/' rublock.dnsmasq

echo Add ip
ipset flush rublock

for IP in $(cat /etc/rublock/rublock.ips) ; do
ipset -A rublock $IP
done

echo Restart dnsmasq
killall -q dnsmasq
/usr/sbin/dnsmasq
