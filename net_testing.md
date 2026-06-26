---
tags: [network, cheatsheet]
aliases: ["iperf", "qperf", "packetdrill", "ethr"]
type: cheatsheet
---
# Network Testing Tools
## Testing tools

### Bandwidth testing/stressing

```bash
# TCP:
# Server side
iperf3 -s
# Client side
iperf3 -c <server ip>
iperf3 -c <server ip> -P 8
iperf3 -c <server ip> -w 32k # it is not recommened to set window size for most cases
#
# UDP:
# Server side
iperf3 -s
# Client side
iperf3 -c <server ip> -u -b 0
iperf3 -c <server ip> -u  -b 0 -P 8
```

### PPS testing/stressing

```bash
# Only for UDP
# Server side
iperf3 -s
# Client side
iperf3 -c 172.16.0.4 -l 16 -u -b 0
iperf3 -c 172.16.0.4 -l 16 -u -b 0 -P 8
```

### Latency testing

```bash
# Use ping:
ping -f <target ip> # ctr + c to stop the execution, then check the output or as below
ping -f <target ip> -c 100000
# Use qperf:
# Server side
qperf
# Client side - TCP
qperf -ip 19766 -t 60 --use_bits_per_sec <server ip> tcp_lat
# Client side - UDP
qperf -ip 19766 -t 60 --use_bits_per_sec <server ip> udp_lat
```

### TCP/IP stack sanity - packetdrill

Google realease of packetdrill for testing entire TCP/UDP/IPv4/IPv6 network stacks, from the system call layer down to the NIC hardware.

Reference: https://github.com/google/packetdrill

### TCP/IP stack robustness - isic

ISIC, abbreviation for IP Stack Integrity Checker, is designed for testing the integrity of TCP/IP stack. It consists of isic/isic6, tcpsic/tpcsic6, udpsic/udpsic6, esic, icmpsic/icmpsic6, and multisic. Most of time, it can be used for generating stress of desired types of traffic.

Reference: https://github.com/IPv4v6/isic

### New Tools - ethr

ethr is based on golang, it supports TCP, UDP, HTTP/HTTPS, and ICMP for measuring bandwidth, connections/s, packets/s, latency, loss & jitter.

Reference: https://github.com/microsoft/ethr

## Related
- [[net_basics]]

