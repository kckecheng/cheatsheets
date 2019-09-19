.. contents:: VMAX Tips

======
SYMCLI
======

Volume/Device Type
------------------

- STD - standard devices, 2-Way-Mir/RAID-5/RAID-6/etc.
- VDEV - configured for Timefinder/snap
- TDEV - thin device, used for virtual provision
- R1/R2 - for SRDF
- DATA - for virtual provision, store actual data for TDEV
- SAVE - for Timefinder/snap and SRDF/A DSE, store actual data for VDEV/R1/R2
- DRV - dynamice reallocation volumes devices, for symmetrix optimizer and FAST

Volume/Device Type
------------------

- Named LUN in industry;
- Also called Symmetrix device in EMC, an identifier will be assigned to it;
- Enginuity maps a logical volume to physical disks on back-end(hyper-volumes or splits);
- Present to a host through Symmetrix channel diretor port after device masking

Auto Meta
---------

- If you want to create a single regular device larger than the maximum size, Symmetrix will create a metadevice instead when auto meta feature is enabled. If auto meta is disabled (which is by default), creating device fails.
- symconfigure -sid xxx -cmd "set symmetrix auto_meta=ENABLE, min_auto_meta_size=65520, auto_meta_member_size=16380, auto_meta_config=concatenated;" commit

  - min_auto_meta_size: Specifies the size threshold that triggers auto meta creation;
  - auto_meta_member_size: Specifies the default meta member size in cylinders when the auto_meta feature is enabled;

- auto_meta_config: Specifies the default meta config when the auto_meta feature is enabled;

Pool
----

- msnap: contain save devices, used by TimeFinder/Snap;
- mrdf_dse: contain save deivces, used by SRDF/A DSE;
- mthin: contain data devices, used by virtual provisioning.

Provision LUNs to a host - demo
-------------------------------

Get VMAX ID
+++++++++++

::

  # symcfg list
  S Y M M E T R I X
  Mcode    Cache      Num Phys  Num Symm
      SymmID       Attachment  Model     Version  Size (MB)  Devices   Devices
  000xxxxxx815 Local       VMAX-1SE  5875       28672        15      1384

Get unmapped Devices
++++++++++++++++++++

::

  # symdev -sid 815 list -noport
  Symmetrix ID: 000xxxxxx815
  Device Name           Directors                  Device
  --------------------------- ------------- -------------------------------------
                                                                             Cap
  Sym  Physical               SA :P DA :IT  Config        Attribute    Sts   (MB)
  --------------------------- ------------- -------------------------------------
  ......
  03F6 Not Visible            ???:? 07C:DB  BCV           N/Asst'd     RW    9000
  0510 Not Visible            ???:? 07A:C0  2-Way Mir     N/Grp'd      RW    8631
  0511 Not Visible            ???:? 08B:C0  2-Way Mir     N/Grp'd      RW    8631
  0512 Not Visible            ???:? 07A:D7  2-Way Mir     N/Grp'd      RW    8631
  0513 Not Visible            ???:? 08B:D7  2-Way Mir     N/Grp'd      RW    8631
  0514 Not Visible            ???:? 08A:D0  2-Way Mir     N/Grp'd      RW    8631
  051A Not Visible            ???:? 08B:D5  2-Way Mir     N/Grp'd      RW   23732
  051B Not Visible            ???:? 08A:D8  2-Way Mir     N/Grp'd      RW   23732

List a range of Devices
+++++++++++++++++++++++

::

  # symdev -sid 996 list -devs 27:34 -noport

  Symmetrix ID: 000xxxxxx815

          Device Name            Dir                  Device
  ---------------------------- ------- -------------------------------------
                                                                        Cap
  Sym   Physical               SA :P   Config        Attribute    Sts   (MB)
  ---------------------------- ------- -------------------------------------
  00027 Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  00028 Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  00029 Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  0002A Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  0002B Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  0002C Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  0002D Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  0002E Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  0002F Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  00030 Not Visible            ***:*** TDEV          N/Grp'd      RW   10241
  00031 Not Visible            ???:??? TDEV          N/Grp'd      NR    1026
  00032 Not Visible            ***:*** TDEV          N/Grp'd      RW       6
  00033 Not Visible            ***:*** TDEV          N/Grp'd      RW       6
  00034 Not Visible            ***:*** TDEV          N/Grp'd      RW       6

Create and Verify Storage Group
+++++++++++++++++++++++++++++++

::

  # symaccess create -sid 815 -name elcsesx_devs -type storage devs 0510:0514
  # symaccess -sid 815 show elcsesx_devs  -type storage
  Symmetrix ID                : 000xxxxxx815
  Storage Group Name          : elcsesx_devs
  Last update time            : 04:13:06 AM on Fri Jul 19,2013
  Group last update time      : 04:13:06 AM on Fri Jul 19,2013
  Number of Storage Groups : 0
     Storage Group Names      : None
  Devices                  : 0510:0514
  Masking View Names
       {
         None
       }

Get Target Ports
++++++++++++++++

::

  # symcfg list -fa all -port
  Symmetrix ID: 000xxxxxx815 (Local)
  S Y M M E T R I X    F I B R E   D I R E C T O R S
  Dir    Port  WWN               Flags  Max
                                     AVPF   Speed
  FA-7E   0    50000972C00CBD18  X.X.     N/A
      FA-7E   1    50000972C00CBD19  X.X.     N/A
      FA-8E   0    50000972C00CBD1C  X.X.     N/A
      FA-8E   1    50000972C00CBD1D  X.X.     N/A
      FA-7F   0    50000972C00CBD58  X.X.     N/A
      FA-7F   1    50000972C00CBD59  ..X.     N/A
      FA-8F   0    50000972C00CBD5C  X.X.     N/A
      FA-8F   1    50000972C00CBD5D  X.X.     N/A
  Legend:
    Flags:
        (A)CLX Enabled          : X = True, . = False
        (V)olume Set Addressing : X = True, . = False
        (P)oint to Point        : X = True, . = False
        (F)COE Director         : X = True, . = False

Create and Verify Port Group
++++++++++++++++++++++++++++

::

  #  symaccess create -sid 815 -name elcsesx_target  -type port -dirport 7E:0,7E:1,8F:0,8F:1
  # symaccess -sid 815 show elcsesx_target  -type port
  Symmetrix ID          : 000xxxxxx815
  Port Group Name         : elcsesx_target
  Last update time        : 04:22:49 AM on Fri Jul 19,2013
  Director Identification
       {
         FA-7E:0
         FA-7E:1
         FA-8F:0
         FA-8F:1
       }
  Masking View Names
       {
         None
       }

Get host WWPN on FC switch/host
+++++++++++++++++++++++++++++++

::

  [root@elcsesx63 ~]# symaccess discover hba -v
  Symmetrix ID          : 000xxxxxx815
  Device Masking Status : Success
  WWN        : 10000000c997bee8
  ip Address : N/A
  Type       : Fibre
  User Name  : 10000000c997bee8/10000000c997bee8
  WWN        : 10000000c997bee9
  ip Address : N/A
  Type       : Fibre
  User Name  : 10000000c997bee9/10000000c997bee9

Create a initiator WWN File
+++++++++++++++++++++++++++

::

  #touch /tmp/wwns
  #echo wwn:2100001b32084524 > /tmp/wwns
  #echo wwn:2101001b32284524 >> /tmp/wwns

Create and Verify Initiator Port Group
++++++++++++++++++++++++++++++++++++++

::

  # symaccess create -sid 815 -name elcsesx_initports -type initiator -file /tmp/wwns
  # symaccess -sid 815 show elcsesx_initports  -type initiator
  Symmetrix ID          : 000xxxxxx815
  Initiator Group Name    : elcsesx_initports
  Last update time        : 04:39:39 AM on Fri Jul 19,2013
  Group last update time  : 04:39:39 AM on Fri Jul 19,2013
  Host Initiators
       {
         WWN  : 2100001b32084524 [alias: 2100001b32084524/2100001b32084524]
         WWN  : 2101001b32284524 [alias: 2101001b32284524/2101001b32284524]
       }
  Masking View Names
       {
         None
       }
  Parent Initiator Groups
       {
         None
       }

Create and Verify a Masking Veiw
++++++++++++++++++++++++++++++++

::

  # symaccess -sid 815 create view -name elcsesx_view -sg elcsesx_devs -pg elcsesx_target -ig elcsesx_initports
  (Notices: option -lun xxx canbe used together to set the starting LUN - dynamic LUN addressing)
  # symaccess -sid 815 list view
  Symmetrix ID          : 000xxxxxx815
  Masking View Name   Initiator Group     Port Group          Storage Group
  ------------------- ------------------- ------------------- -------------------
  ......
  elcsesx_view        elcsesx_initports   elcsesx_target      elcsesx_devs
  ......

Thin Provisioning
-----------------

1. Find device with the same size

   - DATA devices in a pool should have the same size;
   - symdev -sid xxx list -all -cyl
     - From the output, find devices with the same size from the Cap(capacity) field, say 1150;

2. Create thin devices

   - touch mktdev.cfg
   - echo "create dev count=8, size=1150, config=TDEV, emulation=FBA;" > mktdev.cfg
   - symconfigure -sid xxx -file mktdev.cfg prep -nop ---------------> Perform a check before making the change
   - symconfigure -sid xxx -file mktdev.cfg commit -nop
   - symdev -sid xxx list -tdev -unbound -------------------------------> Display the created thin devices

3. Create data devices

   - touch mkddev.cfg
   - echo "create dev count=8, size=1150, config=2-Way-Mir, emulation=fba, attribute=datadev;" > mkddev.cfg
   - symconfigure -sid xxx -file mkddev.cfg commit -nop
   - symdev -sid xxx list -datadev -nonpooled

4. Create a thin pool

   - symconfigure -sid xxx -cmd "create pool P1 type=thin;" commit -nop

5. Add data devices into a pool

   - symconfigure -sid xxx -cmd "add dev 1A9:1AA to pool P1 type=thin, member_state=ENABLE;" commit -nop
   - symcfg -sid xxx list -pool -thin
   - symcfg -sid xxx show -pool P1 -thin

6. Bind thin devices to a thin pool

   - Symconfigure -sid xxx -cmd "bind tdev 1A1:1A4 to pool P1;" commit -nop
   - symcfg -sid xxx list -tdev
   - symcfg -sid xxx show -pool P1 -thin -detail

7. Pre-allocate space on TDEV(optional)

   - touch alloc.cfg
   - echo "start allocate on tdev 1A1:1A2 start_cyl=0 size=100 MB;" > alloc.cfg
   - symconfigure -sid xxx -f alloc.cfg commit -nop
   - symcfg -sid xxx list -tdev
   - symcfg -sid xxx show -pool P1 -thin -detail

8. Provision thin devices to hosts as normal devices

   - Done

9. Check TDEV info

   - symcfg list -tdev -devs 1180:1182 -sid 316

10. Unbind a thin device

    - symconfigure -sid 815 -cmd 'unbind tdev 02ED from pool elcsesx6263;' -nop commit

11. Remove date devices from a pool

    - symconfigure -sid 815 -cmd 'disable dev 02B2:02B4 in pool elcsesx6263,type=thin;' -nop commit
    - symconfigure -sid 815 -cmd 'remove dev 02B2:02B4 from pool elcsesx6263 type=thin;' -nop commit

12. Remove a thin pool

    - symconfigure -sid 815 -cmd 'delete pool elcsesx6263,type=thin;' -nop commit

Get help
--------

- symcli : show version of the CLI
- symcli -h : get brief online help of the symcli commands
- symcli -v : display all symcli commands and their short descriptions
- symcli -env : env can be set
- symcli -def : env defined for current session

symconfigure examples
---------------------

- Query configuration session

::

  symconfigure -sid xxx query

- Terminate a configuration session

::

  symconfigure -sid xxx abort -session_id

- Execute a command without a command file

::

  symconfigure -sid xxx -cmd "command 1;command 2;" commit

- Create a device

  - Create a RAID 6 device with 6+2 RAID protechtion

    - Create a file and add below command into it

      ::

        create dev cout=4, size=1100, config=RAID-6, emulation=FBA, data_member_cout=6;

    - Create the device

      ::

  symconfigure -sid xxx -file command_file commit

  - Create a virtual device

    - Create a file and add below command into it

      ::

        create dev cout=2, size=1100, emulation=FBA, config=VDEV;

    - Create the device

      ::

        symconfigure -sid xxx -file command_file commit

  - Create RAID1 Devices with one line

    ::

      Symconfigure -sid xxx -cmd "create dev count=3, size=5 GB, config=2-Way-Mir, emulation=FBA;" preview

- Delete a device

  - Create a file and add below command into it

  ::

    delete dev SymDevname[:SymDevName];

  - Commit the command with symconfiure

- Create/dissolve a meta device

  - Create command file: form meta from dev 107, config=concatenated; add dev 108 to meta 107;
  - Dissolve command file: dissolve meta dev 107;

- Reserve/release a device

  - symconfigure -sid xxx -cmd "reserve dev ;" -owner -comment ""
  - symconfigure list -reserved
  - Symconfigure -sid xxx release -reserved_id -nop

MISC Commands
-------------

Add Initiators to an Initiator Group
++++++++++++++++++++++++++++++++++++

::

  #symaccess -sid 815 -name elcsaix127_128_iports  add -type initiator -wwn c0507600781d0008

Add devices to an storage group
+++++++++++++++++++++++++++++++

::

  #symaccess -sid 815 -name elcsaix127_128_sg  -type storage add devs 1E37:1E38

Delete views
++++++++++++

::

  #symaccess -sid 815 delete view -name elcsaix127_view -unmap

Delete storage groups
+++++++++++++++++++++

::

  #symaccess -sid 815 show elcsaix127_devs -type storage
  #symaccess -sid 815 -name elcsaix127_devs -type storage remove devs 0128:0131
  #symaccess -sid 815 -name elcsaix127_devs -type storage delete

Delete port groups
++++++++++++++++++

::

  #symaccess -sid 815 show elcsaix127_tports -type port
  #symaccess -sid 815 -name elcsaix127_tports -type port remove -dirport 7E:1,8F:1
  #symaccess -sid 815 -name elcsaix127_tports -type port delete

Delete initiator groups
+++++++++++++++++++++++

::

  #symaccess -sid 815 show elcsaix127_iports -type initiator
  #symaccess -sid 815 -name elcsaix127_iports -type initiator remove -wwn c0507600781d0008
  ......
  #symaccess -sid 815 -name elcsaix127_iports -type initiator delete

Delete devices
++++++++++++++

For thin devices, they must be freed before deletion:

::

  symdev -sid <sid> -devs <device range> free -all
  symcfg -sid <sid> -i 15 -c <counter> -devs <device range> verify -tdev -[allocating|-deallocating|...]

Then perform the deletion:

::

  symconfigure -sid <sid> -cmd 'delete dev <device range>;' commit

Rename views
++++++++++++

::

  #symaccess -sid 815 rename view -name elcsaix128_view -new_name elcsaix127_128_view

Rename storage group
++++++++++++++++++++

::

  #symaccess -sid 815 rename -name elcsaix128_devs -type storage -new_name elcsaix127_128_devs

Rename port group
+++++++++++++++++

::

  #symaccess -sid 815 rename -name elcsaix128_tports -type port -new_name elcsaix127_128_tports

Rename initiator group
++++++++++++++++++++++

::

  #symaccess -sid 815 rename -name elcsaix128_iports -type initiator -new_name elcsaix127_128_iports

Commands with RecoverPoint
++++++++++++++++++++++++++

::

  #symaccess <options …...> -**rp**

List SG/PG/IPG
++++++++++++++

::

  # symaccess -sid 815 list
  Symmetrix ID          : 000xxxxxx815
  Group Name                          Type
  --------------------------------  ---------
  cswin172_iports                   Initiator
  cswin173_iports                   Initiator
  elcsaix127_128_iports             Initiator
  ......
  elcsesx62_65_tpg                  Port
  elcslin55_tports                  Port
  elcssun103_tports                 Port
  elcssun153_tports                 Port
  ......
  elcslin55_devs                    Storage
  elcslin56_sw31                    Storage
  elcssun103_devs                   Storage
  ......

List host connected/zoned
+++++++++++++++++++++++++

::

  # symcfg list -connections

Get director bit/flag info
++++++++++++++++++++++++++

::

  # symcfg list -fa 7e -p 0
  # symcfg list -fa 7e -p 0 -v

List Directores
+++++++++++++++

- Front-end Fibre

  ::

    # symcfg list -sid 815 -fa all

- Front-end Fibre + SCSI + GIGE

  ::

    # symcfg list -sid 815 -sa all

- List all directors(Front+Back)

  ::

    # symcfg -sid 815 list -dir all
    Symmetrix ID: 000xxxxxx815
    S Y M M E T R I X    D I R E C T O R S
    Ident  Symbolic  Numeric  Slot  Type          Status
    DF-7A     07A       7       7   DISK          Online
      DF-8A     08A       8       8   DISK          Online
      DF-7B     07B      23       7   DISK          Online
      DF-8B     08B      24       8   DISK          Online
      DF-7C     07C      39       7   DISK          Online
      DF-8C     08C      40       8   DISK          Online
      DF-7D     07D      55       7   DISK          Online
      DF-8D     08D      56       8   DISK          Online
      FA-7E     07E      71       7   FibreChannel  Online
      FA-8E     08E      72       8   FibreChannel  Online
      FA-7F     07F      87       7   FibreChannel  Online
      FA-8F     08F      88       8   FibreChannel  Online
      SE-7G     07G     103       7   GigE          Online
      SE-8G     08G     104       8   GigE          Online
      SE-7H     07H     119       7   GigE          Online
      SE-8H     08H     120       8   GigE          Online

List devices summary by type
++++++++++++++++++++++++++++

::

  # symdev list -inventory
  Symmetrix ID: 000xxxxxx815
  Device Config      FBA   CKD3390  CKD3380  AS400  CELERRA
    -----------------   -----  -------  -------  -----  -------
    2-Way Mir             881      N/A      N/A    N/A    N/A
    RAID-5                311      N/A      N/A    N/A    N/A
    RAID-6                 18      N/A      N/A    N/A    N/A
    TDEV                  136      N/A      N/A    N/A    N/A
    BCV                     3      N/A      N/A    N/A    N/A

Show disk details
+++++++++++++++++

::

  # symdisk show 1C:C0

Show Real Time FA Stats
+++++++++++++++++++++++

::

  symstat -sid 535 -type port -dir all -i 5 -c 1

Host Visible VS. All
++++++++++++++++++++

- "sympd list" list devices which are configured/mapped for current host(where SE is installed);
- "syminq" only list devices seen by current host too;
- "symdev list" list all devices on Symmetrix(not restricted on devices seen by this host)
- "symdev list pd" list only devices which can be seen by this host.

Unmap device manually after deleting storage view
+++++++++++++++++++++++++++++++++++++++++++++++++

- After deleting a storage view, masks for devices which are mapped to defined director ports in the port group definition won't be deleted automatically if -unmap is not used;
- symdev -sid xxx not_ready dev xxx;
- symconfigure -sid xxx -cmd 'unmap dev XXX from dir ALL:ALL;' commit

List initiator loggedin
++++++++++++++++++++++++

::

  # symaccess -sid 61 list logins [-dir 1D]

Find RA WWN
+++++++++++

::
  # symcfg -sid 218 list -dir 9h -p 0 -v => Then search WWN

FCOE Port
+++++++++

1. FCOE ports are taken as FC ports, in other words, it will be listed in "symcfg list -fa all" output:

   ::

     # symcfg -sid 162 list -fa all

     Symmetrix ID: 000xxxxxx162 (Local)

              S Y M M E T R I X    D I R E C T O R S

         Ident  Type          Engine  Cores  Ports  Status
         -----  ------------  ------  -----  -----  ------

         FA-1D  FibreChannel     1     11     12    Online
         FA-2D  FibreChannel     1      9     10    Online
         FA-3D  FibreChannel     2      9     10    Online
         FA-4D  FibreChannel     2     11     12    Online
         FE-1G  FibreChannel     1      3      2    Online
         FE-2G  FibreChannel     1      4      2    Online
         FE-3G  FibreChannel     2      4      2    Offline
         FE-4G  FibreChannel     2      3      2    Offline

2. Its wwn and speed can be seens as below:

   ::

     # symcfg -sid 162 list -fa 1g -port

     Symmetrix ID: 000xxxxxx162 (Local)

              S Y M M E T R I X    D I R E C T O R    P O R T S

                                                    Speed
       Ident  Port  WWN               Type          Gb/sec  Status
       -----  ----  ----------------  ------------  ------  -------

       FE-1G     9  5000097350122809  FibreChannel      10  Online
       FE-1G    11  500009735012280B  FibreChannel      10  Online

Disable ACLX on FA port
+++++++++++++++++++++++

(ACLX device (symdev -sid xxx list -aclx) is used for initial symm configuration. By default, it is visible on all hosts. To disable this behavior, follow below commands)

::

  # symconfigure -sid 162 -cmd "unmap dev 0001 from dir ALL:ALL;" commit
  --- OR ---
  # symconfigure -sid 162 -cmd "set port 1D:4 show_aclx_device=DISABLE;" commit

Online Device Expansion
+++++++++++++++++++++++

::

  symdev -sid <sid> modify 1ab -cap 200 -captype gb -tdev
  symdev -sid <sid> modify -devs 1ac:1af -cap 200 -captype gb -tdev

=======
SymmWin
=======

Check Slic Map
--------------

1. File -> IMPL from system
2. Configuration -> Slic Map

========
TF/Clone
========

Clone to Regular Devices
------------------------

::

  # symdg create clonepg -type regular
  # symdg -g clonepg addall -devs 0120:0124
  # symdg show clonepg
  Group Name:  clonepg
  ……
      Standard (STD) Devices (5):
          {
          ----------------------------------------------------------------------------------
                                                        Sym  Device                     Cap
          LdevName              PdevName                Dev  Config        Att. Sts     (MB)
          ----------------------------------------------------------------------------------
          DEV001                N/A                     0120 RAID-5             RW      2063
          DEV002                N/A                     0121 RAID-5             RW      2063
          DEV003                N/A                     0122 RAID-5             RW      2063
          DEV004                N/A                     0123 RAID-5             RW      2063
          DEV005                N/A                     0124 RAID-5             RW      2063
          }
  # symclone -g clonepg create DEV001 sym ld DEV002

  Execute 'Create' operation for device 'DEV001'
  in device group 'clonepg' (y/[n]) ? y

  'Create' operation execution is in progress for device 'DEV001'
  paired with target device 'DEV002' in
  device group 'clonepg'. Please wait...

  'Create' operation successfully executed for device 'DEV001'
  in group 'clonepg' paired with target device 'DEV002'.
  # symclone -g clonepg query DEV001


  Device Group (DG) Name: clonepg
  DG's Type             : REGULAR
  DG's Symmetrix ID     : 000xxxxxx815


           Source Device                   Target Device            State     Copy
  --------------------------------- ---------------------------- ------------ ----
                 Protected Modified                Modified
  Logical   Sym  Tracks    Tracks   Logical   Sym  Tracks   CGDP SRC <=> TGT  (%)
  --------------------------------- ---------------------------- ------------ ----
  DEV001    0120     33000        0 DEV002    0121        0 XXX. Created        0
  ……
  # symdg show clonepg

  Group Name:  clonepg
  ……
      Standard (STD) Devices (5):
          {
          ----------------------------------------------------------------------------------
                                                        Sym  Device                     Cap
          LdevName              PdevName                Dev  Config        Att. Sts     (MB)
          ----------------------------------------------------------------------------------
          DEV001                N/A                     0120 RAID-5             RW      2063
          DEV002                N/A                     0121 RAID-5             NR      2063
          DEV003                N/A                     0122 RAID-5             RW      2063
          DEV004                N/A                     0123 RAID-5             RW      2063
          DEV005                N/A                     0124 RAID-5             RW      2063
          }
  # symclone -g clonepg activate DEV001 symld DEV002 -noprompt
  # symclone -g clonepg terminate DEV001 symld DEV002 -noprompt [-symforce]
  # symdg delete clonepg -force
  # symdev ready 0121 -sid 815

Clone to BCV Devices
--------------------

::

  # symconfigure -sid 316 -cmd "create dev count=2, size=20625 MB, emulation=FBA, config=BCV;" commit
  # symdev list -sid 316 | grep '0E2[89]\|1E3[78]'
  0E28 Not Visible            ***:* 09D:C3  RAID-5        N/Grp'd      RW   20625
  0E29 Not Visible            ***:* 07D:D4  RAID-5        N/Grp'd      RW   20625
  1E37 Not Visible            ???:? 08A:DE  BCV           N/Asst'd     RW   20625
  1E38 Not Visible            ???:? 08A:DE  BCV           N/Asst'd     RW   20625
  # symdg -g clonegp addall -devs 0E28:0E29 -sid 316
  # symbcv -g clonegp associate dev 1E37 -sid 316
  # symbcv -g clonegp associate dev 1E38 -sid 316
  # symdg show clonegp
      Number of STD Devices in Group               :    2
      Number of Associated GK's                    :    0
      Number of Locally-associated BCV's           :    2
      ……
      Standard (STD) Devices (2):
          {
          ----------------------------------------------------------------------------------
                                                        Sym  Device                     Cap
          LdevName              PdevName                Dev  Config        Att. Sts     (MB)
          ----------------------------------------------------------------------------------
          DEV001                N/A                     0E28 RAID-5             RW     20625
          DEV002                N/A                     0E29 RAID-5             RW     20625
          }

      BCV Devices Locally-associated (2):
          {
          ----------------------------------------------------------------------------------
                                                        Sym  Device                     Cap
          LdevName              PdevName                Dev  Config        Att. Sts     (MB)
          ----------------------------------------------------------------------------------
          BCV001                N/A                     1E37 BCV                RW     20625
          BCV002                N/A                     1E38 BCV                RW     20625
          }

  # symclone -g clonegp query

  The Source device and the Target device do not form a Copy session

  Device group 'clonegp' does not have any devices that are Clone source devices

  #symclone -g clonegp create [-precopy] -v -nop

  'Create' operation execution is in progress for device group 'clonegp'. Please wait...


  SELECTING Source devices in the group:

    Device: 0E28 [SELECTED]
    Device: 0E29 [SELECTED]

  SELECTING Target devices in the group:

    Device: 1E37 [SELECTED]
    Device: 1E38 [SELECTED]

  PAIRING of Source and Target devices:

    Devices: 0E28(S) - 1E37(T) [PAIRED]
    Devices: 0E29(S) - 1E38(T) [PAIRED]

  STARTING a Clone 'CREATE' operation.

  The Clone 'CREATE' operation SUCCEEDED.

  'Create' operation successfully executed for device group 'clonegp'.

  #symclone -g clonegp query


  Device Group (DG) Name: clonegp
  DG's Type             : ANY
  DG's Symmetrix ID     : 000xxxxxx316


           Source Device                   Target Device            State     Copy
  --------------------------------- ---------------------------- ------------ ----
                 Protected Modified                Modified
  Logical   Sym  Tracks    Tracks   Logical   Sym  Tracks   CGDP SRC <=> TGT  (%)
  --------------------------------- ---------------------------- ------------ ----
  DEV001    0E28    330000        0 BCV001    1E37        0 XXX. Created        0
  DEV002    0E29    330000        0 BCV002    1E38        0 XXX. Created        0

  Total           -------- --------                --------
    Track(s)        660000        0                       0
    MB(s)          41250.0      0.0                     0.0

  # symclone -g clonegp activate

  Execute 'Activate' operation for device group
  'clonegp' (y/[n]) ? y

  'Activate' operation execution is in progress for
  device group 'clonegp'. Please wait...

  'Activate' operation successfully executed for device group
  'clonegp'.

  #symclone -g clonegp query


  Device Group (DG) Name: clonegp
  DG's Type             : ANY
  DG's Symmetrix ID     : 000xxxxxx316


           Source Device                   Target Device            State     Copy
  --------------------------------- ---------------------------- ------------ ----
                 Protected Modified                Modified
  Logical   Sym  Tracks    Tracks   Logical   Sym  Tracks   CGDP SRC <=> TGT  (%)
  --------------------------------- ---------------------------- ------------ ----
  DEV001    0E28    198821        0 BCV001    1E37        0 XXX. CopyInProg    39
  DEV002    0E29    191705        0 BCV002    1E38        0 XXX. CopyInProg    41

  Total           -------- --------                --------
    Track(s)        390526        0                       0
    MB(s)          24407.9      0.0                     0.0

  # symclone -g clonegp terminate

  Execute 'Terminate' operation for device group
  'clonegp' (y/[n]) ? y

  'Terminate' operation execution is in progress for
  device group 'clonegp'. Please wait...

  'Terminate' operation successfully executed for device group
  'clonegp'.

====================
Open Replicator Demo
====================

1. 2 x Arrays, one of them must be VMAX/DMX who provides Open replicator software. Open replicator is also referred to as ORS(open replicator for symmetrix);
2. VMAX 098 as control, VMAX 316 as remote:

::

  [team1@Redhatse ~]$ symcfg list

                                  S Y M M E T R I X

                                         Mcode    Cache      Num Phys  Num Symm
      SymmID       Attachment  Model     Version  Size (MB)  Devices   Devices

      000xxxxxx302 Local       DMX3-24   5772       32768         3      2676
      000xxxxxx963 Local       DMX4-6    5773       32768         3      5327
      000xxxxxx316 Local       VMAX-1    5875       24576         3      8711
      000xxxxxx098 Local       VMAX-1SE  5876       28672         3      2908
      000xxxxxx606 Local       DMX3-24   5773       98304         3      2927
      000xxxxxx218 Remote      VMAX-1    5876       24576         0      3591

3. Devices for the replication:

::

  [team1@Redhatse ~]$ symdev list -range 0B59:0B5B -sid 098

  Symmetrix ID: 000xxxxxx098

          Device Name           Directors                  Device
  --------------------------- ------------- -------------------------------------
                                                                             Cap
  Sym  Physical               SA :P DA :IT  Config        Attribute    Sts   (MB)
  --------------------------- ------------- -------------------------------------

  0B59 Not Visible            07H:0 07A:CE  2-Way Mir     N/Grp'd      RW    5121
  0B5A Not Visible            07H:0 07D:DC  2-Way Mir     N/Grp'd      RW    5121
  0B5B Not Visible            07H:0 07B:CD  2-Way Mir     N/Grp'd      RW    5121

  [team1@Redhatse ~]$ symdev list -range 1E37:1E39 -sid 316

  Symmetrix ID: 000xxxxxx316

          Device Name           Directors                  Device
  --------------------------- ------------- -------------------------------------
                                                                             Cap
  Sym  Physical               SA :P DA :IT  Config        Attribute    Sts   (MB)
  --------------------------- ------------- -------------------------------------

  1E37 Not Visible            ***:* 07D:D0  2-Way Mir     N/Grp'd      RW    5121
  1E38 Not Visible            ***:* 10B:C0  2-Way Mir     N/Grp'd      RW    5121
  1E39 Not Visible            ***:* 08A:D0  2-Way Mir     N/Grp'd      RW    5121

4. Assume: hosts are accessing 316 devices through 7H:0 on VMAX 316, we want to hot pull data with donor update option on to VMAX 098;
5. Create a zone: a director FA port from VMAX 098(say 7H:0) + a director FA port from VMAX 316(say 7H:0 too) + host HBA WWNs to VMAX 316 7H:0
6. Prepare storage view on both VMAX 098 and VMAX 316:

   - VMAX 098 storage view:

     - Storage group: 0B59:0B5B;
     - Initiator group: nothing;
     - Port group: 7H:0;

   - VMAX 316:

     - Storage group: 1E37:1E39;
     - Initiator group: 7H:0 WWN of VMAX 098 + host HBA WWNs;
     - Port group: 7H:0;

7. Verify array connection:

::

  team1@Redhatse ~]$ symsan -sid 098 list -sanports -dir 7h -p 0

  Symmetrix ID: 000xxxxxx098

        Flags                                Num
  DIR:P   I   Vendor        Array            LUNs Remote Port WWN
  ----- ----- ------------- ---------------- ---- --------------------------------
  07H:0   .   EMC Symmetrix 000xxxxxx316        3 50000972082431D8

  Legend:
   Flags: (I)ncomplete : X = record is incomplete, . = record is complete.

8. Get WWNs for 1E37:1E39:

::

  [team1@Redhatse ~]$ symsan -sid 098 list -sanluns -wwn 50000972082431D8 -dir 7H -p 0

  Symmetrix ID:      000xxxxxx098
  Remote Port WWN:   50000972082431D8

        ST
         A
         T  Flags  Block   Capacity   LUN   Dev  LUN
  DIR:P  E ICRTHS  Size      (MB)     Num   Num  WWN
  ----- -- ------- ----- ----------- ----- ----- --------------------------------
  07H:0 RW ...F.X    512        5121     1  1E37 60000970000xxxxxx316533031453337
  07H:0 RW ...F.X    512        5121     2  1E38 60000970000xxxxxx316533031453338
  07H:0 RW ...F.X    512        5121     3  1E39 60000970000xxxxxx316533031453339

9. Create a mapping file for open replicator:

::

  [team1@Redhatse ~]$ cat KC_098_316_hotpull_wwn.txt
  Symdev=000xxxxxx098:0B59 wwn=60000970000xxxxxx316533031453337
  Symdev=000xxxxxx098:0B5A wwn=60000970000xxxxxx316533031453338
  Symdev=000xxxxxx098:0B5B wwn=60000970000xxxxxx316533031453339

10. Now, everything is fine. We should power off the host which access 1E37:1E39 on VMAX 316 or delete WWNs of the host from the initiator group of the storage view defined in step 6 since host write to remote devices should be avoided per open replicator document;
11. Create an open replicator session and active it:

::

  [team1@Redhatse ~]$  symrcopy -f KC_098_316_hotpull_wwn.txt create -copy -hot -pull \
    -donor_update -name KC_hotpull_1
  [team1@Redhatse ~]$  symrcopy -f KC_098_316_hotpull_wwn.txt activate

12. Check the open replicator copy progress:

::

  [team1@Redhatse ~]$ symrcopy -f KC_098_316_hotpull_wwn.txt query

  Device File Name      : KC_098_316_hotpull_wwn.txt

         Control Device                  Remote Device              Flags      Status     Done
  ---------------------------- ----------------------------------- ------- -------------- ----
                     Protected
  SID:symdev         Tracks    Identification                   RI CDSHUTZ  CTL <=> REM    (%)
  ------------------ --------- -------------------------------- -- ------- -------------- ----
  000xxxxxx098:0B59          0 000xxxxxx316:1E37                SD X..XXS. Copied          100
  000xxxxxx098:0B5A          0 000xxxxxx316:1E38                SD X..XXS. Copied          100
  000xxxxxx098:0B5B          0 000xxxxxx316:1E39                SD X..XXS. Copied          100

13. Now, host access can be restored at VMAX 098. We should add WWNs of the host from the initiator group of the storage view defined in step 6 for VMAX 098 and delete them from VMAX 316;
14. Terminate it:

::

  [team1@Redhatse ~]$ symrcopy -f KC_098_316_hotpull_wwn.txt terminate -force

15. Done.

====
SRDF
====

Demo
----

1. Identify Array Connections

::

  # symcfg list -ra all -sid 098 [-switched]

  Symmetrix ID: 000xxxxxx098

                   S Y M M E T R I X    R D F    D I R E C T O R S


                                                                      Remote        Local    Remote
  Ident  Symb  Num  Slot  Type       Attr  SymmID        RA Grp   RA Grp  Status

  RF-8H   08H  120     8  RDF-R2       -   000xxxxxx218 101 (64) 101 (64) Online
                                       -   000xxxxxx218 102 (65) 102 (65)
                                       -   000xxxxxx218 105 (68) 105 (68)
                                       -   000xxxxxx218 109 (6C) 109 (6C)
  …...
  # symcfg list -ra all -sid 218 [-switched]

  Symmetrix ID: 000xxxxxx218

                   S Y M M E T R I X    R D F    D I R E C T O R S


                                                                      Remote        Local    Remote
  Ident  Symb  Num  Slot  Type       Attr  SymmID        RA Grp   RA Grp  Status

  RF-9H   09H  121     9  RDF-R1       -   000xxxxxx098 101 (64) 101 (64) Online
  …...
  Notes:  VMAX 098 will be used for R2 device and VMAX 218 will be used for R1 device in this example although
          098 is local and 218 is remote:)

2. Check Connectivity between Arrays(Notes: available RDF group num. is a number which has not been used. It is required to collect a number from each array and keep them the same is a recommendation, for example, in this example, 110 is going to be used for both local and remote arrays)

::

  # symrdf -rdf -sid 218 ping
  Successfully pinged (Remotely) Symmetrix ID: 000xxxxxx218

3. Identify available RDF Group Num.

::

  # symcfg list -rdfg all -sid 218

  Symmetrix ID : 000xxxxxx218

                  S Y M M E T R I X   R D F   G R O U P S

      Local             Remote                  Group                RDFA Info
  -------------- --------------------- -------------------------- ---------------
              LL                                      Flags   Dir Flags Cycle
   RA-Grp  (sec)  RA-Grp  SymmID       T    Name    LPDS CHT  Cfg CSRM  time  Pri
  -------------- --------------------- -------------------------- ----- ----- ---
  100 (63)    10   -                 - D BES_100    XX.. ..X    - -IS-     15  33
  101 (64)    10 101 (64) 000xxxxxx098 D BES_101    XX.. ..X  F-S -IS-     15  33
  102 (65)    10 102 (65) 000xxxxxx098 D BES_102    XX.. ..X  F-S -IS-     15  33
  105 (68)    10 105 (68) 000xxxxxx098 D group_105  XX.. ..X  F-S -IS-     15  33
  109 (6C)    10 109 (6C) 000xxxxxx098 D group_109  XX.. ..X  F-S -IS-     15  33

  # symcfg list -rdfg all -sid 098

  Symmetrix ID : 000xxxxxx098

                  S Y M M E T R I X   R D F   G R O U P S

      Local             Remote                  Group                RDFA Info
  -------------- --------------------- -------------------------- ---------------
              LL                                      Flags   Dir Flags Cycle
   RA-Grp  (sec)  RA-Grp  SymmID       T    Name    LPDS CHT  Cfg CSRM  time  Pri
  -------------- --------------------- -------------------------- ----- ----- ---
  101 (64)    10 101 (64) 000xxxxxx218 D BES_101    XX.. ..X  F-S -IS-     15  33
  102 (65)    10 102 (65) 000xxxxxx218 D BES_102    XX.. ..X  F-S -IS-     15  33
  105 (68)    10 105 (68) 000xxxxxx218 D group_105  XX.. ..X  F-S -IS-     15  33
  109 (6C)    10 109 (6C) 000xxxxxx218 D group_109  XX.. ..X  F-S -IS-     15  33


4. Create R1/R2 Capable Device

::

  Source Array
  # symconfigure -sid 218 -cmd 'create dev count=1, size=2 GB, emulation=FBA, config=2-Way-Mir, \
      dynamic_capability=dyn_rdf;' -nop commit
  # symdev -sid 218 show 0FE5 | grep -i rdf
      Dynamic RDF Capability   : RDF1_OR_RDF2_Capable
  Target Array
  # symconfigure -sid 098 -cmd 'create dev count=1, size=2 GB, emulation=FBA, config=2-Way-Mir, \
      dynamic_capability=dyn_rdf;' commit
  # symdev -sid 098 show 0B59 | grep -i rdf
      Dynamic RDF Capability   : RDF1_OR_RDF2_Capable

5. Create Device Groups for Future Operation

::

  Source Array
  # symdg create -type ANY KC_RDF1
  # symdg -g KC_RDF1 add dev 0FE5
  Target Array
  # symdg create -type ANY KC_RDF2
  # symdg -g KC_RDF2 add dev 0B59

6. Create SRDF Group

::

  Identify Connected Directors
  # symsan list -sanrdf -sid 098 -dir all

  Symmetrix ID: 000xxxxxx098

      Flags                Remote
  --- ------- ---------------------------------
      Dir Lnk
  Dir CT  S   Symmetrix ID Dir WWN
  --- --- --- ------------ --- ----------------
  08H SO  C   000xxxxxx218 09H 500009720841E9E0
  Create SRDF Group
  # symrdf addgrp -sid 098 -rdfg 110 -label dyngrp110 -dir 08H -remote_rdfg 110 -remote_sid 218 -remote_dir 09H -nop

   Successfully Added Dynamic RDF Group 'dyngrp110' for Symm: 000xxxxxx098
  # symcfg list -rdfg all -sid 098

  Symmetrix ID : 000xxxxxx098

                  S Y M M E T R I X   R D F   G R O U P S

      Local             Remote                  Group                RDFA Info
  -------------- --------------------- -------------------------- ---------------
              LL                                      Flags   Dir Flags Cycle
   RA-Grp  (sec)  RA-Grp  SymmID       T    Name    LPDS CHT  Cfg CSRM  time  Pri
  -------------- --------------------- -------------------------- ----- ----- ---
  101 (64)    10 101 (64) 000xxxxxx218 D BES_101    XX.. ..X  F-S -IS-     15  33
  102 (65)    10 102 (65) 000xxxxxx218 D BES_102    XX.. ..X  F-S -IS-     15  33
  105 (68)    10 105 (68) 000xxxxxx218 D group_105  XX.. ..X  F-S -IS-     15  33
  109 (6C)    10 109 (6C) 000xxxxxx218 D group_109  XX.. ..X  F-S -IS-     15  33
  110 (6D)    10 110 (6D) 000xxxxxx218 D dyngrp110  XX.. ..X  F-S -IS-     15  33

7. Create SRDF Pair

::

  Create R1/R2 Mapping
  # cat SRDF_Mapping.txt
  0B59 0FE5
  Notes: the first column should be devices from local and the second column should be devices from remote.
  Create SRDF Pair
  # symrdf createpair -sid 098 -rdfg 110 -file SRDF_Mapping.txt -type R2 -invalidate R2 -nop

  An RDF 'Create Pair' operation execution is in progress for device
  file 'SRDF_Mapping.txt'. Please wait...

      Create RDF Pair in (0098,110)....................................Started.
      Create RDF Pair in (0098,110)....................................Done.
      Mark target device(s) in (0098,110) for full copy from source....Started.
      Devices: 0FE5-0FE5 in (0098,110).................................Marked.
      Mark target device(s) in (0098,110) for full copy from source....Done.

  The RDF 'Create Pair' operation successfully executed for device
  file 'SRDF_Mapping.txt'.
  Note: although 098 is used to invoke the configuration and it is a local array,
        it is the target for SRDF, hence the type is R2.

8. Establish

::

  Full - full sync for the first time
  # symrdf -g KC_RDF2 establish -full -nop

  An RDF 'Full Establish' operation execution is
  in progress for device group 'KC_RDF2'. Please wait...

      Suspend RDF link(s).......................................Done.
      Mark target (R2) devices for full copy from source (R1)...Started.
      Devices: 0FE5-0FE5 in (0098,110)..........................Marked.
      Mark target (R2) devices for full copy from source (R1)...Done.
      Merge device track tables between source and target.......Started.
      Devices: 0FE5-0FE5 in (0098,110)..........................Merged.
      Merge device track tables between source and target.......Done.
      Resume RDF link(s)........................................Started.
      Resume RDF link(s)........................................Done.

  The RDF 'Full Establish' operation successfully initiated for
  device group 'KC_RDF2'.
  Incremental - sync only the new data from R1 to R2
  # symrdf -g KC_RDF2 establish

  An RDF 'Incremental Establish' operation execution is
  in progress for device group 'KC_RDF2'. Please wait...
  …...
  Note: The "establish" operation needs to be performed on any array(local or remote)
        for just once - no need to run at both arrays.

9. Failover/Failback/Restore/Split/etc.

::

  Failover - Switch Data Processing from R1 to R2
  # symrdf -g KC_RDF2 failover -nop -force

  An RDF 'Failover' operation execution is
  in progress for device group 'KC_RDF2'. Please wait...

      Suspend RDF link(s).......................................Done.
      Read/Write Enable device(s) on RA at target (R2)..........Done.

  The RDF 'Failover' operation successfully executed for
  device group 'KC_RDF2'.

  # symrdf -g KC_RDF2 query

  Device Group (DG) Name             : KC_RDF2
  DG's Type                          : ANY
  DG's Symmetrix ID                  : 000xxxxxx098    (Microcode Version: 5876)
  Remote Symmetrix ID                : 000xxxxxx218    (Microcode Version: 5876)
  RDF (RA) Group Number              : 110 (6D)

         Target (R2) View                 Source (R1) View     MODES
  --------------------------------    ------------------------ ----- ------------
               ST                  LI      ST
  Standard      A                   N       A
  Logical       T  R1 Inv   R2 Inv  K       T  R1 Inv   R2 Inv       RDF Pair
  Device  Dev   E  Tracks   Tracks  S Dev   E  Tracks   Tracks MDAE  STATE
  -------------------------------- -- ------------------------ ----- ------------

  DEV001  0B59 RW       0        0 NR 0FE5 RW       0        0 C.D.  Failed Over
  Failback - Switch Data Processing back to R1
  # symrdf -g KC_RDF2 failback -nop -force

  An RDF 'Failback' operation execution is
  in progress for device group 'KC_RDF2'. Please wait...

      Write Disable device(s) on RA at target (R2)..............Done.
      Suspend RDF link(s).......................................Done.
      Merge device track tables between source and target.......Started.
      Devices: 0FE5-0FE5 in (0098,110)..........................Merged.
      Merge device track tables between source and target.......Done.
      Resume RDF link(s)........................................Started.
      Resume RDF link(s)........................................Done.

  The RDF 'Failback' operation successfully executed for
  device group 'KC_RDF2'.

  # symrdf -g KC_RDF2 query

  Device Group (DG) Name             : KC_RDF2
  DG's Type                          : ANY
  DG's Symmetrix ID                  : 000xxxxxx098    (Microcode Version: 5876)
  Remote Symmetrix ID                : 000xxxxxx218    (Microcode Version: 5876)
  RDF (RA) Group Number              : 110 (6D)

         Target (R2) View                 Source (R1) View     MODES
  --------------------------------    ------------------------ ----- ------------
               ST                  LI      ST
  Standard      A                   N       A
  Logical       T  R1 Inv   R2 Inv  K       T  R1 Inv   R2 Inv       RDF Pair
  Device  Dev   E  Tracks   Tracks  S Dev   E  Tracks   Tracks MDAE  STATE
  -------------------------------- -- ------------------------ ----- ------------

  DEV001  0B59 WD       0        0 RW 0FE5 RW       0        0 C.D.  Synchronized
  Restore - Sync Data from R2 to R1
  # symrdf -g KC_RDF2 restore [-full] -nop -force
  Split - Stop Mirroring between R1 and R2
  # symrdf -g KC_RDF2 split -nop -force

10. Query

::

  # symrdf -g KC_RDF2 query

  Device Group (DG) Name             : KC_RDF2
  DG's Type                          : ANY
  DG's Symmetrix ID                  : 000xxxxxx098    (Microcode Version: 5876)
  Remote Symmetrix ID                : 000xxxxxx218    (Microcode Version: 5876)
  RDF (RA) Group Number              : 110 (6D)

         Target (R2) View                 Source (R1) View     MODES
  --------------------------------    ------------------------ ----- ------------
               ST                  LI      ST
  Standard      A                   N       A
  Logical       T  R1 Inv   R2 Inv  K       T  R1 Inv   R2 Inv       RDF Pair
  Device  Dev   E  Tracks   Tracks  S Dev   E  Tracks   Tracks MDAE  STATE
  -------------------------------- -- ------------------------ ----- ------------

  DEV001  0B59 WD       0        0 RW 0FE5 RW       0        0 C.D.  Synchronized

  Total          -------- --------           -------- --------
    Track(s)            0        0                  0        0
    MB(s)             0.0      0.0                0.0      0.0

  # symdg show KC_RDF2
  …...
  Group Name:  KC_RDF2

      Group Type                                   : ANY     (RDFA)
      Device Group in GNS                          : No
      Valid                                        : Yes
      Symmetrix ID                                 : 000xxxxxx098
  ……
      Standard (STD) Devices (1):
          {
          ----------------------------------------------------------------------------------
                                                        Sym  Device                     Cap
          LdevName              PdevName                Dev  Config        Att. Sts     (MB)
          ----------------------------------------------------------------------------------
          DEV001                N/A                     0B59 RDF2+Mir           WD      5121
          }
  ……
      Device Group RDF Information
          {
          RDF Type                               : R2
          RDF (RA) Group Number                  : 110 (6D)

          Remote Symmetrix ID                    : 000xxxxxx218
  ……
          RDF Mode                               : Adaptive Copy
          RDF Adaptive Copy                      : Enabled: Disk Mode
  ……
          Device RDF Status                      : Ready           (RW)

          Device RA Status                       : Write Disabled  (WD)
          Device Link Status                     : Ready           (RW)
  ……
          Device RDF State                       : Write Disabled  (WD)
          Remote Device RDF State                : Ready           (RW)

          RDF Pair State (  R1 <===> R2 )        : Synchronized
  …...

11. Delete SRDF Configurations

::

  Delete SRDF Pair
  # symrdf suspend -sid 098 -file SRDF_Mapping.txt -rdfg 110
  # symrdf deletepair -sid 098 -file SRDF_Mapping.txt -rdfg 110 -nop

  An RDF 'Delete Pair' operation execution is in progress for device
  file 'SRDF_Mapping.txt'. Please wait...

      Delete RDF Pair in (0098,110)....................................Started.
      Delete RDF Pair in (0098,110)....................................Done.

  The RDF 'Delete Pair' operation successfully executed for device
  file 'SRDF_Mapping.txt'.

  # symrdf -g KC_RDF2 query

  Device Group 'KC_RDF2' has no associated RDF devices that match the criteria specified.
  Remove SRDF Group
  # symcfg list -rdfg all -sid 098

  Symmetrix ID : 000xxxxxx098

                  S Y M M E T R I X   R D F   G R O U P S

      Local             Remote                  Group                RDFA Info
  -------------- --------------------- -------------------------- ---------------
              LL                                      Flags   Dir Flags Cycle
   RA-Grp  (sec)  RA-Grp  SymmID       T    Name    LPDS CHT  Cfg CSRM  time  Pri
  -------------- --------------------- -------------------------- ----- ----- ---
  101 (64)    10 101 (64) 000xxxxxx218 D BES_101    XX.. ..X  F-S -IS-     15  33
  102 (65)    10 102 (65) 000xxxxxx218 D BES_102    XX.. ..X  F-S -IS-     15  33
  105 (68)    10 105 (68) 000xxxxxx218 D group_105  XX.. ..X  F-S -IS-     15  33
  109 (6C)    10 109 (6C) 000xxxxxx218 D group_109  XX.. ..X  F-S -IS-     15  33
  110 (6D)    10 110 (6D) 000xxxxxx218 D dyngrp110  XX.. ..X  F-S -IS-     15  33
  # symrdf removegrp -label dyngrp110 -sid 098 -nop

    Successfully Removed Dynamic RDF Group (Label: 'dyngrp110') for Symm: 000xxxxxx098
  # symcfg list -rdfg all -sid 098

  Symmetrix ID : 000xxxxxx098

                  S Y M M E T R I X   R D F   G R O U P S

      Local             Remote                  Group                RDFA Info
  -------------- --------------------- -------------------------- ---------------
              LL                                      Flags   Dir Flags Cycle
   RA-Grp  (sec)  RA-Grp  SymmID       T    Name    LPDS CHT  Cfg CSRM  time  Pri
  -------------- --------------------- -------------------------- ----- ----- ---
  101 (64)    10 101 (64) 000xxxxxx218 D BES_101    XX.. ..X  F-S -IS-     15  33
  102 (65)    10 102 (65) 000xxxxxx218 D BES_102    XX.. ..X  F-S -IS-     15  33
  105 (68)    10 105 (68) 000xxxxxx218 D group_105  XX.. ..X  F-S -IS-     15  33
  109 (6C)    10 109 (6C) 000xxxxxx218 D group_109  XX.. ..X  F-S -IS-     15  33

  Legend:
  ……

MISC Commands
-------------

- Source/Target vs. Local/Remote

  - Source: R1;
  - Target: R2;
  - Local:  based on the view of connected host/SE, local may be SRDF source or SRDF target;
  - Remote: based on the view of connected host/SE, once you run commands on a host attached to the remote array directly, the remote becomes local to the host and the other array becomes local.

- SRDF Group Type

  ::

    # symcfg -sid 76 -ra all list

    Symmetrix ID: 000xxxxxx076

                     S Y M M E T R I X    R D F    D I R E C T O R S


                                             Remote        Local    Remote
    Ident  Symb  Num  Slot  Type       Attr  SymmID        RA Grp   RA Grp  Status

    RF-1D   01D   49     1  RDF-BI-DIR  -   000xxxxxx076  10 (09)  10 (09) Online
                                        -   000xxxxxx076  11 (0A)  11 (0A)
                                        -   000xxxxxx076  13 (0C)  13 (0C)
    RF-16D  16D   64    16  RDF-R1      -   000xxxxxx076  12 (0B)  12 (0B) Online
                                    -   000xxxxxx076  13 (0C)  13 (0C)
- Type Explanation

  - RDF-BI-DIR - This is the state of the RDF group when the group is defined (i.e., before any RDF devices are assigned to the RDF group). This value will also be shown when both R1 and R2 devices are defined to the RDF group.
  - RDF-R1 - This value indicates that the RDF group contains only R1 devices.
  - RDF-R2 - This value indicates that the RDF group contains only R2 devices.
  - Caution!!: For fibre channel and GigE remote directors this state field does not indicate the capability of the link. The Fibre Channel and Ethernet communication protocols are bi-directional architectures. The "Type" field only reflects the type of RDF devices on the RDF director.

- Show R1/R2 Devices and Their Corresponding RDF Group Number

  ::

    # symrdf list -sid 098

    Symmetrix ID: 000xxxxxx098

                                  Local Device View
    ----------------------------------------------------------------------------
                        STATUS     MODES                     RDF  S T A T E S
    Sym        RDF      ---------  -----  R1 Inv   R2 Inv ----------------------
    Dev  RDev  Typ:G    SA RA LNK  MDATE  Tracks   Tracks Dev RDev Pair
    ---- ---- --------  ---------  ----- -------  ------- --- ---- -------------

    0B54 0DF6   R2:101  RW RW NR   C.D2.     348        0 RW  RW   Split
    0B56 0DF8   R2:102  RW RW NR   C.D2.     346        0 RW  RW   Split
    0B57 0DF9   R2:105  RW WD NR   C.D2.       0        0 WD  RW   Suspended
    0B58 0DFA   R2:109  RW WD NR   C.D2.       0        0 WD  RW   Suspended
    …...
    Note:  Typ:G column shows type of devices and SRDF group number. For example,
           0B56 is a R2 device and belong to SRDF group 102.

- Show Existing R1/R2 Devices

  ::

    # symdev list -r1 -sid 218

    Symmetrix ID: 000xxxxxx218

            Device Name           Directors                  Device
    --------------------------- ------------- -------------------------------------
                                                                               Cap
    Sym  Physical               SA :P DA :IT  Config        Attribute    Sts   (MB)
    --------------------------- ------------- -------------------------------------

    0DDA Not Visible            09E:0  NA:NA  RDF1+TDEV     N/Grp'd      RW    2048
    0DDB Not Visible            09E:0  NA:NA  RDF1+TDEV     N/Grp'd      RW    2048
    0DDC Not Visible            09E:0  NA:NA  RDF1+TDEV     N/Grp'd      RW    2048
    ……
    Note: N/Grp'd means the device does not belong to any SRDF group.

- Modify SRDF Group

  ::

    symrdf modifygrp -sid 098 -label dyngrp110 -remove -dir 13a

- Turn off Adaptive Copy

  ::

    # symrdf -cg RDF1_CG set mode acp_off

    An RDF Set 'ACp Mode OFF' operation execution is in
    progress for composite group 'RDF1_CG'. Please wait...

    The RDF Set 'ACp Mode OFF' operation successfully executed
    for composite group 'RDF1_CG'.

- Enable Device Level Write Pacing Autostart(R1/R21&R2)

  ::

    Symconfigure –sid 515 –cmd “Set rdf group 5 fa_devpace_autostart=enable;” commit –nop -v

- Activate Device Pacing(R1/R21)

  ::

    symrdf -sid 515 -rdfg rdf_group_number activate -rdfa_devpace –nop
    (if the rdf group is in a Star env, add “-star” option)

==========
SRDF/Metro
==========

1. Identify director ports to be used(RA ports):

::

  # symsan list -sanrdf -sid 996 -dir all

  Symmetrix ID: 000xxxxxx996

            Flags                   Remote
  ------ ----------- ------------------------------------
         Dir Prt Lnk
  Dir:P  CS  S   S   Symmetrix ID Dir:P        WWN
  ------ --- --- --- ------------ ------ ----------------
  01E:08 SO  O   I   -            -      0000000000000000
  01E:09 SO  O   I   -            -      0000000000000000
  01E:10 SO  O   I   -            -      0000000000000000
  01E:11 SO  O   C   000xxxxxx098 07H:00 50000972C00189D8
  01E:11 SO  O   C   000xxxxxx098 08H:00 50000972C00189DC
  01E:11 SO  O   C   000xxxxxx193 01E:06 500009735012A406
  01E:11 SO  O   C   000xxxxxx193 02E:06 500009735012A446
  01E:11 SO  O   C   000xxxxxx996 02E:11 50000973580F904B
  02E:08 SO  O   I   -            -      0000000000000000
  02E:09 SO  O   I   -            -      0000000000000000
  02E:10 SO  O   I   -            -      0000000000000000
  02E:11 SO  O   C   000xxxxxx098 07H:00 50000972C00189D8
  02E:11 SO  O   C   000xxxxxx098 08H:00 50000972C00189DC
  02E:11 SO  O   C   000xxxxxx193 01E:06 500009735012A406
  02E:11 SO  O   C   000xxxxxx193 02E:06 500009735012A446
  02E:11 SO  O   C   000xxxxxx996 01E:11 50000973580F900B

  Legend:
    Director:
      (C)onfig : S = Fibre-Switched, H = Fibre-Hub
                 G = GIGE, - = N/A
      (S)tatus : O = Online, F = Offline, D = Dead, - = N/A

    Port:
      (S)tatus : O = Online, F = Offline, - = N/A

    Link:
      (S)tatus : C = Connected, P = ConnectInProg
                 D = Disconnected, I = Incomplete, - = N/A
  Explanations: we want to use 996 and 193 for SRDF/Metro setup - based on the command output,
                1E:11 & 2E:11 on 996 are connected/zoned with 1E:06 & 2E:06 on 193. They can
                be used to add SRDF group later.

2. List existing RDF groups to identify SRDF group num. to be used:

::

 # symcfg -sid 996 list -rdfg all

 Symmetrix ID : 000xxxxxx996

                 S Y M M E T R I X   R D F   G R O U P S

     Local             Remote                  Group               RDF Metro
 ------------ --------------------- --------------------------- -----------------
           LL                                       Flags   Dir    Witness
  RA-Grp  sec  RA-Grp  SymmID       ST    Name    LPDS CHTM Cfg CE S Identifier
 ------------ --------------------- --------------------------- -- --------------
   1 ( 0)  10   -      000xxxxxx193 FD aix119234_ XX.. ..X. F-S -- - -
   2 ( 1)  10   -      000xxxxxx193 FD jason_test XX.. ..X. F-S -- - -
  55 (36)  10  55 (36) 000xxxxxx098 OD Rotate     XX.. ..X. F-S -- - -
  66 (41)  10   -      000xxxxxx193 FD Joey_SAA   XX.. ..XX F-S -- - -
  71 (46)  10   -      000xxxxxx343 FD metro_71   .X.. ..X. F-S -- - -
  72 (47)  10   -      000xxxxxx343 FD metro_72   .X.. ..X. F-S -- - -
  73 (48)  10   -      000xxxxxx343 FD metro_73   .X.. ..X. F-S -- - -
  74 (49)  10   -      000xxxxxx343 FD metro_74   .X.. ..X. F-S -- - -
  88 (57)  10   -      000xxxxxx193 FD Joey_AA8   XX.. ..XX F-S -- - -
  92 (5B)  10   -      000xxxxxx193 FD Joey_AA2   XX.. ..XX F-S -- - -
  95 (5E)  10   -      000xxxxxx193 FD Joey_AA3   XX.. ..XX F-S -- - -
  96 (5F)  10   -      000xxxxxx193 FD Joey_AA    XX.. ..X. F-S -- - -
  97 (60)   1   -      000xxxxxx343 FW Joey_AQ1   XX.. ..X. F-S -- - -
 100 (63)  10   -      000xxxxxx193 FD Ting_AA    XX.. ..XX F-S -- - -
 ……
 Explanations: this command need to be run on both VMAX boxes. A SRDF group num. is a num.
               which has not been taken on both sides. For example, on VMAX 996, we can
               use 3-54, 56-65, etc. On the peer VMAX box, we find a num. as the same way.
               Normally, we will choose the same num. at both sides for ease of configuration.

3. Query Exising SRDF/Metro

::

  # symcfg -sid 996 list -rdfg all -rdf_metro

  Symmetrix ID : 000xxxxxx996

                  S Y M M E T R I X   R D F   G R O U P S

      Local             Remote                  Group               RDF Metro
  ------------ --------------------- --------------------------- -----------------
            LL                                       Flags   Dir    Witness
   RA-Grp  sec  RA-Grp  SymmID       ST    Name    LPDS CHTM Cfg CE S Identifier
  ------------ --------------------- --------------------------- -- --------------
    1 ( 0)  10   -      000xxxxxx193 FD aix119234_ XX.. ..X. F-S -- - -
    2 ( 1)  10   -      000xxxxxx193 FD jason_test XX.. ..X. F-S -- - -
   55 (36)  10  55 (36) 000xxxxxx098 OD Rotate     XX.. ..X. F-S -- - -
   66 (41)  10   -      000xxxxxx193 FD Joey_SAA   XX.. ..XX F-S -- - -
   71 (46)  10   -      000xxxxxx343 FD metro_71   .X.. ..X. F-S -- - -
  ……


4. Show Device Status:

::

  # symdev -sid 148 show 767 | grep RDF
      Device Configuration     : RDF1+TDEV
      Dynamic RDF Capability   : RDF1_OR_RDF2_Capable
      RDF Information
          RDF Type                               : R1
          RDF (RA) Group Number                  : 250 (F9)
          RDF Pair Configuration                 : Normal
          RDF STAR Mode                          : False
          RDF SQAR Mode                          : False
          RDF Mode                               : Synchronous
          RDF Adaptive Copy                      : Disabled
          RDF Adaptive Copy Write Pending State  : N/A
          RDF Adaptive Copy Skew (Tracks)        : 65535
          RDF Device Domino                      : Disabled
          RDF Link Configuration                 : Fibre
          RDF Link Domino                        : Disabled
          Prevent Automatic RDF Link Recovery    : Enabled
          Device RDF Status                      : Ready           (RW)
          RDF R2 Not Ready If Invalid            : Disabled
          Device RDF State                       : Ready           (RW)
          Remote Device RDF State                : Ready           (RW)
          RDF Pair State (  R1 <-=-> R2 )        : SyncInProg
          RDFA Information:

5. Query based on storge group:

::

  # symrdf -sid 193 -sg KC_SRDFM_xHA239194_SG query -rdfg 5

  Storage Group (SG) Name      : KC_SRDFM_xHA239194_SG
  Symmetrix ID                 : 000xxxxxx193    (Microcode Version: 5977)
  Remote Symmetrix ID          : 000xxxxxx996    (Microcode Version: 5977)
  RDF (RA) Group Number        :   5 (04)

          Source (R1) View                 Target (R2) View     MODE
  ---------------------------------    ------------------------ ---- ------------
                 ST                 LI       ST
  Standard        A                  N        A
  Logical  Sym    T R1 Inv  R2 Inv   K Sym    T R1 Inv  R2 Inv       RDF Pair
  Device   Dev    E Tracks  Tracks   S Dev    E Tracks  Tracks  MACE STATE
  --------------------------------- -- ------------------------ ---- ------------

  N/A      00402 RW       0       0 RW 00328 RW       0       0 T.X. ActiveBias
  N/A      00403 RW       0       0 RW 00329 RW       0       0 T.X. ActiveBias
  N/A      00404 RW       0       0 RW 0032A RW       0       0 T.X. ActiveBias
  N/A      00405 RW       0       0 RW 0032B RW       0       0 T.X. ActiveBias
  N/A      00406 RW       0       0 RW 0032E RW       0       0 T.X. ActiveBias
  N/A      00407 RW       0       0 RW 0032F RW       0       0 T.X. ActiveBias

  Total             ------- -------             ------- -------
    Track(s)              0       0                   0       0
    MB(s)               0.0     0.0                 0.0     0.0

  Legend for MODE:

   M(ode of Operation)   : A = Async, S = Sync, E = Semi-sync, C = Adaptive Copy
                         : M = Mixed, T = Active
   A(daptive Copy)       : D = Disk Mode, W = WP Mode, . = ACp off
   C(onsistency State)   : X = Enabled, . = Disabled, M = Mixed, - = N/A
   (Consistency) E(xempt): X = Enabled, . = Disabled, M = Mixed, - = N/A

===
NDM
===

Setup and create a migration session
------------------------------------

1. Run below commands to create the session:

   ::

     symdm environment -src_sid 3184 -tgt_sid 0129 -setup
     symdm create [-precopy] -src_sid 3184 -tgt_sid 0129 -sg lcseb246_sg [-validate] [-nop]

2. Rescan on servers to discover new paths

Query
-----

::

  symdm -sid 3184 -sg lcseb246_sg list [-v] [-detail] [-pairs_info]
  symdm -sid 3184 -sg lcseb246_sg list [-v] [-detail] [-sg_info]


Cancel
------

::

  symdm -sid 0129 -sg lcseb246_sg cancel [-nop]

Cutover
-------

::

  symdm -sid 0129 -sg lcseb246_sg list -v -detail -pairs_info | grep 'Migration State'
  symdm -sg lcseb246_sg cutover -sid 0129 [-nop]

Revert
------

::

  symdm cancel -sid 0129 -sg lcseb246_sg -revert [-nop]

Commit
------

::

  symdm commit -sid 0129 -sg lcseb246_sg [-nop]

Recover
-------

The recover command can be used if a migration step fails due to some problem in the environment. After fixing environment issues, a recover operation can be leverated to pick up where the create command failed and completes the create operation.

::

  symdm create -src_sid 3184 -tgt_sid 0129 -sg lcseb246_sg [-nop]

Remove the migration environment
--------------------------------

::

  symdm -src_sid 3184 -tgt_sid 0129 environment -remove [-nop]
