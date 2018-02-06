sudo apt-get update
sudo apt-get install hostapd udhcpd -y

d=/etc/hostapd/hostapd.conf && sudo rm -f $d && sudo touch $d
e=/usr/local/bin/hostapdstart && sudo rm -f $e && sudo touch $e sudo chmod 775 $e
f=/etc/dnsmasq.conf && sudo rm -f $f && sudo touch $f

sudo echo "DAEMON_CONF='/etc/hostapd/hostapd.conf'" >>  /etc/default/hostapd
sudo echo "/bin/bash /usr/local/bin/hostapdstart" >>  /etc/rc.local


#Modifying hostapd -----------------------------------------------------------
ssid=dronewifi
pass=dyhere024
sudo echo "interface=uap0
ssid=$ssid
hw_mode=g
channel=11
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$pass
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP" >> $d

#Making an  autostart script--------------------------------------------------
sudo echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
iw dev wlan0 interface add uap0 type __ap
service dnsmasq restart
sysctl net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 192.168.50.0/24 ! -d 192.168.50.0/24 -j MASQUERADE
ifup uap0
hostapd /etc/hostapd/hostapd.conf" >> $e


#Modifying dnsmasq ---------------------------------------------------------
sudo echo "interface=lo,uap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.50.50,192.168.50.150,12h" >> $f