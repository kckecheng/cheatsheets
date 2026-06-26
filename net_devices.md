---
tags: [network, cheatsheet]
aliases: ["bond", "vlan", "vxlan", "bridge", "veth", "tun tap"]
type: cheatsheet
---
# Network Devices
## Devices

### Bonded Device

The Linux bonding driver provides a method for aggregating multiple network interfaces into a single logical "bonded" interface. The behavior of the bonded interface depends on the mode; generally speaking, modes provide either hot standby or load balancing services.

```bash
modinfo bonding
ip link add bond0 type bond
ip link set bond0 type bond miimon 100 mode active-backup
ip link set eth0 master bond0
ip link set eth1 master bond0
ip link set bond0 up
```

### VLAN Interface

```text
+----------------------------------+
|           Server                 |
|  +--------+        +--------+    |
|  | eth0.2 |        | eth0.3 |    |
|  +---+----+        +----+---+    |
|      |                  |        |
|      +--------+---------+        |
|               |                  |
|           +---+---+              |
|           | eth0  |              |
|           +---+---+              |
+---------------|------------------+
                |
        +-------+-------+
        |    Switch     |
        +---------------+
```

```bash
ip link add link eth0 name eth0.2 type vlan id 2
ip link add link eth0 name eth0.3 type vlan id 3
```

### MACVLAN Interface

With VLAN, multiple interfaces can be created on top of a single one and packages can be filtered based on VLAN tags. With MACVLAN, multiple interfaces with different Layer 2 (MAC) addresses can be created on top of a single one.

```text
+-------------------------------------------------------+
|                      Host                             |
|  +------------------+    +------------------+         |
|  |     netns 1      |    |     netns 2      |         |
|  |  +----------+    |    |  +----------+    |         |
|  |  |  macv1   |    |    |  |  macv2   |    |         |
|  |  +----+-----+    |    |  +----+-----+    |         |
|  |       |          |    |       |          |         |
|  |  +----+-----+    |    |  +----+-----+    |         |
|  |  |  macv1   |    |    |  |  macv2   |    |         |
|  |  +----+-----+    |    |  +----+-----+    |         |
|  +-------|----------+    +-------|----------+         |
|          |    (bridge/pvep)     |                     |
|          +----------+-----------+                     |
|                     |                                 |
|                 +---+---+                             |
|                 |  eth0 |                             |
|                 +---+---+                             |
+---------------------|---------------------------------+
                      |
              +-------+-------+
              |    Switch     |
              +---------------+
```

In the meanwhile, MACVLAN supports several different modes:

- private : doesn't allow communication between MACVLAN instances on the same physical interface;
- vepa    : virtual ethernet port aggregator, data from one MACVLAN instance to the other on the same physical interface is transmitted over the physical interface;
- bridge  : all endpoints are directly connected to each other with a simple bridge via the physical interface (the default mode);
- passthru: allows a single VM to be connected directly to the physical interface;
- source  : filter traffic based on a list of allowed source MAC addresses;

**Examples:**

```bash
ip link add macvlan1 link eth0 type macvlan mode bridge
ip link add macvlan2 link eth0 type macvlan mode bridge
ip netns add net1
ip netns add net2
ip link set macvlan1 netns net1
ip link set macvlan2 netns net2
```

### VXLAN Interface

```text
+---------------------+                      +---------------------+
|       Server        |                      |       Server        |
|  +---------------+  |                      |  +---------------+  |
|  |      vx0      |  |                      |  |      vx0      |  |
|  +-------+-------+  |                      |  +-------+-------+  |
|          |          |                      |          |          |
|  +-------+-------+  |                      |  +-------+-------+  |
|  |      eth0     |  |                      |  |      eth0     |  |
|  +-------+-------+  |                      |  +-------+-------+  |
+----------|----------+                      +----------|----------+
           |                                            |
   +-------+-------+                          +-------+-------+
   |    Switch     |                          |    Switch     |
   +-------+-------+                          +-------+-------+
           |                                            |
           +--------------------+----------------------+
                                |
                     +----------+----------+
                     |    Network Cloud    |
                     +---------------------+
```

```bash
ip link add vx0 type vxlan id 100 local 1.1.1.1 remote 2.2.2.2 dev eth0 dstport 4789
```

### Linux Bridge

Simply put, a bridge is a layer two device that is used to join two (Ethernet) networks together to form a single larger network. Why is this useful? Imagine a business spread across two different sites each with it's own LAN. Without an interconnection between the two networks machines on one LAN couldn't communicate with machines on the other. This can be fixed by installing a bridge between the two sites which will forward packets from one LAN to the other effectively making the two LANs into one large network.

Bridges may or may not learn about the hosts connected to the networks they are bridging. A basic transparent bridge will just pass all packets arriving on it's input port out the output port(s). This strategy is simple but it can be very wasteful and potentially expensive if the bridge link is charged on the amount of data that passes across it. A better solution is to use a learning bridge that will learn the MAC addresses of hosts on each connected network and only put packets on the bridge when the required. Note that in many respects a learning bridge is much like a regular Ethernet switch which is why bridges as a piece of real hardware have all but disappeared.

#### Bridge Utilities

In the modern network switches have largely made bridges obsolete but the concept of the bridge is still very useful in the virtual world. By installing the package "bridge-utils" on any mainstream Linux machine the you get the ability to create virtual bridges with commands such as:

```bash
brctl addbr br0
```

This would create a virtual bridge called "br0". You can then add interfaces to the bridge like this:

```bash
brctl addif br0 eth0
brctl addif br0 eth1
```

This adds two Ethernet ports "eth0" and "eth1" to the bridge. If these are physical ports then this set up has linked the two networks connected to these ports at layer two and packets will flow between them. Linux has built in support for filtering the packets passing across the bridge using the user space tool "ebtables" (Ethernet bridge tables) which is similar to "iptables".

You can see the configuration of virtual bridges using the command:

```bash
brctl show
```

Finally you can remove an interface and delete a bridge like this:

```bash
brctl delif br0 eth0
brctl delbr br0
```

#### iproute2 Bridges

The examples above use the brctl command from the bridge-utils package but that has now been superseded by the newer iproute2 utility which can also create bridges. To create a bridge with iproute2 use the following command:

```bash
ip link add br0 type bridge
ip link show
```

The second show command just displays the link information which you can use to confirm the bridge has been created. To add an interface to the bridge (know as enslaving it) use a command like this:

```bash
ip link set ep1 master br0
```

This adds the interface ep1 to the bridge br0 (the interfaces ep1 and ep2 are just a veth pair). The output of and ip link show command would now look something like this:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
 link/ether 08:00:27:4a:5e:e1 brd ff:ff:ff:ff:ff:ff
4: ep2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
 link/ether fa:d3:ce:c3:da:ad brd ff:ff:ff:ff:ff:ff
5: ep1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master br0 state DOWN mode DEFAULT group default qlen 1000
 link/ether e6:80:a3:19:2c:10 brd ff:ff:ff:ff:ff:ff
6: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
 link/ether e6:80:a3:19:2c:10 brd ff:ff:ff:ff:ff:ff
```

Notice that the ep1 interface shows br0 as it's master. To then remove or release the ep1 interface from the bridge:

```bash
ip link set ep1 nomaster
```

And finally to delete the bridge:

```bash
ip link delete br0
```

### TUN/TAP Devices

Typically a network device in a system, for example eth0, has a physical device associated with it which is used to put packets on the wire. In contrast a TUN or a TAP device is entirely virtual and managed by the kernel. User space applications can interact with TUN and TAP devices as if they were real and behind the scenes the operating system will push or inject the packets into the regular networking stack as required making everything appear as if a real device is being used.

You might wonder why there are two options, surely a network device is a network device and that's the end of the story. That's partially true but TUN and TAP devices aim to solve different problems.

#### TUN Interfaces

TUN devices work at the IP level or layer three level of the network stack and are usually point-to-point connections. A typical use for a TUN device is establishing VPN connections since it gives the VPN software a chance to encrypt the data before it gets put on the wire. Since a TUN device works at layer three it can only accept IP packets and in some cases only IPv4. If you need to run any other protocol over a TUN device you're out of luck. Additionally because TUN devices work at layer three they can't be used in bridges and don't typically support broadcasting

#### TAP Interfaces

TAP devices, in contrast, work at the Ethernet level or layer two and therefore behave very much like a real network adaptor. Since they are running at layer two they can transport any layer three protocol and aren't limited to point-to-point connections. TAP devices can be part of a bridge and are commonly used in virtualization systems to provide virtual network adaptors to multiple guest machines. Since TAP devices work at layer two they will forward broadcast traffic which normally makes them a poor choice for VPN connections as the VPN link is typically much narrower than a LAN network (and usually more expensive).

#### Managing Virtual Interfaces

It really couldn't be simpler to create a virtual interface:

```bash
ip tuntap add name tap0 mode tap
ip link show
```

The above command creates a new TAP interface called tap0 and then shows some information about  the device. You will probably notice that after creating the tap0 device reports that it is in the down state. This is by design and it will come up only when something binds it. The output of the show command will look something like this:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
 link/ether 08:00:27:4a:5e:e1 brd ff:ff:ff:ff:ff:ff
3: tap0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 500
 link/ether 36:2b:9d:5c:92:78 brd ff:ff:ff:ff:ff:ff
```

To remove a TUN/TAP interface just replace "add" in the creation command with "del". Note that you have to specify the mode when deleting, presumably you can create both a tun and a tap interface with the same name.

### veth Pairs

A pair of connected interfaces, commonly known as a veth pair, can be created to act as virtual wiring. Essentially what you are creating is a virtual equivalent of a patch cable. What goes in one end comes out the other. The command to create a veth pair is a little more complicated than some:

```bash
ip link add ep1 type veth peer name ep2
```

This will create a pair of linked interfaces called ep1 and ep2 (ep for Ethernet pair, you probably want to choose more descriptive names). When working with OpenStack, especially on a single box install, it's common to use veth pairs to link together the internal bridges. It is also possible to add IP addresses to the interfaces, for example:

```bash
ip addr add 10.0.0.10 dev ep1
ip addr add 10.0.0.11 dev ep2
```

Now you can use ip address show to check the assignment of IP addresses which will output something like this:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 inet 127.0.0.1/8 scope host lo
 valid_lft forever preferred_lft forever
 inet6 ::1/128 scope host
 valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
 link/ether 08:00:27:4a:5e:e1 brd ff:ff:ff:ff:ff:ff
 inet 192.168.1.141/24 brd 192.168.1.255 scope global eth0
 valid_lft forever preferred_lft forever
 inet6 fe80::a00:27ff:fe4a:5ee1/64 scope link
 valid_lft forever preferred_lft forever
4: ep2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
 link/ether fa:d3:ce:c3:da:ad brd ff:ff:ff:ff:ff:ff
 inet 10.0.0.11/32 scope global ep2
 valid_lft forever preferred_lft forever
5: ep1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
 link/ether e6:80:a3:19:2c:10 brd ff:ff:ff:ff:ff:ff
 inet 10.0.0.10/32 scope global ep1
 valid_lft forever preferred_lft forever
```

Using a couple of parameters on the ping command shows us the veth pair working:

```bash
ping -I 10.0.0.10 -c1 10.0.0.11
PING 10.0.0.11 (10.0.0.11) from 10.0.0.10 : 56(84) bytes of data.
64 bytes from 10.0.0.11: icmp_seq=1 ttl=64 time=0.036 ms
--- 10.0.0.11 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.036/0.036/0.036/0.000 ms
```

The -I parameter specifies the interface that should be used for the ping. In this case the 10.0.0.10 interface what chosen which is a pair with 10.0.0.11 and as you can see the ping is there and back in a flash. Attempting to ping anything external fails since the veth pair is essentially just a patch cable (although ping'ing eth0 works for some reason).

### Others

There exist quite a few other interface types which are not used frequently, such as team device, IPVLAN, MACsec, etc.. Google them directly.

## Related
- [[net_basics]]
- [[net_switching]]
- [[net_openvswitch]]

