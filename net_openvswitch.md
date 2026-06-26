---
tags: [network, cheatsheet, ovs]
aliases: ["ovs", "openvswitch", "open vswitch"]
type: cheatsheet
---
# Open vSwitch
## Open vSwitch Commands Cheatsheet

### Overview

The Open vSwitch Database Management Protocol (OVSDB) is an OpenFlow configuration protocol that is designed to manage Open vSwitch implementations. It is used to perform management and configuration operations on OVS instances(OVSDB does not perform per-flow operations, leaving those instead to OpenFlow).

Below is the diagram showing the main components and interfaces of OVS(refer to https://tools.ietf.org/id/draft-pfaff-ovsdb-proto-02.html):

```text
+--------------------------+
|  Control & Management    |
|        Cluster           |
+-----------+--------------+
            | \
            |  \ OpenFlow
            |   \
     OVSDB  |    \
     Mgmt   |     \
            |      \
+-----------+-------+-----------------------------------+
|           |       |                                   |
|  +--------+---+   |   +----------------+              |
|  |ovsdb-server|   |   | ovs-vswitchd   |              |
|  +------------+   |   +--------+-------+              |
|                   |            |                      |
|                   |   +--------+--------+             |
|                   |   |  Forwarding     |             |
|                   |   |     Path        |             |
|                   |   +-----------------+             |
|                   |                                   |
+-------------------------------------------------------+
```

Actually, configuring an OVS instance is similar as operating a database - once the tables, records, and columns are identified, changes can be made easily.

- Tables: man ovs-vsctl -> locate "Identifying Tables, Records, and Columns"
- Commands: man ovs-vsctl -> locate "Database Command Syntax"

#### Samples

Target: Change the vlan of a port.

Steps:

1. man ovs-vsctl -> locate "Identifying Tables, Records, and Columns" -> Find table name "Port";
2. man ovs-vsctl -> locate "Database Command Syntax" -> Find "list" command;
3. Query the details of the port as below:

   ```bash
   # ovs-vsctl list Port vlan305
   ...
   name                : "vlan305"
   tag                 : 305
   trunks              : []
   vlan_mode           : []
   ...
   ```

4. man ovs-vsctl -> locate "Database Command Syntax" -> Find "set" command;
5. Perform the change:

   ```bash
   # table: Port
   # record: vlan305
   # column: tag
   # ovs-vsctl set Port vlan305 tag=310
   ```

### VLAN

Notes: OVS port are in trunk mode by default and all VLANs are allowed.

- Add: ovs-vsctl set port vnet0 tag=100
- Remove: ovs-vsctl remove port vnet0 tag 100
- Trunk: ovs-vsctl set port vnet0 trunks=20,30,40
- Native VLAN: ovs-vsctl set port vnet0 vlan_mode=native-untagged

### Spanning Tree

- Query: ovs-vsctl get bridge \<bridge name\> stp_enable
- Enable: ovs-vsctl set bridge \<bridge name\> stp_enable=true
- Disable: ovs-vsctl set bridge \<bridge name\> stp_enable=false
- Set priority: ovs-vsctl set bridge br0 other_config:stp-priority=0x7800
- Set cost: ovs-vsctl set port eth0 other_config:stp-path-cost=10

### Bridge

- Add: ovs-vsctl add-br br0
- Remove: ovs-vsctl del-br br0
- List: ovs-vsctl list-br
- Set: ovs-vsctl set bridge br0 other-config:disable-in-band=true

### Port

- Add: ovs-vsctl add-port br0 port1
- Remove: ovs-vsctl del-port port1
- List: ovs-vsctl list-ports br0

## Related
- [[net_switching]]
- [[net_devices]]

