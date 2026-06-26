---
tags: [network, cheatsheet, tc]
aliases: ["tc", "traffic control", "qdisc"]
type: cheatsheet
---
# Traffic Control (tc)
## Traffic control - tc

tc is a tool within iproute2, which is used mainly for egress traffic control(works for ingress traffic, but supports limited functions). It can be used to control network bandwidth, add package delay, emulate package loss, etc. Classful qdiscs are used for most use cases since more features are supported(especially HTB), hence use htb whenever possible.

References:

- The overall manual: https://tldp.org/HOWTO/Traffic-Control-HOWTO/index.html
- The unique identifier/handle(understand major and minor): https://tldp.org/HOWTO/Traffic-Control-HOWTO/components.html#c-handle
- The qdisc concept(understand root): https://tldp.org/HOWTO/Traffic-Control-HOWTO/components.html#c-qdisc
- Classful qdisc: https://lartc.org/howto/lartc.qdisc.classful.html
- HTB basics: https://tldp.org/HOWTO/Traffic-Control-HOWTO/classful-qdiscs.html#qc-htb
- HTB examples with wonderful diagrams:
  - https://wiki.debian.org/TrafficControl
  - https://www.sobyte.net/post/2022-03/linux-tc-flow-control
- NETEM(mainly used for emulating abnormal scenarios such as package delay, loss, duplication, etc.): https://wiki.linuxfoundation.org/networking/netem
- Filter basics: https://lartc.org/howto/lartc.qdisc.filters.html
- The u32 classifier(protocol level match): https://tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.adv-filter.u32.html
- Commands:
  - man tc: the PARAMETERS section lists the syntax of RATES, TIMES, and SIZES
  - man tc-htb
  - man tc-netem
  - man tc-u32

Example 1:

```bash
tc qdisc del dev eth0 root netem
# specify several options together
tc qdisc add dev eth0 netem delay 10ms reorder 5% loss 5%
tc qdisc show dev eth0
```

Example 2:

```bash
# refer to https://wiki.debian.org/TrafficControl to understand htb
tc qdisc del dev eth0 root # clear egress which is named root

# tc qdisc add dev eth0 root handle 1: htb r2q 1
tc qdisc add dev eth0 root handle 1: htb default 6

tc class add dev eth0 parent 1: classid 1:1 htb rate 10mbit ceil 10mbit

tc class add dev eth0 parent 1:1 classid 1:5 htb rate 0.1mbit ceil 0.1mbit
tc filter add dev eth0 protocol ip parent 1:1 prio 1 u32 match ip sport 3260 0xffff flowid 1:5
tc filter add dev eth0 protocol ip parent 1:1 prio 1 u32 match ip dst 192.168.10.10 flowid 1:5
tc qdisc add dev eth0 handle 30: parent 1:5 netem loss 100%

tc class add dev eth0 parent 1:1 classid 1:6 htb rate 10.9mbit ceil 10.9mbit

tc qdisc show dev eth0
tc class show dev eth0
```

Example 3:

```bash
# control overall bandwidth
tc qdisc del dev eth0 root htb
tc qdisc add dev eth0 root handle 1: htb default 10
tc class add dev eth0 parent 1: classid 1:10 htb rate 2mbit ceil 2mbit
tc qdisc show dev eth0
tc class show dev eth0
```

## Related
- [[net_basics]]

