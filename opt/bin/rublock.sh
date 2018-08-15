#!/bin/sh

echo List Generation
/opt/bin/blupdate.lua

echo Clear List
cd /opt/etc
sed -i '/pornhub.com/d' rublock.dnsmasq
sed -i '/youtube.com/d' rublock.dnsmasq
sed -i '/googleusercontent.com/d' rublock.dnsmasq
sed -i '$aipset=\/nnm-club.ws\/rublock' rublock.dnsmasq
sed -i '$aipset=\/gnome-look.org\/rublock' rublock.dnsmasq
sed -i '$aipset=\/opendesktop.org\/rublock' rublock.dnsmasq
sed -i '$aipset=\/pling.com\/rublock' rublock.dnsmasq
sed -i '$a52.77.181.198' rublock.ips
sed -i '$a54.229.110.205' rublock.ips
sed -i '$a18.205.93.0\/25' rublock.ips

echo Restart dnsmasq
killall -sighup dnsmasq