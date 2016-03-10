## Использование OpenVPN для обхода блокировок
Решение ниже позволяет использовать VPN-соедиенение исключтельно для списка блокируемых ресурсов. При обращении к любым другим ресурсам будет использоваться привычное провайдерское соединение.

### Требования
* Прошивка с ipset (любые сборки Padavan, кроме nano),
* [Развёрнутый](https://bitbucket.org/padavan/rt-n56u/wiki/RU/HowToConfigureEntware) репозиторий Entware.

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

В веб-интерфейсе роутера на странице `Customization > Scripts` отредактируйте поле `Run After Router Started`, раскоментировав две строчки:
```
modprobe ip_set_hash_ip
modprobe xt_set
```
