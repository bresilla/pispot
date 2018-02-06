#1. Install the necessary dependencies
sudo apt-get update
sudo apt-get install hostapd udhcpd -y
sudo apt-get install iptables -y
sudo apt-get update

#2. Files to edit
x=/etc/udev/rules.d/70-persistent-net.rules
y=/etc/dnsmasq.conf
z=/etc/hostapd/hostapd.conf


#3. Allocate device for Acces Point
sudo touch $x
sudo echo SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="b8:27:eb:ff:ff:ff", KERNEL=="phy0", \
  RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
  RUN+="/bin/ip link set ap0 address b8:27:eb:ff:ff:ff" >>  $x

#4. Modifying dnsmasq
sudo echo "interface=lo,ap0" >>  $y
sudo echo "no-dhcp-interface=lo,wlan0" >>  $y
sudo echo "bind-interfaces" >>  $y
sudo echo "server=8.8.8.8" >>  $y
sudo echo "domain-needed" >>  $y
sudo echo "bogus-priv" >>  $y
sudo echo "dhcp-range=192.168.10.50,192.168.10.150,12h" >>  $y

#5. Modifying hostapd
ssid=algorithm
pass=dyhere024
sudo echo "ctrl_interface=/var/run/hostapd" >>  $z
sudo echo "ctrl_interface_group=0" >>  $z
sudo echo "interface=ap0" >>  $z
sudo echo "driver=nl80211" >>  $z
sudo echo "ssid=$ssid" >>  $z
sudo echo "hw_mode=g" >>  $z
sudo echo "channel=11" >>  $z
sudo echo "wmm_enabled=0" >>  $z
sudo echo "macaddr_acl=0" >>  $z
sudo echo "auth_algs=1" >>  $z
sudo echo "wpa=2" >>  $z
sudo echo "wpa_passphrase=$pass" >>  $z
sudo echo "wpa_key_mgmt=WPA-PSK" >>  $z
sudo echo "wpa_pairwise=TKIP CCMP" >>  $z
sudo echo "rsn_pairwise=CCMP" >>  $z

