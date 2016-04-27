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

# Set Gateway IP
/usr/bin/ip addr add 192.168.202.1/24 broadcast 192.168.202.255 dev bat0

# Start the dhcp server on bat0
/usr/bin/systemctl start dhcpd4@bat0

# This sets up routing
/usr/bin/iptables -t nat -A POSTROUTING -o int0 -j MASQUERADE
/usr/bin/iptables -A FORWARD -i int0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
/usr/bin/iptables -A FORWARD -i bat0 -o int0 -j ACCEPT
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
/usr/bin/iptables -D FORWARD -i int0 -o bat0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
/usr/bin/iptables -D FORWARD -i bat0 -o int0 -j ACCEPT
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

# Bridge Setup
/usr/bin/ip link add name mesh-bridge type bridge
/usr/bin/ip link set dev eth0 master mesh-bridge
/usr/bin/ip link set dev bat0 master mesh-bridge
/usr/bin/ip link set up dev eth0
/usr/bin/ip link set up dev bat0
/usr/bin/ip link set up dev mesh-bridge

# Set the mesh-bridge IP
/usr/bin/ip addr add 192.168.202.2/24 broadcast 192.168.202.255 dev mesh-bridge
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