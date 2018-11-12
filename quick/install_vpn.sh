echo Check Update
opkg update && opkg upgrade

echo Install Packages
opkg install lua

echo Make Dir
mkdir /opt/lib/lua

echo Download Scripts
wget -O /opt/lib/lua/ltn12.lua https://raw.githubusercontent.com/diegonehab/luasocket/master/src/ltn12.lua
wget -O /opt/bin/blupdate.lua https://raw.githubusercontent.com/blackcofee/rublock-vpn/master/opt/bin/blupdate.lua
wget -O /opt/bin/rublock.sh https://raw.githubusercontent.com/blackcofee/rublock-vpn/master/opt/bin/rublock.sh

echo Block Site
chmod +x /opt/bin/blupdate.lua /opt/bin/rublock.sh
rublock.sh

echo Make S10iptables
rm -rf /opt/etc/init.d/S10iptables

cat >> /opt/etc/init.d/S10iptables << 'EOF'
#!/bin/sh

case "$1" in
start|update)
        # add iptables custom rules
        echo "firewall started"
        [ -d '/opt/etc' ] || exit 0
        # Create new rublock ipset and fill it with IPs from list
        if [ ! -z "$(ipset --swap rublock rublock 2>&1 | grep 'given name does not exist')" ] ; then
                ipset -N rublock iphash
                for IP in $(cat /opt/etc/rublock.ips) ; do
                        ipset -A rublock $IP
                done
        fi
        iptables -A PREROUTING -t mangle -m set --match-set rublock dst,src -j MARK --set-mark 1
        ;;
stop)
        # delete iptables custom rules
        echo "firewall stopped"
        ;;
*)
        echo "Usage: $0 {start|stop|update}"
        exit 1
        ;;
esac
EOF

echo Add IP Set Module
cd /etc/storage/
sed -i '$a' start_script.sh
sed -i '$a### Example - load ipset modules' start_script.sh
sed -i '$amodprobe ip_set_hash_ip' start_script.sh
sed -i '$amodprobe xt_set' start_script.sh

echo Add option client.conf
cd /etc/storage/openvpn/client/
sed -i '$a' client.conf
sed -i '$a### Nocache' client.conf
sed -i '$aauth-nocache' client.conf
sed -i '$a' client.conf
sed -i '$a### Noexec' client.conf
sed -i '$aroute-noexec' client.conf

Make vpnc_server_script.sh
rm -rf /etc/storage/vpnc_server_script.sh

cat >> /etc/storage/vpnc_server_script.sh << 'EOF'
#!/bin/sh

func_ipup()
{
    echo 0 > /proc/sys/net/ipv4/conf/$IFNAME/rp_filter
    ip route flush table 1
    ip rule del table 1
    ip rule add fwmark 1 table 1 priority 1000
    ip route add default via $route_vpn_gateway table 1
    return 0
}

func_ipdown()
{
   return 0
}

logger -t vpnc-script "$IFNAME $1"

case "$1" in
up)
  func_ipup
  ;;
down)
  func_ipdown
  ;;
esac
EOF

chmod +x /etc/storage/vpnc_server_script.sh

echo Add entry dnsmasq
cd /etc/storage/dnsmasq/
sed -i '$a' dnsmasq.conf
sed -i '$a### RuBlock' dnsmasq.conf
sed -i '$aconf-file=/opt/etc/rublock.dnsmasq' dnsmasq.conf

echo Add Crontab tasks
cat >> /etc/storage/cron/crontabs/admin << 'EOF'
0 5 * * * /opt/bin/rublock.sh
EOF

echo Reboot
reboot
