---
tags: [network, cheatsheet]
aliases: ["namespace", "veth pair", "linux bridge demo"]
type: cheatsheet
---
# Linux Switching Demo
## Linux Switching with Demo

Switching in software on Linux is one of the important parts when using virtualization technologies like KVM or LXC. Typical hosts do not provide one or more physical adapters for each NIC of a virtual machine in KVM or per container when using LXC. Something else must take the part to interconnect the virtual network interfaces.

The software switching classical tool is the linuxbridge, which is available in the Linux kernel for a long time. The frontend to manage the linuxbridge is brctl. The newer tool is the openvswitch (at http://openvswitch.org/). The main frontend is ovs-vsctl.

### tap interfaces

Linux tap interfaces created with ip tuntap cannot be used to attach network namespaces to linuxbridges or the openvswitch.

### veth pair

The simple solution to connect two network namespaces is the usage of one veth pair:

```text
+-----------------------------------------------------------+
|                     Linux server                          |
|                                                           |
|  +-------------------+        +-------------------+       |
|  |   Namespace ns1   |        |   Namespace ns2   |       |
|  |                   |        |                   |       |
|  |            [tap1] |========| [tap2]            |       |
|  |                   |  veth  |                   |       |
|  |                   |  pair  |                   |       |
|  +-------------------+        +-------------------+       |
|                                                           |
+-----------------------------------------------------------+
```

**The command sequence are as below:**

```bash
# add the namespaces
ip netns add ns1
ip netns add ns2
# create the veth pair
ip link add tap1 type veth peer name tap2
# move the interfaces to the namespaces
ip link set tap1 netns ns1
ip link set tap2 netns ns2
# bring up the links
ip netns exec ns1 ip link set dev tap1 up
ip netns exec ns2 ip link set dev tap2 up
# now assign the ip addresses
```

### linux bridge and veth Pairs

When more than two network namespaces (or KVM or LXC instances) must be connected a switch should be used. Linux offers as one solution the well known linux bridge.

```text
+-------------------------------------------------------------------+
|                         Linux server                              |
|                                                                   |
|  +-------------------+              +-------------------+         |
|  |   Namespace ns1   |              |   Namespace ns2   |         |
|  |                   |              |                   |         |
|  |            [tap1] |======+======| [tap2]            |         |
|  |                   |      |      |                   |         |
|  +-------------------+      |      +-------------------+         |
|                             |                                     |
|                      +------+------+                              |
|                      | br-tap1     |                              |
|                      |             |                              |
|                      |   Linux     |                              |
|                      |   bridge    |                              |
|                      |             |                              |
|                      |     br-tap2 |                              |
|                      +------+------+                              |
|                             |                                     |
|  +-------------------+      |      +-------------------+         |
|  |   Namespace ns1   |      |      |   Namespace ns2   |         |
|  |                   |======+======|                   |         |
|  +-------------------+              +-------------------+         |
|       (Veth pair)                      (Veth pair)                |
+-------------------------------------------------------------------+
```

**The commands to create this setup are:**

```bash
# add the namespaces
ip netns add ns1
ip netns add ns2
# create the switch
BRIDGE=br-test
brctl addbr $BRIDGE
brctl stp   $BRIDGE off
ip link set dev $BRIDGE up
#
#### PORT 1
# create a port pair
ip link add tap1 type veth peer name br-tap1
# attach one side to linuxbridge
brctl addif br-test br-tap1
# attach the other side to namespace
ip link set tap1 netns ns1
# set the ports to up
ip netns exec ns1 ip link set dev tap1 up
ip link set dev br-tap1 up
#
#### PORT 2
# create a port pair
ip link add tap2 type veth peer name br-tap2
# attach one side to linuxbridge
brctl addif br-test br-tap2
# attach the other side to namespace
ip link set tap2 netns ns2
# set the ports to up
ip netns exec ns2 ip link set dev tap2 up
ip link set dev br-tap2 up
#
```

### openvswitch and two veth pairs

Another solution is to use the openvswitch instead of the "old" linuxbrige. The configuration is nearly the same as for the linuxbridge.

```text
+-------------------------------------------------------------------+
|                         Linux server                              |
|                                                                   |
|  +-------------------+              +-------------------+         |
|  |   Namespace ns1   |              |   Namespace ns2   |         |
|  |                   |              |                   |         |
|  |            [tap1] |======+======| [tap2]            |         |
|  |                   |      |      |                   |         |
|  +-------------------+      |      +-------------------+         |
|                             |                                     |
|                      +------+------+                              |
|                      | ovs-tap1    |                              |
|  +-------------------+|             |+-------------------+         |
|  |   Namespace ns1   ||   Open      ||   Namespace ns2   |         |
|  |                   ||   vSwitch   |                   |         |
|  +-------------------+|             |+-------------------+         |
|                      |     ovs-tap2|                              |
|                      +------+------+                              |
|                             |                                     |
|  +-------------------+      |      +-------------------+         |
|  |   Namespace ns1   |      |      |   Namespace ns2   |         |
|  |                   |======+======|                   |         |
|  +-------------------+              +-------------------+         |
|       (Veth pair)                      (Veth pair)                |
+-------------------------------------------------------------------+
```

**The commands to create this setup are:**

```bash
# add the namespaces
ip netns add ns1
ip netns add ns2
# create the switch
BRIDGE=ovs-test
ovs-vsctl add-br $BRIDGE
#
#### PORT 1
# create a port pair
ip link add tap1 type veth peer name ovs-tap1
# attach one side to ovs
ovs-vsctl add-port $BRIDGE ovs-tap1
# attach the other side to namespace
ip link set tap1 netns ns1
# set the ports to up
ip netns exec ns1 ip link set dev tap1 up
ip link set dev ovs-tap1 up
#
#### PORT 2
# create a port pair
ip link add tap2 type veth peer name ovs-tap2
# attach one side to ovs
ovs-vsctl add-port $BRIDGE ovs-tap2
# attach the other side to namespace
ip link set tap2 netns ns2
# set the ports to up
ip netns exec ns2 ip link set dev tap2 up
ip link set dev ovs-tap2 up
#
```

### openvswitch and two openvswitch ports

Another solution is to use the openvswitch and make use of the openvswitch internal ports. This avoids the usage of the veth pairs, which must be used in all other solutions.

```text
+-------------------------------------------------------------------+
|                         Linux server                              |
|                                                                   |
|  +-------------------+              +-------------------+         |
|  |   Namespace ns1   |              |   Namespace ns2   |         |
|  |                   |              |                   |         |
|  |            [tap1] |==============| [tap2]            |         |
|  |                   |   Open       |                   |         |
|  +-------------------+   vSwitch    +-------------------+         |
|         (Ovs port)          |          (Ovs port)                 |
|                             |                                     |
|                      +------+------+                              |
|                      |   Open      |                              |
|                      |   vSwitch   |                              |
|                      +-------------+                              |
+-------------------------------------------------------------------+
```

**The commands to create this setup are:**

```bash
# add the namespaces
ip netns add ns1
ip netns add ns2
# create the switch
BRIDGE=ovs-test
ovs-vsctl add-br $BRIDGE
#
#### PORT 1
# create an internal ovs port
ovs-vsctl add-port $BRIDGE tap1 -- set Interface tap1 type=internal
# attach it to namespace
ip link set tap1 netns ns1
# set the ports to up
ip netns exec ns1 ip link set dev tap1 up
#
#### PORT 2
# create an internal ovs port
ovs-vsctl add-port $BRIDGE tap2 -- set Interface tap2 type=internal
# attach it to namespace
ip link set tap2 netns ns2
# set the ports to up
ip netns exec ns2 ip link set dev tap2 up
```

**Notes**: OVS internal port can be used to refer to the Open vSwitch itself, in other words, an IP can be assigned to it. With this feature, the host could still be accessible from outside even if all physical port are added to OVS bridge. For example, we can create an internal port(VLAN configured) and assign an IP for it, then we can access the host from outside within the same VLAN:

```bash
ovs-vsctl add-port br0 vlan1000 -- set Interface vlan1000 type=internal
ovs-vsctl set port vlan1000 tag=1000
ip addr add 192.168.10.10/24 dev vlan1000
ifup vlan1000
```

### Connect 2 x Open vSwitch

To connect 2 x Open vSwitch together, we need to use patch port:

```text
+-------------------+         +-------------------+
|   Open vSwitch 1  |         |   Open vSwitch 2  |
|                   |         |                   |
|  +-------------+  |         |  +-------------+  |
|  | port:       |  |         |  | port:       |  |
|  | "patch-     |==+=========+==| "patch-     |  |
|  | ovs-1"      |  |         |  | ovs-2"      |  |
|  | peer:       |  |         |  | peer:       |  |
|  | "patch-     |  |         |  | "patch-     |  |
|  | ovs-2"      |  |         |  | ovs-1"      |  |
|  +-------------+  |         |  +-------------+  |
+-------------------+         +-------------------+
```

```bash
ovs-vsctl add-port ovs1 patch-ovs-1
ovs-vsctl set interface patch-ovs-1 type=patch
ovs-vsctl set interface patch-ovs-1 options:peer=patch-ovs-2

ovs-vsctl add-port ovs1 patch-ovs-2
ovs-vsctl set interface patch-ovs-2 type=patch
ovs-vsctl set interface patch-ovs-2 options:peer=patch-ovs-1
```

## Related
- [[net_devices]]
- [[net_openvswitch]]

