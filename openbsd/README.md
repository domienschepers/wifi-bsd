# OpenBSD Wi-Fi

This README is written based on OpenBSD ```Version 6.8``` and ```Version 6.9```.

## Hardware

We confirmed support for the following hardware.

For more information on all evaluated hardware, see [Wi-Fi Hardware](../HARDWARE.md). 

| Wi-Fi Dongle | Device ID | HW Vendor | Manpage | AP-Mode |
| :----------- | :----- | :-------- | :------ | :-----: |
| ALFA Network AWUS036NH | 148f:3070 | Ralink (_run_) | https://man.openbsd.org/run | No |
| Belkin F5D8053 v3 | 050d:815c | Ralink (_run_) | https://man.openbsd.org/run | No |
| D-Link DWL-G132 vA2 | 2001:3a02 | Atheros (_uath_) | https://man.openbsd.org/uath | No |
| Edimax EW-7811Un v2 | 7392:7811 | Realtek (_urtwn_) | https://man.openbsd.org/urtwn | No |
| Linksys WUSB600N v1 | 1737:0071 | Ralink (_run_) | https://man.openbsd.org/run | No |
| Netgear WG111 v2 | 0846:6a00 | Realtek (_urtw_) | https://man.openbsd.org/urtw | No |
| Netgear WG111 v3 | 0846:4260 | Realtek (_urtw_) | https://man.openbsd.org/urtw | No |
| Netgear WN111 v2 | 0846:9001 | Atheros (_otus_) | https://man.openbsd.org/otus | No |
| Netgear WPN111 | 1385:5f00 | Atheros (_uath_) | https://man.openbsd.org/uath | No |
| Sitecom WL-172 v1 | 0df6:90ac | Ralink (_rum_) | https://man.openbsd.org/rum | Yes |
| TP-Link TL-WN722N v1.10 | 0cf3:9271 | Atheros (_athn_) | https://man.openbsd.org/athn | Yes |
| TP-Link TL-WN722N v3 | 2357:010c | Realtek (_urtwn_) | https://man.openbsd.org/urtwn | No |
| TP-Link TL-WN725N v3.8 | 0bda:8179 | Realtek (_urtwn_) | https://man.openbsd.org/urtwn | No |
| TP-Link TL-WN821N v3 | 0cf3:7015 | Atheros (_athn_) | https://man.openbsd.org/athn | Yes |
| TRENDnet TEW-648UB v1 | 0bda:8171 | Realtek (_rsu_) | https://man.openbsd.org/rsu | No |

## Configuration of Network Interfaces

Firmware updates may be needed:
```
fw_update -v
```

We must edit ```/etc/hostname.athn0``` where ```athn0``` is the interface name.

Below are example configuration files for clients and access points.

After writing the configuration, the interface is then started as follows:
```
sh /etc/netstart athn0
```

#### Client

Clients can connect to a typical WPA2(PSK/AES/AES) network using the following configuration:
```
up media autoselect
	nwid testnetwork \
	wpakey passphrase \
	wpaprotos wpa2 \
	wpaciphers ccmp \
	wpagroupcipher ccmp
```

Alternatively, these options can be set manually, for example:
```
ifconfig athn0 nwid testnetwork wpakey passphrase
ifconfig athn0 wpaprotos wpa2 wpaciphers ccmp wpagroupcipher ccmp
ifconfig athn0 up
```

#### Access Point

The following configuration can be used to create a typical WPA2(PSK/AES/AES) network:
```
up media autoselect mediaopt hostap 
	inet 192.168.0.1 255.255.255.0
	mode 11g \
	chan 1 \
	nwid testnetwork \
	wpakey passphrase \
	wpaciphers ccmp \
	wpagroupcipher ccmp
```

Alternatively, these options can be set manually, for example:
```
ifconfig athn0 media autoselect mediaopt hostap 192.168.0.1 netmask 255.255.255.0
ifconfig athn0 chan 1 nwid testnetwork wpakey passphrase
ifconfig athn0 up
```

#### DHCP

Write the following configuration into ```/etc/dhcpd.conf```:
```
subnet 192.168.0.0 netmask 255.255.255.0 {
	option routers 192.168.0.1;
	range 192.168.0.100 192.168.0.200;
}
```

The DHCP Daemon can then be started for a given interface:
```
dhcpd athn0
```

## Kernel

Instructions to rebuild the kernel with debug statements.

:warning: These instructions are for debugging purposes only and should not be used on production environments.

Resources:
- https://www.openbsd.org/faq/faq5.html
- https://www.openbsd.org/anoncvs.html

#### Rebuild the Kernel

Clone the appropriate kernel source code into ```/usr/src```:
```
cd /usr
cvs -qd anoncvs@anoncvs.usa.openbsd.org:/cvs checkout -rOPENBSD_6_9 -P src
```

We can now simply build and install:
```
cd /usr/src/sys/arch/$(machine)/conf
config GENERIC
cd /usr/src/sys/arch/$(machine)/compile/GENERIC
make
make install
```

#### Debugging WLAN

Debug messages can be added with simple print statements:
```c
printf("DEBUG-WLAN: Statement.\n");
```

Interesting source files are located in the ```/usr/src/sys/net80211/``` directory.

The kernel can now be rebuild:
```
cd /usr/src/sys/arch/$(machine)/compile/GENERIC
make
make install
```

#### Creating a Patch

Creating a patch file of any changes can be done as follows:
```
cd /usr/src
cvs diff -u ./sys/net80211/ > filename.patch
```

## Drivers

Instructions to rebuild device drivers.

Resources:
- https://www.openbsd.org/papers/eurobsdcon2017-device-drivers.pdf
 
Device driver code runs in the kernel and can be found in ```/usr/src/sys/dev```.

Interesting source files for Wi-Fi dongles are located in the ```/usr/src/sys/dev/usb/``` directory.

For example, Atheros code can be found in ```/usr/src/sys/dev/usb/if_athn_usb.c```.

Changes can be made by rebuilding the kernel as listed above, and rebooting the system:
```
cd /usr/src/sys/arch/$(machine)/compile/GENERIC
make
make install
```

## Logging

We can slightly increase debugging output for interface ```wlan0``` with:
```
ifconfig wlan0 debug
```

## Miscellaneous 

- Create and mount a sufficiently large disk for ```/usr/src``` to hold the source code.
