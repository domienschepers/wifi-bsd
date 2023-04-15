# NetBSD Wi-Fi

This README is written based on NetBSD ```Version 9.2```.

## Hardware

We confirmed support for the following hardware.

For more information on all evaluated hardware, see [Wi-Fi Hardware](../HARDWARE.md). 

| Wi-Fi Dongle | Device ID | HW Vendor | Manpage | AP-Mode |
| :----------- | :----- | :-------- | :------ | :-----: |
| Airlink 101 AWLL3026 | 0ace:1211 | ZyDAS (_zyd_) | https://man.netbsd.org/NetBSD-9.2-STABLE/zyd.4 | No |
| ALFA Network AWUS036NH | 148f:3070 | Ralink (_run_) | https://man.netbsd.org/NetBSD-9.2-STABLE/run.4 | No |
| Belkin F5D8053 v3 | 050d:815c | Ralink (_run_) | https://man.netbsd.org/NetBSD-9.2-STABLE/run.4 | No |
| Edimax EW-7811Un v2 | 7392:7811 | Realtek (_urtwn_) | https://man.netbsd.org/NetBSD-9.2-STABLE/urtwn.4 | Yes |
| Linksys WUSB600N v1 | 1737:0071 | Ralink (_run_) | https://man.netbsd.org/NetBSD-9.2-STABLE/run.4 | No |
| Linksys WUSBF54G v1.1 | 13b1:0024 | ZyDAS (_zyd_) | https://man.netbsd.org/NetBSD-9.2-STABLE/zyd.4 | No |
| Netgear WG111 v2 | 0846:6a00 | Realtek (_urtw_) | https://man.netbsd.org/NetBSD-9.2-STABLE/urtw.4 | Yes |
| Netgear WG111 v3 | 0846:4260 | Realtek (_urtw_) | https://man.netbsd.org/NetBSD-9.2-STABLE/urtw.4 | Yes |
| Sitecom WL-172 v1 | 0df6:90ac | Ralink (_rum_) | https://man.netbsd.org/NetBSD-9.2-STABLE/rum.4 | Yes |
| TP-Link TL-WN722N v1.10 | 0cf3:9271 | Atheros (_athn_) | https://man.netbsd.org/NetBSD-9.2-STABLE/athn.4 | Yes |
| TP-Link TL-WN722N v3 | 2357:010c | Realtek (_urtwn_) | https://man.netbsd.org/NetBSD-9.2-STABLE/urtwn.4 | Yes |
| TP-Link TL-WN725N v3.8 | 0bda:8179 | Realtek (_urtwn_) | https://man.netbsd.org/NetBSD-9.2-STABLE/urtwn.4 | Yes |

## Configuration of Network Interfaces

#### Client

Clients can connect to a network using the well-known ```wpa_supplicant```:
```
wpa_supplicant -i wlan0 -c supplicant.conf
```

#### Access Point

An access point can be set up using the well-known ```hostapd```:
```
hostapd -i wlan0 hostapd.conf
```

#### DHCP

First we must enable ```dhcpd``` in ```/etc/rc.conf```:
```
dhcpd=YES
```

Write the configuration in ```/etc/dhcpd.conf```, for example:
```
allow unknown-clients;
subnet 192.168.0.0 netmask 255.255.255.0 {
    range 192.168.0.100 192.168.0.200;
    default-lease-time 604800;
    max-lease-time 604800;
    option routers 192.168.0.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.168.0.255;
}
```

Then start the DHCP daemon:
```
dhcpd wlan0
```

## Kernel

Instructions to rebuild the kernel with debug statements.

:warning: These instructions are for debugging purposes only and should not be used on production environments.

Resources:

- https://www.netbsd.org/docs/guide/en/chap-fetch.html
- https://www.netbsd.org/docs/guide/en/chap-kernel.html

#### Rebuild the Kernel

Clone the appropriate kernel source code into ```/usr/src```:
```
cd /usr
export CVSROOT="anoncvs@anoncvs.NetBSD.org:/cvsroot"
cvs checkout -r netbsd-9-2-RELEASE -P src
```

We can now simply build and install:
```
cd /usr/src/sys/arch/$(machine)/conf
config GENERIC
cd /usr/src/sys/arch/$(machine)/compile/GENERIC
make depend
make
make install
```

#### Debugging WLAN

Debug messages can be added with simple print statements:
```c
printf("DEBUG-WLAN: Statement.\n");
```

Interesting source files are located in the ```/usr/src/sys/net80211/``` directory.

The kernel can now be rebuild and installed as instructed above.

#### Creating a Patch

Creating a patch file of any changes can be done as follows:
```
cd /usr/src
cvs diff -u ./sys/net80211/ > filename.patch
```

## Drivers

Instructions to rebuild device drivers.

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
