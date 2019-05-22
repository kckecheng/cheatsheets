.. contents:: Switch Tips

==================
Brocade SAN Switch
==================

Get Help
--------

- help <-p> : Print help info for a command
- h : Command history
- Zonehelp : Show all zone config related commands

Output Processing
-----------------

- Divide output: command | more
- Filter output: command | more, then press '/' to search or command | grep string

Show Information
----------------

===========  =============================================================
Command      Description
-----------  -------------------------------------------------------------
switchshow   show switch and port status
cfgactvshow  Show working/active Fabric configuration set
cfgshow      show all defined&enabled zones&Alias&etc
fabricshow   show switches in a fabric, principle switch will be displayed
supportshow  show all diagnostic info
configshow   show all configurations on the switch
zoneshow     show all defined zones
nscamshow    show all wwn in the whole fabric
chassisshow  show SN and uptime
version      show FOS version
===========  =============================================================

Zoning
------

- alishow
- alicreate
- zonecreate/zonedelete
- zoneadd/zoneremove : Add or remove a memeber such as a alias/wwn into/from a zone
- cfgadd/cfgremove : Add or remove a zone into/from a configuration, or in other words, a zoneset
- cfgsave
- cfgshow | grep "cfg:" : Find Configuration name
- cfgenable <Configuration Name>
- cfgcreate : Create a new zone set, this is not used frequently

Peer Zoning
+++++++++++

One initiator + multiple targets is the best practice of configuing zones. However, it is tedious to configure multiple hosts with the same targets, since an end user needs to creat num. of hosts x zones, which share the identical targets info. User errors is easy to be invovled at the same time.

Peer zoning defines principle and non-principle members for a zone:

  - Principle members cannot communicate with each other;
  - Non-principle members cannot communicate with each other;
  - A principle member can communicate with all non-principle members.

With peer zoning, multiple hosts can be zoned together as one zone with the same targets:

::

   zonecreate --peerzone peerzone_wwn_mbrs -principal "10:00:00:00:01:1e:20:20; 10:00:00:00:01:1e:20:21"
   zoneadd --peerzone peerzone_wwn_mbrs -members "10:00:05:1e:a9:20:00:01; 10:00:05:1e:a9:20:00:02"

Show/Enable/Disable FOS Feature
-------------------------------

::

  SW_5_BR300:cs> fosconfig
  Usage: fosconfig [--enable iscsi | fcr | isnsc | vf | ethsw]
                   [--disable iscsi | fcr | isnsc | vf | ethsw]
                   [--show]
  SW_5_BR300:cs> fosconfig --show
  FC Routing service:             Service not supported on this platform
  iSCSI service:                  Service not supported on this Platform
  iSNS client service:            Service not supported on this Platform
  Virtual Fabric:                 Service not supported on this Platform
  Ethernet Switch Service:        Service not supported on this Platform
  SW_5_BR300:cs>

Virtual Fabrics
---------------

- Definition: http://www.brocade.com/solutions-technology/technology/platforms/fabric-os/virtual_fabrics.page
- Commands

  ======================================  ===============================================
  Commands                                Descriptions
  --------------------------------------  -----------------------------------------------
  fosconfig --enable vf                   Enable virtual fabrics; A reboot is required.
  lscfg --create                          Create a logical/virtual switch
  lscfg --show                            Show virtual fabrics and ports assignment
  setcontext                              Begin to configure the logical/virtual switch
  lscfg --config -port                    Add physical port to the logical/virtual switch
  switchdisable; configure; switchenable  Set domain ID, etc.
  ======================================  ===============================================

- Examples:

  ::

    1. Check if VF is enabled:
    Brocade-DCX4s-FCoE:FID128:admin> fosconfig --show
    FC Routing service:             enabled
    iSCSI service:                  Service not supported on this Platform
    iSNS client service:            Service not supported on this Platform
    Virtual Fabric:                 enabled
    Ethernet Switch Service:        enabled

    2. Show VSAN:
    Brocade-DCX4s-FCoE:FID128:admin> lscfg --show

    Created switches:  128(ds)  10  2  20  40
    Slot      1     2     3     4     5     6     7     8
    -------------------------------------------------------
    Port
     0    | 128 |  20 | 128 |     |     | 128 | 128 |     |
     1    | 128 |  20 | 128 |     |     | 128 | 128 |     |
     2    | 128 |  20 | 128 |     |     | 128 | 128 |     |
     3    | 128 |  20 | 128 |     |     | 128 | 128 |     |
     4    | 128 | 128 | 128 |     |     | 128 | 128 |     |
     5    | 128 | 128 | 128 |     |     | 128 | 128 |     |
     6    | 128 | 128 | 128 |     |     | 128 | 128 |     |

    3. Show Default Switch(ds):
    Brocade-DCX4s-FCoE:FID128:admin> switchshow
    switchName:     Brocade-DCX4s-FCoE
    switchType:     77.3
    switchState:    Online
    switchMode:     Native
    switchRole:     Principal
    switchDomain:   3
    switchId:       fffc03
    switchWwn:      10:00:00:05:1e:ac:4b:00
    zoning:         OFF
    switchBeacon:   OFF
    FC Router:      OFF
    Fabric Name:    defFab
    Allow XISL Use: OFF
    LS Attributes:  [FID: 128, Base Switch: No, Default Switch: Yes, Address Mode 0]

    Index Slot Port Address Media  Speed  State       Proto
    =======================================================
       0    1    0   030000   id     N8   No_Light    FC
       1    1    1   030100   id     AN   No_Sync     FC
       2    1    2   030200   id     N8   No_Light    FC
       3    1    3   030300   id     N8   No_Light    FC

    4. Change to other VSAN:
    Brocade-DCX4s-FCoE:FID128:admin> setcontext 20
    DCX4S_94_sw_20:FID20:admin> switchshow
    switchName:     DCX4S_94_sw_20
    switchType:     77.3
    switchState:    Online
    switchMode:     Native
    switchRole:     Principal
    switchDomain:   94
    switchId:       fffc5e
    switchWwn:      10:00:00:05:1e:ac:4b:03
    zoning:         ON (Toro_fid20)
    switchBeacon:   OFF
    FC Router:      OFF
    Allow XISL Use: OFF
    LS Attributes:  [FID: 20, Base Switch: No, Default Switch: No, Address Mode 0]

    Index Slot Port Address Media  Speed  State       Proto
    =======================================================
      64    2    0   5eefc0   id     N8   Online      FC  E-Port  10:00:00:05:1e:b2:be:f6 "brocade8Gb" (downstream)(Trunk master)
      65    2    1   5e0000   id     N8   Online      FC  E-Port  10:00:00:05:1e:b2:bf:e5 "brocade8Gb" (downstream)(Trunk master)

Identify FC Switch port a HBA port is attached to
-------------------------------------------------

::

  1. Find  node information:
  CDI1-SW1_DCX8510-4:FID98:admin> nodefind 50:06:01:6b:3b:64:04:1e
  Remote:
      Type Pid    COS     PortName                NodeName
      N    341101;      3;50:06:01:6b:3b:64:04:1e;50:06:01:60:bb:60:04:1e; ===> 34 here is switch ID of the FC switch; 11 is the switch port num. in hex
          FC4s: FCP
          Fabric Port Name: 20:11:00:05:1e:d8:fd:80
          Permanent Port Name: 20:11:00:05:1e:d8:fd:80
          Device type: NPIV Unknown(initiator/target)
          Port Index: 17
          Share Area: No
          Device Shared in Other AD: No
          Redirect: No
          Partial: No
      Aliases:

  2. Find the switch
  CDI1-SW1_DCX8510-4:FID98:admin> fabricshow
  Switch ID   Worldwide Name           Enet IP Addr    FC IP Addr      Name
  -------------------------------------------------------------------------
   25: fffc19 10:00:00:05:1e:f5:4d:78 10.103.116.18   0.0.0.0         "SGI21-SW8_18_DS5100"
   30: fffc1e 10:00:00:05:33:6a:94:1e 10.103.116.23   0.0.0.0         "SGI21-SW12_23_BR6510"
   46: fffc2e 10:00:00:05:33:59:31:00 10.103.116.46   0.0.0.0         "CDI1-SW1_DCX8510-4"
   49: fffc31 10:00:00:27:f8:85:c5:33 10.103.116.49   0.0.0.0         "SGI17-SW7_49_BR6520B"
   50: fffc32 10:00:00:27:f8:84:21:70 10.103.116.50   0.0.0.0         "SGI17-SW8_50_BR6520B"
   52: fffc34 10:00:00:05:1e:d8:fd:80 10.103.116.20   0.0.0.0         "SGI17-SW5_20_BR8000" ====> This switch is the one our HBA port is attached to(port 17)

Identify who is using a WWN
---------------------------

::

  CDI1-SW1_DCX8510-4:FID98:admin> nszonemember 50:06:01:6e:3b:60:04:1e
  No local zoned members

  7 remote zoned members:

      Type Pid    COS     PortName                NodeName
      N    160100;      3;50:06:01:6e:3b:60:04:1e;50:06:01:60:bb:60:04:1e; ===> A zone defined in the fabric contains this WWN and our WWN above
          FC4s: FCP
          PortSymb: [28] "DGC     LUNZ            0430"
          Fabric Port Name: 20:01:00:05:1e:c7:ca:23
          Permanent Port Name: 50:06:01:6e:3b:60:04:1e
          Device type: Physical Initiator+Target
          Port Index: 1
          Share Area: No
          Device Shared in Other AD: No
          Redirect: No
          Partial: No
                    …...

Identify all WWN login a port(NPIV)
-----------------------------------

::

  SW_1_B7600:admin> portloginshow 0/0
  Type  PID     World Wide Name        credit df_sz cos
  =====================================================
    fe  020000 10:00:00:00:c9:60:94:3e    16  2048   c  scr=3
    ff  020000  10:00:00:00:c9:60:94:3e    12  2048   c  d_id=FFFFFA
    ff  020000  10:00:00:00:c9:60:94:3e    12  2048   c  d_id=FFFFFC

Show Commands History
---------------------

clihistory

Show running Transaction
------------------------

::

  SW_3_B7600:admin> cfgtransshow
  Current transaction token is 0x4814
  It is abortable

nsshow
------

Similar to nscamshow, but only show local information

Configure ISL
-------------

1. Make sure the ports used for ISL at each side belong to the same FID
2. Check available domain ID(the swtich used as upstream does not need to change its domain id, the downstrem switch need to change its domain id to avoid conflict)
3. From the downstrem switch:

   1. switchdisable
   2. configure ---> Only change the domain id is enough, leave all options untouched
   3. switchenable

Brocade Zone Conflict
---------------------

1. SSH into the switch you are adding, and press Enter.
2. Login, enter your userid and password, disable the switch with the switchdisable command.
3. Disable the active configuration using cfgdisable, for example, cfgdisable “CFG1 ”.
4. Issue the cfgclear command to clear all zoning information.
5. Issue the cfgsave command to save the changes.
6. Issue the switchenable command to enable the switch.

Brocade 8000
------------

Ethernet Configuration
++++++++++++++++++++++

::

  WIN182074_BR8000_PLATFORM_40:user_platform>
  WIN182074_BR8000_PLATFORM_40:user_platform> cmsh ------> Enter Ethernet configuration mode
  brocade_8k_247#show ip interface brief
  Interface                 IP-Address      Status                Protocol
  =========                 ==========      ======                ========
  TenGigabitEthernet 0/0    unassigned      up                     up
  TenGigabitEthernet 0/1    unassigned      up                     up
  TenGigabitEthernet 0/2    unassigned      up                     up
  …...

Show FCoE Login
+++++++++++++++

::

  LIN104140_BR8000_PLATFORM_40:user_platform> fcoe --loginshow
  ================================================================================
  Port   Te port        Device WWN             Device MAC        Session MAC
  ================================================================================
  10     Te 0/2    10:00:00:90:fa:43:fc:d7  00:90:fa:43:fc:d7  0e:fc:00:8c:0a:01
  11     Te 0/3    10:00:00:90:fa:43:fc:d6  00:90:fa:43:fc:d6  0e:fc:00:8c:0b:01
  12     Te 0/4    21:00:00:0e:1e:15:91:41  00:0e:1e:15:91:49  0e:fc:00:8c:0c:01
  13     Te 0/5    21:00:00:0e:1e:15:91:40  00:0e:1e:15:91:41  0e:fc:00:8c:0d:01
  14     Te 0/6    21:00:00:c0:dd:10:26:4d  00:c0:dd:10:26:4d  0e:fc:00:8c:0e:01
  15     Te 0/7    21:00:00:c0:dd:10:26:4f  00:c0:dd:10:26:4f  0e:fc:00:8c:0f:01
  17     Te 0/9    10:00:00:00:c9:93:9d:fb  00:00:c9:93:9d:fb  0e:fc:00:8c:11:01
  18     Te 0/10   21:00:00:0e:1e:13:68:d0  00:0e:1e:13:68:d1  0e:fc:00:8c:12:01
  19     Te 0/11   10:00:00:90:fa:a8:ad:fb  00:90:fa:a8:ad:fb  0e:fc:00:8c:13:01
  22     Te 0/14   10:00:00:05:33:26:0c:9b  00:05:33:26:0c:9b  0e:fc:00:8c:16:01
  23     Te 0/15   10:00:00:05:33:26:0c:9a  00:05:33:26:0c:9a  0e:fc:00:8c:17:01
  28     Te 0/20   10:00:00:90:fa:a8:ac:fd  00:90:fa:a8:ac:fd  0e:fc:00:8c:1c:01

========
Cisco FC
========

Create alias
------------

- config
- fcalias name  vsan
- member pwwn
- exit

  = or =

- config
- device-alias database
- device-alias name <Name> pwwn <WWN>
- exit
- device-alias commit
- show run -> Verify

Zoning
------

- config
- zone name  <name > vsan <X>
- member fcalias =or= member device-alias or pwwn <WWPN>
- …...
- exit
- show zone name <name> pending

Smart Zoning
++++++++++++

Smart zoning is the implementation on Cisco similar as Brocade peer zoning.

::

  zone name SmartZone vsan 1
    member pwwn 10:00:00:00:c9:2f:02:db init
    member pwwn 21:00:00:04:cf:db:3e:a7 target
    member pwwn 21:00:00:20:37:15:dc:02 target
    member pwwn 10:00:00:00:c9:2e:ff:d5 init
    member pwwn 21:00:00:e0:8b:02:56:4b init
    member pwwn 21:00:00:e0:8b:03:43:6f init

Commit Zone
-----------

- config
- zone commit vsan <X>
- show zone name <name>

Add/remove memeber into/from a Zoneset
--------------------------------------

- config
- zoneset clone  vsan
   --- Or ---
- zoneset  name <name> vsan <X>
- member <zone name>
- ……
- exit
- show zoneset  pending vsan <X>
- config
- zone commit vsan <X>
- exit
- show zoneset  pending vsan <X>

Active a Zoneset
----------------

- config
- zoneset activate name <Nmae> vsan <X>
- exit
- config
- zone commit vsan <X>
- exit
- show zoneset  pending vsan <X>
- copy running-config startup-config

Show
----

- show flogi database: switcshow similar on Cisco
- show fcns database: nscamshow similar on Cisco
- show zoneset active
- show zone
- show vsan
- show run

VSAN
----

- Reference: http://www.cisco.com/en/US/docs/switches/datacenter/mds9000/sw/4_1/configuration/guides/cli_4_1/vsan.html

Assign a port to a VSAN statically
----------------------------------

::

  lin104014(config)# vsan database
  lin104014(config-vsan-db)# vsan 2140
  lin104014(config-vsan-db)# vsan 2140 interface fc1/21
  Traffic on fc1/21 may be impacted. Do you want to continue? (y/n) [n] y
  lin104014(config-vsan-db)# do show vsan mem

Find uplink switch
------------------

- show topology

  ::

    FC Topology for VSAN 100 :
    --------------------------------------------------------------------------------
           Interface  Peer Domain Peer Interface     Peer IP Address
    --------------------------------------------------------------------------------
               fc1/14  0x25(37)           fc1/25  10.103.116.39
                fc2/1  0x27(39)           fc1/25  10.103.116.37

Search CLI output
-----------------

include <string> next <num. of lines> pre <num. of lines>

::

  CSH1-SW11-39-RP9216i# show fcns database detail | inc 50:06:01:60:bb:60:04:1e next 5 prev 5
  ------------------------
  VSAN:1     FCID:0x2200b5
  ------------------------
  port-wwn (vendor)           :50:06:01:63:3b:64:04:1e (Clariion)
                               [CX_116115_A11]
  node-wwn                    :50:06:01:60:bb:60:04:1e
  class                       :3
  node-ip-addr                :0.0.0.0
  ipa                         :ff ff ff ff ff ff ff ff
  fc4-types:fc4_features      :scsi-fcp:target
  symbolic-port-name          :
  --

Find Array SP Connections on Switch
-----------------------------------

- Find the array WWNN: for VNX and Clariion, this can be gotten from Unisphere "System Information";
- Locate all SP connections for the array:

  ::

    CSH1-SW11-39-RP9216i# show fcns database detail | inc 50:06:01:60:bb:60:04:1e next 10 prev 5 ===> Highlighted string is the array WWNN
    ------------------------
    VSAN:1     FCID:0x2200b5  ===> We will decode this later
    ------------------------
    port-wwn (vendor)           :50:06:01:63:3b:64:04:1e (Clariion)  ===> SPA3 (Decode Clariion/VNX WWPN)
                                 [CX_116115_A11]
    node-wwn                    :50:06:01:60:bb:60:04:1e
    class                       :3
    node-ip-addr                :0.0.0.0
    ipa                         :ff ff ff ff ff ff ff ff
    fc4-types:fc4_features      :scsi-fcp:target
    symbolic-port-name          :
    symbolic-node-name          :
    port-type                   :N
    port-ip-addr                :0.0.0.0
    fabric-port-wwn             :20:08:00:0d:ec:cf:98:bf
    hard-addr                   :0x000000
    --
    ------------------------
    VSAN:1     FCID:0x268900
    ------------------------
    port-wwn (vendor)           :50:06:01:68:3b:60:04:1e (Clariion) ===> SPB0
                                 [CX_116116_B0]
    node-wwn                    :50:06:01:60:bb:60:04:1e
    class                       :3
    node-ip-addr                :0.0.0.0
    ipa                         :ff ff ff ff ff ff ff ff
    fc4-types:fc4_features      :scsi-fcp:both
    symbolic-port-name          :
    symbolic-node-name          :
    port-type                   :N
    port-ip-addr                :0.0.0.0
    fabric-port-wwn             :20:01:00:0d:ec:87:96:80
    hard-addr                   :0x000000
    --
    ------------------------
    VSAN:1     FCID:0x268b00
    ------------------------
    port-wwn (vendor)           :50:06:01:69:3b:60:04:1e (Clariion) ===> SPB1
                                 [CX_116116_B1]
    node-wwn                    :50:06:01:60:bb:60:04:1e
    class                       :3
    node-ip-addr                :0.0.0.0
    ipa                         :ff ff ff ff ff ff ff ff
    fc4-types:fc4_features      :scsi-fcp:both
    symbolic-port-name          :
    symbolic-node-name          :
    port-type                   :N
    port-ip-addr                :0.0.0.0
    fabric-port-wwn             :20:03:00:0d:ec:87:96:80
    hard-addr                   :0x000000
    --
    ------------------------
    VSAN:1     FCID:0x27ca00
    ------------------------
    port-wwn (vendor)           :50:06:01:60:3b:60:04:1e (Clariion) ===> SPA0
                                 [CX_116115_A0]
    node-wwn                    :50:06:01:60:bb:60:04:1e
    class                       :3
    node-ip-addr                :0.0.0.0
    ipa                         :ff ff ff ff ff ff ff ff
    fc4-types:fc4_features      :scsi-fcp:both
    symbolic-port-name          :
    symbolic-node-name          :
    port-type                   :N
    port-ip-addr                :0.0.0.0
    fabric-port-wwn             :20:01:00:0d:ec:85:c9:00
    hard-addr                   :0x000000

- Decode FCID: Domain ID(1 byte) + Area ID(1 byte) + Port ID(1 byte)

  ::

    VSAN:1 FCID: 0x2200b5  - VSAN 1, Domain ID 0x22
    …...
    - Locate Swtich with Domain 0x22
    SGI17-SW2-34-NEX5020# show fcdomain domain-list vsan 1

    Number of domains: 9
    Domain ID              WWN
    ---------    -----------------------
     0x25(37)    20:01:00:0d:ec:87:93:81 [Principal]
    0x7d(125)    20:01:00:0d:ec:2d:be:41
     0x26(38)    20:01:00:0d:ec:87:96:81
     0x27(39)    20:01:00:0d:ec:85:c9:01
     0x23(35)    20:01:00:0d:ec:a2:f5:81
     0x24(36)    20:01:00:0d:ec:b6:99:41
     0x22(34)    20:01:00:0d:ec:cf:98:81 [Local]
     0x28(40)    20:01:00:0d:ec:6f:69:81
     0x21(33)    20:01:00:05:9b:7b:2c:01

- Get the FCID:

  ::

    SGI17-SW2-34-NEX5020# show fcns database domain 34

    VSAN 1:
    --------------------------------------------------------------------------
    FCID        TYPE  PWWN                    (VENDOR)        FC4-TYPE:FEATURE
    --------------------------------------------------------------------------
    0x220097    N     10:00:8c:7c:ff:08:4d:00                 scsi-fcp:init
                      [VMW117174_HBA4]
    0x2200a8    N     10:00:8c:7c:ff:08:32:00                 scsi-fcp:init
                      [WIN116169_HBA4]
    0x2200af    N     10:00:00:00:c9:bb:c9:2b (Emulex)        scsi-fcp:init
                      [WIN116188_HBA4]
    0x2200b1    N     50:00:09:72:08:24:31:1c (EMC)           scsi-fcp:both 253
                      [VMAX_316_8E_P0]
    0x2200b5    N     50:06:01:63:3b:64:04:1e (Clariion)      scsi-fcp:target
                      [CX_116115_A11]

- Show Switch Used:

  ::

    SGI17-SW2-34-NEX5020# show fcns database fcid 0x2200b5 detail vsan 1
    ------------------------
    VSAN:1     FCID:0x2200b5
    ------------------------
    port-wwn (vendor)           :50:06:01:63:3b:64:04:1e (Clariion)
                                 [CX_116115_A11]
    node-wwn                    :50:06:01:60:bb:60:04:1e
    class                       :3
    node-ip-addr                :0.0.0.0
    ipa                         :ff ff ff ff ff ff ff ff
    fc4-types:fc4_features      :scsi-fcp:target
    symbolic-port-name          :
    symbolic-node-name          :
    port-type                   :N
    port-ip-addr                :0.0.0.0
    fabric-port-wwn             :20:08:00:0d:ec:cf:98:bf
    hard-addr                   :0x000000
    permanent-port-wwn (vendor) :50:06:01:63:3b:64:04:1e (Clariion)
    Connected Interface         :vfc9 ===> interface
    Switch Name (IP address)    :SGI17-SW2-34-NEX5020 (10.103.116.34) ===> Switch

NPV and NPIV
------------

- NPV(N-Port Virtualization)(Switch Level) enabled switch acts as a proxy switch;
- NPIV(N-Port ID Virtualization)(Port Level) can assign multiple FID to the node attached to the F-Port;
- NPV switch acts as an hub, it uplink to another switch's NPIV port;
- NPV enabled switch won't hold any Fabric Services(such as login service, name service, etc.), instead, it acts as a proxy(hub) and pass service request to its uplink switch, then uplink switch will provide services to nodes attached to the NPV enabled switch;
- NPV switch works as a node to its uplink switch;
- Through NPV mode, Cisco and Brocade switch can be used together. But compatible mode may need to be configured on the NPV switch;
- NPV mode is called AG mode on Brocade FC switch.

If the target is getting multiple N ports from a HBA/FA login the same FC switch port (such as Dell SC box, which leveraes NPIV), NPIV is enough:

::

  # conf t
  # npiv enable
  # interface fc1/3-4
  # swithport mode F
  # no shutdown

============
Dell Force10
============

Trunk Configuration
-------------------

1. Trunk mode is named "hybrid" port mode:

   ::

     interface TeX/X
     no switchport
     exit
     interface TeX/X
     portmode hybrid
     switchport

2. Allowed VLANs and native VLAN needs to be configured with VLAN interface:

   ::

     interface vlan A1
     tagged TeX/X
     exit
     interface vlan A2
     tagged TeX/X
     exit
     interface vlan A0
     untagged TeX/X

