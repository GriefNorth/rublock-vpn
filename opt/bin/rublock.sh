#!/bin/sh

echo List generation
/opt/bin/blupdate.lua

echo Clear the list
cd /opt/etc
sed -i '/pornhub.com/d' rublock.dnsmasq
sed -i '/youtube.com/d; /googleusercontent.com/d' rublock.dnsmasq
sed -i '/vulkan/d; /wulkan/d; /vulcan/d' rublock.dnsmasq
sed -i '/casino/d; /kasino/d; /azino/d' rublock.dnsmasq
sed -i '/1xbet/d; /betcity/d; /leon/d; /fonbet/d' rublock.dnsmasq
sed -i '/stavka/d; /slot/d; /dosug/d' rublock.dnsmasq

echo Add custom sites
sed -i '$aipset=\/nnm-club.ws\/rublock' rublock.dnsmasq
sed -i '$aipset=\/gnome-look.org\/rublock' rublock.dnsmasq
sed -i '$aipset=\/opendesktop.org\/rublock' rublock.dnsmasq
sed -i '$aipset=\/pling.com\/rublock' rublock.dnsmasq
sed -i '$aipset=\/7-zip.org\/rublock' rublock.dnsmasq
sed -i '$aipset=\/reactos.org\/rublock' rublock.dnsmasq
sed -i '$aipset=\/nextcloud.com\/rublock' rublock.dnsmasq
sed -i '$aipset=\/git.openwrt.org\/rublock' rublock.dnsmasq

echo Add custom ip
sed -i '$a91.108.4.0\/22' rublock.ips
sed -i '$a91.108.8.0\/22' rublock.ips
sed -i '$a91.108.12.0\/22' rublock.ips
sed -i '$a91.108.16.0\/22' rublock.ips
sed -i '$a91.108.56.0\/22' rublock.ips
sed -i '$a149.154.160.0\/22' rublock.ips
sed -i '$a149.154.164.0\/22' rublock.ips
sed -i '$a149.154.168.0\/22' rublock.ips
sed -i '$a149.154.172.0\/22' rublock.ips

echo Add ip to table
ipset flush rublock

for IP in $(cat /opt/etc/rublock.ips) ; do
ipset -A rublock $IP
done

echo Restart dnsmasq
killall -q dnsmasq
/usr/sbin/dnsmasq
