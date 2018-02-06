sudo apt-get install iptables iw iproute2 -y
sudo apt-get install hostapd udhcpd -y

a=/etc/wpa_supplicant/wpa_supplicant.conf && sudo rm -f $a && sudo touch $a
b=/etc/network/interfaces && sudo rm -f $b && sudo touch $b
c=/etc/udev/rules.d/70-persistent-net.rules && sudo rm -f $c && sudo touch $c
d=/etc/hostapd/hostapd.conf && sudo rm -f $d && sudo touch $d
e=/usr/local/bin/hostapdstart && sudo rm -f $e && sudo touch $e sudo chmod 775 $e
f=/etc/dnsmasq.conf && sudo rm -f $f && sudo touch $f

sudo echo "DAEMON_CONF='/etc/hostapd/hostapd.conf'" >>  /etc/default/hostapd
sudo echo "/bin/bash /usr/local/bin/hostapdstart" >>  /etc/rc.local

piMAC=b8:27:eb:32:88:26

#Modifying wpa_supplicant ---------------------------------------------------
ssid=algorithm
pass=dyhere024
sudo echo "country=DE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid='$ssid'
    psk='$pass'
}" >>  $a


#Modifying interfaces -------------------------------------------------------
sudo echo "source-directory /etc/network/interfaces.d
auto lo
auto eth0
auto wlan0
auto uap0
iface eth0 inet dhcp
iface lo inet loopback
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
iface uap0 inet static
  address 192.168.50.1
  netmask 255.255.255.0
  network 192.168.50.0
  broadcast 192.168.50.255
  gateway 192.168.50.1" >>  $b


sudo echo "SUBSYSTEM=='ieee80211', ACTION=='add|change', ATTR{macaddress}=='$piMAC', KERNEL=='phy0', \
RUN+='/sbin/iw phy phy0 interface add uap0 type __ap', \
RUN+='/bin/ip link set uap0 address $piMAC'" >>  $c


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