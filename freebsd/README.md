# FreeBSD Wi-Fi

This README is written based on FreeBSD ```Version 13.0-RELEASE```.

## Hardware

We confirmed support for the following hardware.

For more information on all evaluated hardware, see [Wi-Fi Hardware](../HARDWARE.md). 

| Wi-Fi Dongle | Device ID | HW Vendor | Manpage | AP-Mode |
| :----------- | :----- | :-------- | :------ | :-----: |
| Airlink 101 AWLL3026 | 0ace:1211 | ZyDAS (_zyd_) | https://www.freebsd.org/cgi/man.cgi?zyd(4) | No |
| ALFA Network AWUS036NH | 148f:3070 | Ralink (_run_) | https://www.freebsd.org/cgi/man.cgi?run(4) | Yes |
| Belkin F5D8053 v3 | 050d:815c | Ralink (_run_) | https://www.freebsd.org/cgi/man.cgi?run(4) | Yes |
| Edimax EW-7811Un v2 | 7392:7811 | Realtek (_rtwn_) | https://www.freebsd.org/cgi/man.cgi?rtwn(4) | Yes |
| Linksys WUSB600N v1 | 1737:0071 | Ralink (_run_) | https://www.freebsd.org/cgi/man.cgi?run(4) | Yes |
| Linksys WUSBF54G v1.1 | 13b1:0024 | ZyDAS (_zyd_) | https://www.freebsd.org/cgi/man.cgi?zyd(4) | No |
| Netgear WG111 v2 | 0846:6a00 | Realtek (_urtw_) | https://www.freebsd.org/cgi/man.cgi?urtw(4) | No |
| Netgear WG111 v3 | 0846:4260 | Realtek (_urtw_) | https://www.freebsd.org/cgi/man.cgi?urtw(4) | No |
| Sitecom WL-172 v1 | 0df6:90ac | Ralink (_rum_) | https://www.freebsd.org/cgi/man.cgi?rum(4) | Yes |
| TP-Link TL-WN722N v3 | 2357:010c | Realtek (_rtwn_) | https://www.freebsd.org/cgi/man.cgi?rtwn(4) | Yes |
| TP-Link TL-WN725N v3.8 | 0bda:8179 | Realtek (_rtwn_) | https://www.freebsd.org/cgi/man.cgi?rtwn(4) | Yes |
| TRENDnet TEW-648UB v1 | 0bda:8171 | Realtek (_rsu_) | https://www.freebsd.org/cgi/man.cgi?rsu(4) | No |

## Configuration of Network Interfaces

Load drivers on boot by creating or modifying ```/boot/loader.conf```:
```
if_run_load="YES"
if_rum_load="YES"
if_rtwn_usb_load="YES"
```

Alternatively, load them directly when needed, for example:
```
kldload if_rum
```

Now we can create a wireless interface for the respective driver. For example, for ```rum0``` devices:
```
ifconfig wlan create wlandev rum0
```

Which will print the name of the created interface (```wlan0```).

#### Client

Clients can connect to a network using the well-known ```wpa_supplicant```: 
```
wpa_supplicant -i wlan0 -c supplicant.conf
```

#### Access Point

In order to create an access point, the corresponding mode has to be set when creating the interface:
```
ifconfig wlan create wlandev rum0 wlanmode hostap
```

An access point can now be set up using the well-known ```hostapd```: 
```
hostapd -i wlan0 hostapd.conf
```

We provide a script to automatically configure and set up an access point, optionally with support for DHCP.
```
Usage; ./setup.sh interface
```

For example:
```
./setup.sh rum0
```

#### DHCP

Install a DHCP server, for example:
```
pkg install isc-dhcp44-server
```
Then enable DHCP in ```/etc/rc.conf```:
```
dhcpd_enable="YES"
dhcpd_ifaces="wlan0"
```
Write the following configuration file in ```/usr/local/etc/dhcpd.conf```:
```
### Lease Times
default-lease-time 86400;
max-lease-time 86400;

### Options
authoritative;
get-lease-hostnames true;
option broadcast-address 192.168.0.255;
option routers 192.168.0.1;
option subnet-mask 255.255.255.0;

### DHCP Address Bank of 100 ip addresses
subnet 192.168.0.0 netmask 255.255.255.0
{
range 192.168.0.100 192.168.0.200;
}
```
The DHCP server can now be started:
```
service isc-dhcpd start
```

## Kernel

Instructions to rebuild the kernel with debug statements.

:warning: These instructions are for debugging purposes only and should not be used on production environments.

Resources:
- https://docs.freebsd.org/en/books/handbook/kernelconfig/#kernelconfig-building

#### Pre-Requirements

```
pkg install git
```

#### Rebuild the Kernel

Clone the appropriate kernel source code into ```/usr/src```: 
```
git clone --depth 1 -b release/13.0.0 https://github.com/freebsd/freebsd-src /usr/src
```

We can now simply build and install:
```
cd /usr/src
make buildkernel
make installkernel
```
Note the option ```KERNCONF=MYKERNEL``` can be used to use [customized kernel configurations](https://docs.freebsd.org/en/books/handbook/kernelconfig/#kernelconfig-config).

By default, the above installation will use the ```/usr/src/sys/amd64/conf/GENERIC``` configuration file.

In the ```GENERIC``` configuration file, the ```IEEE80211_DEBUG``` option should be enabled by default.

#### Debugging WLAN

Debug messages can be added with simple print statements:
```c
printf("DEBUG-WLAN: Statement.\n");
```

Interesting source files are located in the ```/usr/src/sys/net80211/``` directory.

Building the kernel is a slow procedure.
Therefore, for new builds during the debugging procedure, you can disable a clean build:
```
make -DNO_CLEAN buildkernel
make installkernel
```

#### Creating a Patch

Creating a patch file of any changes can be done as follows:
```
cd /usr/src
git diff > filename.patch
```

## Kernel Modules

In addition to the kernel, one can rebuild individual kernel modules which are loaded at run-time using ```kldload```.

Kernel modules are located in ```/usr/src/sys/modules``` with notable wireless driver code in ```/usr/src/sys/dev/usb/wlan/```.

#### Example

For example, the source of Ralink's ```run``` driver can be found in ```/usr/src/sys/dev/usb/wlan/if_run.c```.

To rebuild the driver source code, one can make and install its approriate Makefile: 
```
cd /usr/src/sys/modules/usb/run
make
make install
```

Now the rebuilt module can be found in, and loaded from, ```/boot/modules/```:
```
kldunload if_run
kldload /boot/modules/if_run.ko
```

Note ```kldstat``` can be used to report statistics on the loaded kernel modules.

## Logging

FreeBSD allows for one to enable additional wlan debug messages.

Resources:
- https://wiki.freebsd.org/WiFi/Debugging
- https://www.freebsd.org/cgi/man.cgi?wlan
- https://www.freebsd.org/cgi/man.cgi?wlandebug

#### Verbosity

Using ```wlandebug```, one can change the verbosity of wlan debug messages.
To list the current messages:
```
wlandebug
```

A full list of available options is listed on the [wlandebug manpage](https://www.freebsd.org/cgi/man.cgi?wlandebug).

As an example, one can enable debug messages for power save operations:
```
wlandebug -i wlan0 power
```

These messages are then written to ```/var/log/messages``` or can be displayed using ```dmesg```.

The following are example debug messages for power save operations:
```
wlan0: [aa:aa:aa:aa:aa:aa] power save mode on, 1 sta's in ps mode
wlan0: [aa:aa:aa:aa:aa:aa] save frame with age 0, 1 now queued
wlan0: ieee80211_beacon_update: TIM updated, pending 1, off 0, len 1
wlan0: [aa:aa:aa:aa:aa:aa] power save mode off, 0 sta's in ps mode
wlan0: ieee80211_beacon_update: TIM updated, pending 0, off 0, len 1
wlan0: [aa:aa:aa:aa:aa:aa] flush ps queue, 1 packets queued
```
