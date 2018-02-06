sudo apt-get update
sudo apt-get install iptables iw iproute2 -y

a=/etc/wpa_supplicant/wpa_supplicant.conf && sudo rm -f $a && sudo touch $a
b=/etc/network/interfaces && sudo rm -f $b && sudo touch $b
c=/etc/udev/rules.d/70-persistent-net.rules && sudo rm -f $c && sudo touch $c

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