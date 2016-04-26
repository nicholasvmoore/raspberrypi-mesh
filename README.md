Manual Mesh inception
---------------------

# Mesh Gateway
```bash
# Load Module
/usr/bin/modprobe batman-adv

# Enable IP Forwarding
/usr/bin/sysctl -w net.ipv4.ip_forward=1

# Ad-Hoc
/usr/bin/ip link set mtu 1532 dev wlan0
/usr/bin/iw wlan0 set type ibss
/usr/bin/ip link set wlan0 up
/usr/bin/iw wlan0 ibss join mesh 2462 HT20

# B.A.T.M.A.N. setup
/usr/local/sbin/batctl if add wlan0
/usr/bin/ip link set bat0 up
/usr/local/sbin/batctl gw_mode server

# Avahi IP'ing this creates a bat0:avahi alias which you'll have to use for routing
/usr/bin/avahi-autoipd bat0

# This sets up routing
/usr/bin/iptables -t nat -A POSTROUTING -o int0 -j MASQUERADE
/usr/bin/iptables -A FORWARD -i int0 -o bat0:avahi -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
/usr/bin/iptables -A FORWARD -i bat0:avahi -o int0 -j ACCEPT