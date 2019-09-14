#!/bin/sh

echo Check update
opkg update && opkg upgrade

echo Install packages
opkg install lua

echo Make directories
mkdir -p /opt/lib/lua /opt/etc/rublock

echo Download scripts
wget -O /opt/lib/lua/ltn12.lua https://raw.githubusercontent.com/diegonehab/luasocket/master/src/ltn12.lua
wget -O /opt/bin/blupdate.lua https://raw.githubusercontent.com/blackcofee/rublock-vpn/master/opt/bin/blupdate.lua
wget -O /opt/bin/rublock.sh https://raw.githubusercontent.com/blackcofee/rublock-vpn/master/opt/bin/rublock.sh

echo Load ipset modules
modprobe ip_set_hash_net
modprobe xt_set
ipset -N rublock nethash

echo Execute scripts
chmod +x /opt/bin/blupdate.lua /opt/bin/rublock.sh
rublock.sh

echo Make config iptables
cat /dev/null > /opt/bin/update_iptables.sh

cat >> /opt/bin/update_iptables.sh << 'EOF'
#!/bin/sh

case "$1" in
start|update)
        # add iptables custom rules
        echo "firewall started"
        [ -d '/opt/etc/rublock' ] || exit 0
        # Create new rublock ipset and fill it with IPs from list
        if [ ! -z "$(ipset --swap rublock rublock 2>&1 | grep 'given name does not exist')" ] ; then
                ipset -N rublock nethash
                for IP in $(cat /opt/etc/rublock/rublock.ips) ; do
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

echo Add ipset modules
cat >> /etc/storage/start_script.sh << 'EOF'

### Load ipset modules
modprobe ip_set_hash_net
modprobe xt_set
EOF

echo Add options client
cat >> /etc/storage/openvpn/client/client.conf << 'EOF'

### User options
auth-nocache
route-noexec
EOF

echo Make vpnc script
cat /dev/null > /etc/storage/vpnc_server_script.sh

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

echo Add entries to dnsmasq
cat >> /etc/storage/dnsmasq/dnsmasq.conf << 'EOF'

### rublock
conf-file=/opt/etc/rublock/rublock.dnsmasq
EOF

echo Add crontab tasks
cat >> /etc/storage/cron/crontabs/$USER << 'EOF'
0 5 * * * /opt/bin/rublock.sh
EOF

echo Reboot
reboot