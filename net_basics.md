---
tags: [network, cheatsheet]
aliases: ["nmcli", "nmap", "netcat", "ethtool", "ss"]
type: cheatsheet
---
# Network Basics & Tools
## Basic

### Overall knowledge

- [How can DPDK access devices from user space](https://codilime.com/blog/how-can-dpdk-access-devices-from-user-space/):

  - Linux network software stack
  - Interface between NIC and kernel
  - NIC to kernel data flow
  - User space driver
  - Hugepages

### net-tools vs. iproute2

| Legacy Utility | Obsoleted by                    | Note                           |
|----------------|---------------------------------|--------------------------------|
| ifconfig       | ip [-d] addr, ip link, ip -s    | Address and link configuration |
| route          | ip [-d] route                   | Routing tables                 |
| arp            | ip [-d] neigh                   | Neighbors                      |
| iptunnel       | ip [-d] tunnel                  | Tunnels                        |
| nameif         | ifrename, ip [-d] link set name | Rename NIC names               |
| ipmaddr        | ip [-d] maddr                   | Multicast                      |
| netstat        | ip [-d] -s, ss, ip [-d] route   | Show network statistics        |

### Add a Gateway

ip route add default via 10.108.183.1

### ss

ss is the newly recommended tool (part of the iproute2 package) as a replacement of legacy netstat.

- Show a summary

  ```bash
  # similar as ip -d -s addr/link
  ss -s
  ```

- List all listening ports

  ```bash
  # Unix socket, TCP and UDP
  ss -l [-p] [-n]
  # TCP
  ss -lt [-p] [-n]
  # UDP
  ss -lu [-p] [-n]
  # Unix socket
  ss -lx
  ```

- List all established ports

  ```bash
  ss -[a|t|u|x] [-p] [-n]
  ```

- List socket memory usage

  ```bash
  ss -[l][t|u|x]m
  ```

- List internal TCP information

  ```bash
  ss -[l]ti
  ```

- Show extended information

  ```bash
  ss -[l][t|u|x]e
  ```

- Show timer information

  ```bash
  ss -[l][t|u|x]o
  ```

### ethtool

- Change and show NIC queue/channel

  ```bash
  ethtool -l eth0
  ethtool -L eth0 combined 2
  ethtool -l eth0
  ```

- Change and show NIC feature such as tsp

  ```bash
  ethtool -k eth0
  ethtool -K eth0 tso on
  ```

- Map NIC name to PCI device

  ```bash
  # the bus info can be gotten by running command:
  # cat /sys/class/net/eth0/device/uevent
  ethtool -i eth0 | grep bus-info
  ```

- Show channel statistic of a NIC:

  ```bash
  ethtool -S eth0
  ```

### traceroute

- trace route with icmp by default: traceroute x.x.x.xxx
- trace route with tcp on a specified port(verify if the port is open): traceroute -T -p 48369 x.x.x.x

### rpcinfo

ss -ntlp might show some ports opened without processes attached, such ports may be used by rpc:

```bash
rpcinfo -p
```

### tcptrack

```bash
# monitor tcp traffics between addresses
tcptrack -i eth0
```

### iftop

```bash
# Monitor real time traffic between addresses.
iftop
```

### nethogs

```bash
# Monitor traffic of each process.
nethogs bond1
```

### nmcli

nmcli is a command-line tool for controlling NetworkManager and reporting network status. It can be utilized as a replacement for nm-applet or other graphical clients. nmcli is used to create, display, edit, delete, activate, and deactivate network connections, as well as control and display network device status. **man nmcli-examples** for simple usage.

- Show device status

  ```bash
  nmcli dev status
  ```

- Connect/disconnect device

  ```bash
  nmcli dev <connect|disconnect> <device name>
  ```

- Show network connections/configurations

  ```bash
  nmcli con show
  ```

- Up/down a connection

  ```bash
  nmcli con up/down <name>
  ```

- Create a new connection

  ```bash
  # With DHCP
  nmcli con add type ethernet con-name <connection name> ifname <device name>
  # With static IP
  nmcli con add type ethernet con-name <connection name> ifname <device name> ip4 <ip/netmask> gw4 <gateway>
  # To verify
  # cat /etc/sysconfig/network-scripts/ifcfg-<connection name>
  ```

- Modify a connection

  ```bash
  nmcli con mod <connection name> ipv4.dns "8.8.8.8 8.8.4.4"
  nmcli con mod <connection name> connection.autoconnect no
  nmcli con show <connection name>
  ```

- Edit a connection

  ```bash
  nmcli con edit <name|ID>
  ```

- Create a bond

  ```bash
  nmcli con add type bond ifname bond0
  # nmcli con add type bond ifname bond0 bond.options "mode=balance-rr,miimon=100"
  nmcli con add type ethernet ifname eth0 master bond0
  nmcli con add type ethernet ifname eth1 master bond0
  # the slave nic name can be gotten based on script name under /etc/sysconfig/network-scirpts
  nmcli con up bond-slave-eth0
  nmcli con up bond-slave-eth1
  # assign ip statically as normal nic
  vim /etc/sysconfig/network-scripts/ifcfg-bond-bon0
  # if /etc/sysconfig/network-scripts/ifcfg-eth0|1 exists, delete them
  # configure IPADDR, etc.
  systemctl restart NetworkManager
  # if the IP is not as expected, reboot the server
  ip a show
  ```

### nmap

nmap is a tool for performing network scanning.

- Scan IPs/Hosts

  ```bash
  nmap 192.168.0.9
  nmap 192.168.0.1-20
  nmap 192.168.0.1/24
  nmap www.google.com
  nmap 192.168.0.9,10,11,12
  nmap 192.168.0.9 192.168.0.10
  nmap 192.168.0.* --exclude 192.168.0.1
  nmap -V 192.168.0.9
  ```

- Scan Ports

  ```bash
  nmap -p 80 192.168.0.9
  nmap -p 80,443 192.168.0.9
  nmap -p 1-100 192.168.0.9
  # Scan the most common ports
  nmap --top-ports 20 192.168.0.9
  ```

- Scan TCP/UDP

  ```bash
  # Scan with SYN scan - half-open scanning
  nmap -sS 192.168.1.1
  # Scan with TCP connect
  nmap -sT 192.168.0.9
  # Scan with UDP
  nmap -sU 192.168.0.9
  ```

- Detection

  ```bash
  # OS detection
  nmap -A 192.168.0.9
  # Standard service detection
  nmap -sV 192.168.0.9
  ```

- Get more options

  ```bash
  nmap
  man nmap
  ```

### netcat/ncat/nc

netcat is a computer networking service for reading from and writing network connections using TCP or UDP. It is named as ncat or nc on some platforms.

- Install: nmap project implements a netcat named ncat, hence install nmap will install ncat
- Open a simple server

  ```bash
  # server
  ncat -l -v 1234
  # client
  ncat localhost 1234
  # or
  telnet localhost 1234
  ```

- Open a simple server with UDP

  ```bash
  # server
  ncat -v -ul 7000
  # client
  ncat localhost -u 7000
  ```

- Open a simple server for file transfer

  ```bash
  # server
  cat happy.txt | ncat -v -l -p 5555
  # client
  ncat localhost 5555 > happy_copy.txt
  ```

- Open a simple remote shell server

  ```bash
  # server
  ncat -v -l -p 7777 -e /bin/bash
  # client
  ncat localhost 7777
  ```

- Redirect journal logs to syslog

  ```bash
  journalctl -f | ncat --udp localhost 514
  ```

### Associate Docker Container and Corresponding veth

- Get peer index from container

  ```bash
  docker exec <container ID> ip link list
  docker exec <container ID> ethtool -S <interface>
  # Or use the below command if ethtool is not available
  docker exec <container ID> cat sys/class/net/<interface>/iflink
  ```

- Get host veth

  ```bash
  ip link list | grep <the index found from container>
  ```

### ngrok

ngrok can be used to expose a local web server to the Internet. It is free for temporary usage (refer to [pricing](https://ngrok.com/pricing)) which involves limited connection.

Usage:

```bash
# Expose localhost 8080 to the Internet
ngrok http 8080
```

### DNS Lookup

**nslookup**

- Record types:

  - PTR  : IP to domain name
  - A    : Domain name to IP
  - AAAA : Domain name to IPv6
  - MX   : Mail server
  - SOA  : Start of Authority record indicates which DNS server is the best source of information
  - CNAME: Alias
  - NS   : Name servers for the domain
  - ANY  : Wildcard for all types

- Commands

  ```bash
  nslookup 8.8.8.8
  nslookup dell.com
  nslookup -type=MX dell.com
  nslookup -type=SOA dell.com
  nslookup -type=CNAME dell.com
  nslookup -type=NS dell.com
  nslookup -type=ANY dell.com
  nslookup -server
  # Lookup with a specified DNS server
  nslookup -type=ANY google.com 8.8.8.8
  ```

### rp_filter

Reference: https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt

rp_filter is the abbreviation of "reverse path filtering". It is used to defend network attack such as DDoS, IP Spoofing, etc. The main function of rp_filter is to check whether a receiving packet source address is routable. On a Linux with multiple NICs and package need to be routed between them, rp_filter should  be disabled:

```bash
# echo "0">/proc/sys/net/ipv4/conf/default/rp_filter
# echo "0">/proc/sys/net/ipv4/conf/all/rp_filter
# echo "0">/proc/sys/net/ipv4/conf/eth1/rp_filter
sysctl -a | grep rp_filter
sysctl -w net.ipv4.conf.default.rp_filter=0
sysctl -w net.ipv4.conf.all.rp_filter=0
sysctl -w net.ipv4.conf.eth1.rp_filter=0
```

## Related
- [[net_devices]]
- [[net_tcpdump]]
- [[net_curl]]
- [[linux_ssh]]

