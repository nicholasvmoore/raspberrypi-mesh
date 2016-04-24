#!/bin/bash

pacman -Sy dhcp linux-raspberrypi-headers make

# Notes
#ip link set mtu 1532 dev wlan0