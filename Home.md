## Использование OpenVPN для обхода блокировок
Решение ниже позволяет использовать VPN-соедиенение исключтельно для списка блокируемых ресурсов. При обращении к любым другим ресурсам будет использоваться привычное провайдерское соединение.

### Требования
* Прошивка с ipset (любые сборки Padavan, кроме nano),
* [Развёрнутый](https://bitbucket.org/padavan/rt-n56u/wiki/RU/HowToConfigureEntware) репозиторий Entware,
* Работающее OpenVPN-соединение.

### Установка скриптов
* Установите необходимые пакеты:
```
opkg install luasocket
```
* Скачайте скрипт формирования конфига для dnsmasq, сделайте его исполняемым:
```
wget --no-check-certificate -O /opt/bin/blupdate.lua https://raw.githubusercontent.com/DontBeAPadavan/rublock-via-vpn/master/opt/bin/blupdate.lua
chmod +x /opt/bin/blupdate.lua
```
* Запустите скрипт на исполнение:
```
blupdate.lua
```
В результате работы скрипта будут сформированы файлы `/opt/etc/rublock.dnsmasq` и `/opt/etc/rublock.ips`, которые будут использованы далее. Повторно запускать скрипт имеет смысл только для обновления списка заблокированных ресурсов, например, раз в месяц.


### Настройка прошивки
* Отредактируйте `/opt/etc/init.d/S10iptables`:
```
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
```

* В веб-интерфейсе роутера на странице `Customization > Scripts` отредактируйте поле `Run After Router Started`, раскоментировав две строчки:
```
modprobe ip_set_hash_ip
modprobe xt_set
```
* На странице `VPN Client` в поле `OpenVPN Extended Configuration` допишите следующую команду:
```
route-noexec
```
Теперь не будут применяться правила роутинга, которые будут переданы с OpenVPN-сервера. Убедитесь, что пункт `Route All Traffic through the VPN interface?` переключен в `No`.
* На той же странице приведите скрипт `Run the Script After Connected/Disconnected to VPN Server` к следующему виду:
```
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
```

Перегрузите роутер для того, чтобы настройки вступили в силу.

### Примечание

Решение отнюдь не является самым безупречным и\или самым универсальным. Например, в случае shaed-хостинга с общим IP будет заблокирован один из ресурсов, скорее всего так и останутся заблокированными все остальные, т.к. основным способом блокировок среди провайдеров остаётся блокировка по IP.

См. [детали](https://github.com/DontBeAPadavan/rublock-via-vpn/wiki/Details) для объяснения алгоритма работы решения и диагностики проблем, если что-то пошло не так.
