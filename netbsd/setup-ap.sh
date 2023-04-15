# Copyright (C) 2021-2023 Domien Schepers.

if [ $# -eq 0 ] ; then
    echo "Usage; $0 interface"
    exit 1
fi

# Parameters.
IFACE=$1
SSID="testnetwork"
CHANNEL="1"
IP="192.168.0.1"
NETMASK="255.255.255.0"
DHCP=true
HOSTAPD=true
HOSTAPD_CONFIG="./hostapd.conf"

# Configure the interface.
ifconfig $IFACE up
ifconfig $IFACE ssid $SSID mode 11g chan $CHANNEL
ifconfig $IFACE inet $IP netmask $NETMASK
ifconfig $IFACE

# Optionally enable the DHCP service.
# Configured in /etc/dhcpd.conf.
if [ "$DHCP" = true ] ; then
	service dhcpd stop
	dhcpd $1
fi

# Optionally start hostapd.
if [ "$HOSTAPD" = true ] ; then
	hostapd -i $IFACE $HOSTAPD_CONFIG
fi
