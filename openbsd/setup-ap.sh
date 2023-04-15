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
HOSTAPD_CONFIG="/etc/hostname.$IFACE"

# Create a hostname configuration file.
if [ ! -f "$HOSTAP_CONFIG" ]; then
	echo "up" > $HOSTAPD_CONFIG
	echo "media autoselect mediaopt hostap" >> $HOSTAPD_CONFIG
	echo "inet $IP $NETMASK" >> $HOSTAPD_CONFIG
	echo "mode 11g" >> $HOSTAPD_CONFIG
	echo "chan $CHANNEL" >> $HOSTAPD_CONFIG
	echo "nwid $SSID \\" >> $HOSTAPD_CONFIG
	echo "wpakey passphrase" >> $HOSTAPD_CONFIG
fi
cat $HOSTAPD_CONFIG

# Optionally enable the DHCP service.
# Configured in /etc/dhcpd.conf.
if [ "$DHCP" = true ] ; then
    dhcpd $IFACE
fi

# Optionally start hostapd.
if [ "$HOSTAPD" = true ] ; then
	sh /etc/netstart $IFACE
fi
