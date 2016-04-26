Manual Mesh inception
---------------------

## Mesh Gateway
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

# B.A.T.M.A.N. config
/usr/local/sbin/batctl if add wlan0
/usr/bin/ip link set bat0 up
/usr/local/sbin/batctl gw_mode server

# Avahi IP'ing this creates a bat0:avahi alias which you'll have to use for routing
/usr/bin/avahi-autoipd bat0

# This sets up routing
/usr/bin/iptables -t nat -A POSTROUTING -o int0 -j MASQUERADE
/usr/bin/iptables -A FORWARD -i int0 -o bat0:avahi -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
/usr/bin/iptables -A FORWARD -i bat0:avahi -o int0 -j ACCEPT
```

### Cleanup
```bash
/usr/bin/ip link set wlan0 down
/usr/bin/ip addr flush dev wlan0
/usr/bin/iw wlan0 set type managed
/usr/bin/rmmod batman-adv
/usr/bin/ip link set mtu 1500 dev wlan0
/usr/bin/ip link del mesh-bridge
/usr/bin/iptables -t nat -D POSTROUTING -o int0 -j MASQUERADE
/usr/bin/iptables -D FORWARD -i int0 -o bat0:avahi -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
/usr/bin/iptables -D FORWARD -i bat0:avahi -o int0 -j ACCEPT
```

## Mesh Client
```bash
# Load Module
/usr/bin/modprobe batman-adv

# Ad-Hoc
/usr/bin/ip link set mtu 1532 dev wlan0
/usr/bin/iw wlan0 set type ibss
/usr/bin/ip link set wlan0 up
/usr/bin/iw wlan0 ibss join mesh 2462 HT20

# B.A.T.M.A.N. config
/usr/local/sbin/batctl if add wlan0
/usr/bin/ip link set bat0 up
/usr/local/sbin/batctl gw_mode client

# Avahi IP'ing this creates a bat0:avahi alias which you'll have to use for bridging
/usr/bin/avahi-autoipd bat0

# Bridge Setup
/usr/bin/ip link add name mesh-bridge type bridge
/usr/bin/ip link set dev eth0 master mesh-bridge
/usr/bin/ip link set dev bat0:avahi master mesh-bridge
/usr/bin/ip link set up dev eth0
/usr/bin/ip link set up dev bat0:avahi
/usr/bin/ip link set up dev mesh-bridge
```

### Cleanup
```bash
/usr/bin/ip link set wlan0 down
/usr/bin/ip addr flush dev wlan0
/usr/bin/iw wlan0 set type managed
/usr/bin/rmmod batman-adv
/usr/bin/ip link set mtu 1500 dev wlan0
/usr/bin/ip link del mesh-bridge
```