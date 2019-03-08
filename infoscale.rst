.. contents:: Veritas Tips

=====
VxDMP
=====

1. Start/Stop DMP:

   ::

     # vxdmpadm start/stop restore

2. Get DMP tunable options:

   ::

     # vxdmpadm gettune all
                 Tunable               Current Value  Default Value
     ------------------------------    -------------  -------------
     dmp_cache_open                           on               on
     dmp_daemon_count                         10               10
     dmp_delayq_interval                      15               15
     ……
     dmp_monitor_osevent                      on               on
     dmp_native_support                       on              off

3. Tune DMP options:

   ::

     # vxdmpadm settune …...

4. List all connected storage enclosures

   ::

      root@CSS3-H21:~# vxdmpadm listenclosure
      ENCLR_NAME        ENCLR_TYPE     ENCLR_SNO      STATUS       ARRAY_TYPE     LUN_COUNT
      =======================================================================================
      pp_emc0           PP_EMC         000194900815         CONNECTED    A/A         5    ====> To Symmetrix
      disk              Disk           DISKS                CONNECTED    Disk        1
      pp_emc_xtremio0   PP_EMC_XtremIO  e9cc000              CONNECTED    A/A        40 ====> To XtremIO

5. Enable DMP log:

   ::

     # vxdmpadm settune dmp_log_level=6

6. Show all disks(pseudo):

   ::

     root@CSS3-H21:~# vxdisk list
     DEVICE       TYPE            DISK         GROUP        STATUS
     disk_0       auto:ZFS        -            -            ZFS
     disk_1       auto:cdsdisk    xiodisk_1    xio_dg       online
     disk_2       auto:cdsdisk    -            -            online
     disk_3       auto:cdsdisk    -            -            online
     disk_4       auto:cdsdisk    -            -            online
     disk_5       auto:cdsdisk    -            -            online
     emcpower0s2  auto:simple     -            -            error
     emcpower1s2  auto:cdsdisk    -            -            online
     emcpower2s2  auto:none       -            -            online invalid
     emcpower3s2  auto:none       -            -            online invalid
     emcpower4s2  auto:none       -            -            online invalid

7. Show disk paths:

   ::

     root@CSS3-H21:~# vxdisk path
     SUBPATH                     DANAME               DMNAME       GROUP        STATE
     c0t5000CCA016106188d0s2     disk_0               -            -            ENABLED
     c11t514F0C5000022103d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c11t514F0C5000022102d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c11t514F0C5000022104d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c11t514F0C5000022101d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c10t514F0C5000022102d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c10t514F0C5000022104d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c10t514F0C5000022103d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     c10t514F0C5000022101d0s2    disk_1               xiodisk_1    xio_dg       ENABLED
     ……
     emcpower0c                  emcpower0s2          -            -            ENABLED
     emcpower1c                  emcpower1s2          -            -            ENABLED

8. Show disk paths for a single disk:

   ::

     root@CSS3-H21:~# vxdisk list emcpower0s2
     Device:    emcpower0s2
     devicetag: emcpower0
     type:      auto
     info:      format=simple,privoffset=1,pubslice=7,privslice=7
     flags:     error private autoconfig
     pubpaths:  block=/dev/vx/dmp/emcpower0s2 char=/dev/vx/rdmp/emcpower0s2
     guid:      {84b30abe-e378-11e2-baea-cd83a03acadf}
     udid:      EMC%5FSYMMETRIX%5F000194900815%5F1500119000
     site:      -
     errno:     Device path not valid
     Multipathing information:
     numpaths:   1
     emcpower0c      state=enabled

9. To display all the subpaths known to DMP:

   ::

     root@CSS3-H21:~# vxdmpadm getsubpaths
     NAME         STATE[A]   PATH-TYPE[M] DMPNODENAME  ENCLR-NAME   CTLR   ATTRS
     ================================================================================
     c0t5000CCA016106188d0s2 ENABLED(A)   -          disk_0       disk         c0        -
     c10t514F0C5000022101d0s2 ENABLED(A)   -          disk_1       disk         c10       -
     c10t514F0C5000022102d0s2 ENABLED(A)   -          disk_1       disk         c10       -
     c10t514F0C5000022103d0s2 ENABLED(A)   -          disk_1       disk         c10       -
     c10t514F0C5000022104d0s2 ENABLED(A)   -          disk_1       disk         c10       -
     c11t514F0C5000022101d0s2 ENABLED(A)   -          disk_1       disk         c11       -
     c11t514F0C5000022102d0s2 ENABLED(A)   -          disk_1       disk         c11       -
     c11t514F0C5000022103d0s2 ENABLED(A)   -          disk_1       disk         c11       -
     c11t514F0C5000022104d0s2 ENABLED(A)   -          disk_1       disk         c11       -

10. To get the information on all the subpaths connected to the same HBA card controller:

    ::

      root@CSS3-H21:~# vxdmpadm getsubpaths ctlr=c10
      NAME         STATE[A]   PATH-TYPE[M] DMPNODENAME  ENCLR-TYPE   ENCLR-NAME   ATTRS
      ================================================================================
      c10t514F0C5000022101d0s2  ENABLED(A)    -          disk_1       Disk         disk            -
      c10t514F0C5000022102d0s2  ENABLED(A)    -          disk_1       Disk         disk            -
      c10t514F0C5000022103d0s2  ENABLED(A)    -          disk_1       Disk         disk            -

11. Display all available HBA controllers:

    ::

      CTLR-NAME       ENCLR-TYPE      STATE      ENCLR-NAME
      =====================================================
      c0              Disk            ENABLED      disk
      c10             Disk            ENABLED      disk
      c11             Disk            ENABLED      disk
      emcp            PP_EMC          ENABLED      pp_emc0

12. Disable/Enable Controller:

    ::

      # vxdmpadm listctlr all
      CTLR-NAME       ENCLR-TYPE      STATE      ENCLR-NAME
      ===========================================================
      c1              Disk            ENABLED      disk
      c2              EMC             ENABLED      emc0
      c4              EMC             ENABLED      emc0
      # vxdmpadm disable ctlr=c2

      # vxdmpadm listctlr all

      CTLR-NAME       ENCLR-TYPE      STATE      ENCLR-NAME
      ===========================================================
      c1              Disk            ENABLED       disk
      c2              EMC             DISABLED      emc0
      c4              EMC             ENABLED       emc0
      # vxdmpadm enable ctlr=c2

      # vxdmpadm listctlr all
      CTLR-NAME       ENCLR-TYPE      STATE      ENCLR-NAME
      ===========================================================
      c1              Disk            ENABLED      disk
      c2              EMC             ENABLED      emc0
      c4              EMC             ENABLED      emc0

13. Display I/O stat:

    ::

      root@CSS3-H21:~# vxdmpadm iostat start
      root@CSS3-H21:~# vxdmpadm iostat show all
                             cpu usage = 2us    per cpu memory = 53248b
                                         OPERATIONS            BLOCKS          AVG TIME(ms)
      PATHNAME             READS    WRITES     READS    WRITES     READS    WRITES
      c0t5000CCA016106188d0s2            0         0         0         0    0.00     0.00
      c10t514F0C5000022101d0s2           0         0         0         0    0.00     0.00
      c10t514F0C5000022101d1s2           0         0         0         0    0.00     0.00
      c10t514F0C5000022101d2s2           0         0         0         0    0.00     0.00
      c10t514F0C5000022101d3s2           0         0         0         0    0.00     0.00
      ……
      root@CSS3-H21:~# vxdmpadm iostat reset
      root@CSS3-H21:~# vxdmpadm iostat stop

14. DMP log: /var/adm/vx/dmpevents.log

====
VxVM
====

1. Get VxVM version(Solaris):

   ::

     -bash-4.1# pkginfo -l VRTSvxvm
        PKGINST:  VRTSvxvm
           NAME:  Binaries for VERITAS Volume Manager by Symantec
       CATEGORY:  system
           ARCH:  sparc
        VERSION:  6.0.300.000,REV=01.14.2013.17.54
        BASEDIR:  /
         VENDOR:  Symantec Corporation
           DESC:  Virtual Disk Subsystem
       INSTDATE:  Sep 01 2014 05:55
        HOTLINE:  http://www.symantec.com/business/support/assistance_care.jsp
         STATUS:  completely installed

2. vxconfigd - VxVM configuration daemon

3. vxdctl - control the volume configuration daemon. For example, enable ‘vxconfigd’ to rebuild device node directories & DMP databases:

4. Change Namingscheme:

   ::

     -bash-4.1# vxddladm get namingscheme
     NAMING_SCHEME       PERSISTENCE    LOWERCASE      USE_AVID
     ============================================================
     OS Native           No             Yes            Yes
     -bash-4.1# vxdmpadm listenclosure
     ENCLR_NAME        ENCLR_TYPE     ENCLR_SNO      STATUS       ARRAY_TYPE     LUN_COUNT
     =======================================================================================
     pp_emc0           PP_EMC         000194900815         CONNECTED    A/A         5
     disk              Disk           DISKS                CONNECTED    Disk        1
     pp_emc_xtremio0   PP_EMC_XtremIO  e9cc000              CONNECTED    A/A        40
     -bash-4.1# vxddladm set namingscheme=ebn persistence=yes
     -bash-4.1# vxddladm get namingscheme
     NAMING_SCHEME       PERSISTENCE    LOWERCASE      USE_AVID
     ============================================================
     Enclosure Based     Yes            Yes            Yes

5. Change TPDMODE(Third party driver mode):

   ::

     root@CSS3-H21:~# vxdmpadm listenclosure
     ENCLR_NAME        ENCLR_TYPE     ENCLR_SNO      STATUS       ARRAY_TYPE     LUN_COUNT
     =======================================================================================
     pp_emc0           PP_EMC         000194900815         CONNECTED    A/A         5
     disk              Disk           DISKS                CONNECTED    Disk        1
     pp_emc_xtremio0   PP_EMC_XtremIO  e9cc000              CONNECTED    A/A        40
     root@CSS3-H21:~# vxdmpadm setattr enclosure pp_emc_xtremio0 tpdmode=pseudo
     (Refer to Symmetrix KB: http://www.symantec.com/business/support/index?page=content&id=TECH77212)

6. Example: Create a VxVM volume:

   ::

     # /opt/VRTS/bin/vxdisksetup -i c1t2d0s2
     # vxdisk list
     DEVICE       TYPE            DISK         GROUP        STATUS
     c1t0d0s2     auto:none       -            -            online invalid
     c1t1d0s2     auto:none       -            -            online invalid
     c1t2d0s2     auto:cdsdisk    -            -            online
     # vxdg init mydg disk01=c1t2d0
     # vxdisk list
     DEVICE       TYPE           DISK        GROUP        STATUS               OS_NATIVE_NAME   ATTR
     c1t0d0s2     auto:none      -            -           online invalid       c1t0d0s2         -
     c1t1d0s2     auto:none      -            -           online invalid       c1t1d0s2         -
     c1t2d0s2     auto:cdsdisk   disk01       mydg        online               c1t2d0s2         -
     # vxassist -g mydg make myvol 500m ===> Create a 500MB volume
     # mkfs -F vxfs /dev/vx/rdsk/mydg/myvol
     # cat /etc/vfstab |grep data (Solaris)
     /dev/vx/dsk/mydg/myvol  /dev/vx/rdsk/mydg/myvol /data   vxfs    0       yes     -
     # mount /data
     # df -h |grep data
     /dev/vx/dsk/mydg/myvol   500M   2.2M   467M     1%    /data

7. Example(Solaris): Enable VxVM on disks

   ::

     # vxdisk list
     uDEVICE       TYPE            DISK         GROUP        STATUS
     udisk_0       auto:ZFS        -            -            ZFS
     udisk_1       auto            -            -            nolabel
     udisk_2       auto            -            -            nolabel
     udisk_3       auto            -            -            nolabel
     udisk_4       auto            -            -            nolabel
     udisk_5       auto            -            -            nolabel
     uemcpower0s2  auto:cdsdisk    -            -            online
     uemcpower1s2  auto:cdsdisk    -            -            online
     uemcpower2s2  auto:cdsdisk    -            -            online
     uemcpower3s2  auto:cdsdisk    -            -            online
     uemcpower4s2  auto:cdsdisk    -            -            online
     u# format disk_1
     uNo disks found!
     u
     u# format emcpower15/16/17/18/19a ===> emcpower1Xa == disk_1 backend native disks here
     u……
     u# vxdctl enable
     u# vxdisk list
     uDEVICE       TYPE            DISK         GROUP        STATUS
     udisk_0       auto:ZFS        -            -            ZFS
     udisk_1       auto:none       -            -            online invalid
     udisk_2       auto:none       -            -            online invalid
     udisk_3       auto:none       -            -            online invalid
     udisk_4       auto:none       -            -            online invalid
     udisk_5       auto:none       -            -            online invalid
     uemcpower0s2  auto:cdsdisk    -            -            online
     uemcpower1s2  auto:cdsdisk    -            -            online
     uemcpower2s2  auto:cdsdisk    -            -            online
     uemcpower3s2  auto:cdsdisk    -            -            online
     uemcpower4s2  auto:cdsdisk    -            -            online
     u# /opt/VRTS/bin/vxdisksetup -i disk_1/2/3/4/5
     u# vxdisk list
     uDEVICE       TYPE            DISK         GROUP        STATUS
     udisk_0       auto:ZFS        -            -            ZFS
     udisk_1       auto:cdsdisk    -            -            online
     udisk_2       auto:cdsdisk    -            -            online
     udisk_3       auto:cdsdisk    -            -            online
     udisk_4       auto:cdsdisk    -            -            online
     udisk_5       auto:cdsdisk    -            -            online
     uemcpower0s2  auto:cdsdisk    -            -            online
     uemcpower1s2  auto:cdsdisk    -            -            online
     uemcpower2s2  auto:cdsdisk    -            -            online
     uemcpower3s2  auto:cdsdisk    -            -            online
     uemcpower4s2  auto:cdsdisk    -            -            online

8. Show registered/license:

   ::

     root@CSS3-H21:~# vxlicrep

     Symantec License Manager vxlicrep utility version 3.02.61.004
     Copyright (C) 1996-2012 Symantec Corporation. All rights reserved.

     Creating a report on all VERITAS products installed on this system

      -----------------***********************-----------------

        License Key                         = AJZU-3JZP-C36L-EXOZ-EZPP-PNPP-PPPR-PIPC-P
        Product Name                        = VERITAS Volume Manager
        Serial Number                       = 12365
        License Type                        = PERMANENT
        OEM ID                              = 2006
        Site License                        = YES
        Editions Product                    = YES

      Features :=

        CPU Count                           = Not Restricted
        ALL_DMP                             = Enabled
        Platform                            = un-used
        Version                             = 6.0
        Maximum number of volumes           = Not Restricted
        DMP Native Support                  = Enabled
        VXKEYLESS                           = Enabled

9. Example(Solaris): setup a PP pseudo disk for using with the volume manager:

   ::

     bash-3.2# vxdisk list | grep emcpower32
     emcpower32s2 auto:none       -            -            online invalid
     bash-3.2# vxdisksetup -i emcpower32
     bash-3.2# vxdisk list | grep emcpower32
     emcpower32s2 auto:cdsdisk    -            -            online
     bash-3.2#  vxdg init bearcat_smartmove emcpower32s2

10. Check the largest volume can be created:

    ::

      bash-3.2# vxassist -g bearcat_vnx36 maxsize
      Maximum volume size: 166713344 (81403Mb)

11. Create strip volume(RAID-0)

    ::

      # vxassist -b -g bearcat_vnx36_dg make stripe_1 5g layout=stripe
      # vxprint -g bearcat_vnx36_dg
      v  stripe_1     fsgen        ENABLED  10485760 -        ACTIVE   -       -
      pl stripe_1-01  stripe_1     ENABLED  10485760 -        ACTIVE   -       -
      sd emcpower28s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower30s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower32s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower34s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower36s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower38s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower41s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -
      sd emcpower43s2-01 stripe_1-01 ENABLED 1310720 0        -        -       -

12. Create concatenated volume: if the created volume is larger than subdisks, it will be concatenated automatically

13. Monitor IO stat for VM disks for VxVM

    ::

      # vxdmpadm iostat start
      # vxdmpadm iostat show
      # vxdmpadm iostat stop

14. Monitor IO for VxVM Volumes

    ::

      bash-3.2# vxstat -g bearcat_vnx36_dg
                            OPERATIONS          BLOCKS           AVG TIME(ms)
      TYP NAME              READ     WRITE      READ     WRITE   READ  WRITE
      vol bearcat1         39740   8629684   2334714 1102655454   8.30   0.47
      vol bearcat2         26020   8629990   2148138 1102696409   6.19   0.46

15. Initialize disk bigger than 2T

    ::

      # format -e <native disk name> -> label as EFI

      # vxdisksetup -if <vxdmpnode pseudo disk name>

======================
VxVM Command Reference
======================

Disk Operation
--------------

========================  ================  =======================================
Operation                 Command           Example
------------------------  ----------------  ---------------------------------------
Initialize disk           vxdisksetup       vxdisksetup -i c1t9d0
Uninitialize disks        vxdiskunsetup     vxdiskunsetup -C c1t9d0
List disks                vxdisk list
List disk header          vxdisk list       vxdisk list disk01
List disk private region  vxprivutil list   vxprivutil list /dev/rdsk/c1t9d0s2
Reserve a disk            vxedit set        vxedit -g my-dg set reserve=on my-disk
Rename a disk             vxedit rename     vxedit -g my-dg rename my-disk new-disk
Rescan/Refresh all disks  vxdctl enable
Remove a disk             vxdisk rm         vxdisk rm emcpower30s2
========================  ================  =======================================

Disk Group Operation
--------------------

==============================   =========================   =====================================================
Operation                        Command                     Example
------------------------------   -------------------------   -----------------------------------------------------
Create disk group                vxdg init                   vxdg init my-dg disk01=c1t9d0
Remove disk group                vxdg destroy                vxdg destroy my-dg
Add disk                         vxdg adddisk                vxdg -g my-dg adddisk disk02=c1t8d0
Remove disk                      vxdg rmdisk                 vxdg -g my-dg rmdisk disk02
Import diskgroup                 vxdg import                 vxdg import my-dg
Deport diskgroup                 vxdg deport                 vxdg deport my-dg
List diskgroups                  vxdg list                   vxdg -o alldgs -e list
List free space                  vxdg free                   vxdg -g my-dg free
List total free space            vxassist                    vxassist -g my-dg maxsize layout=concat
Rename diskgroup on deport       vxdg deport                 vxdg -n new-dg deport old-dg
Rename diskgroup on import       vxdg import                 vxdg -n new-dg import old-dg
Evacuate data from a disk        vxevac                      vxevac -g my-dg fromdisk todisk(s)
==============================   =========================   =====================================================

Plex Operation
--------------

==============================   =========================   =====================================================
Operation                        Command                     Example
------------------------------   -------------------------   -----------------------------------------------------
Create a plex                    vxmake plex                 vxmake -g my-dg plex my-plex sd=my-sd
Associate a plex                 vxplex att                  vxplex -g my-dg att my-vol my-plex
Dis-associate a plex             vxplex dis                  vxplex -g my-dg dis my-plex
Attach a plex                    vxplex att                  vxplex -g my-dg att my-vol my-plex
Detach a plex                    vxplex det                  vxplex -g my-dg det my-plex
List plexes                      vxprint                     vxprint -lp
Remove a plex                    vxedit                      vxedit -g my-dg rm my-plex
==============================   =========================   =====================================================

Subdisk Operation
-----------------

==============================   =========================   =====================================================
Operation                        Command                     Example
------------------------------   -------------------------   -----------------------------------------------------
Create a subdisk                 vxmake sd                   vxmake -g my-dg my-sd disk1 1 5000
Remove subdisk                   vxedit rm                   vxedit -g my-dg rm my-sd
Display subdisk info             vxprint -st
Associate subdisk to plex        vxsd assoc                  vxsd -g my-dg assoc my-plex my-sd
Disassociate subdisk             vxsd dis                    vxsd -g my-dg dis my-sd
==============================   =========================   =====================================================

Volume Operation
----------------

==============================   =========================   =====================================================
Operation                        Command                     Example
------------------------------   -------------------------   -----------------------------------------------------
Create a volume                  vxassist make               - vxassist -g my-dg make my-vol 1G
                                                             - vxassist make my-vol 1G layout=stripe
Display volume info              vxprint -vt                 vxprint -g my-dg -vt
Display volume info              vxinfo                      vxinfo -g my-dg my-vol
Resize a volume                  - vxassist growto           - vxassist -g my-dg growto my-vol 2G
                                 - vxassist growby           - vxassist -g my-dg growby my-vol 600M
Start a volume                   vxvol start                 vxvol -g my-dg start my-vol
Stop a volume                    vxvol stop                  vxvol -g my-dg stop my-vol
Initialise a volume              vxvol init active           vxvol -g my-dg init active my-vol
Recover a volume                 vxrecover                   vxrecover -g my-dg my-vol
Mirror a volume                  vxassist mirror             vxassist -g my-dg mirror my-vol
Add log to a volume              vxassist addlog             vxassist -g my-dg addlog my-vol
Snapshot a volume                - vxassist snapstart        - vxassist -g my-dg snapstart my-vol
                                 - vxassist snapshot         - vxassist -g my-dg snapshot my-vol my-snap
Change volume layout             vxassist relayout           vxassist -g my-dg relayout my-vol layout=stripe
Convert volume type              vxassist convert            vxassist -g my-dg convert my-vol layout=stripe-mirror
Estimate max volume size         - vxassist maxsize          - vxassist -g my-dg maxsize layout=... disk1 diskn
                                 - vxassist maxgrow          - vxassist -g my-dg maxgrow my-vol
Remove a volume                  vxassist remove             vxassist -g my-dg remove my-vol
Remove a volume                  - vxvol stop                - vxvol -g my-dg stop my-vol
                                 - vxedit -r rm              - vxedit -g my-dg -r rm my-vol
                                 - vxdg rmdisk               - vxdg -g my-dg rmdisk my-disk
Help on layout                   vxassist help               vxassist help layout
==============================   =========================   =====================================================

MISC Operation
--------------

==============================   =========================   =====================================================
Operation                        Command                     Example
------------------------------   -------------------------   -----------------------------------------------------
Display enclusres                vxdmpadm listenclosure      vxdmpadm listenclosure all
Display controllers              vxdmpadm listctlr           vxdmpadm listctlr all
Display subpaths                 vxdmpadm getsubpaths        - vxdmpadm getsubpaths ctlr=c3
                                                             - vxdmpadm getsubpaths dmpnodename=EMC_CLARiiON2_4
Enable Enclosure Based Naming    vxddladm set namingscheme   vxddladm set namingscheme=ebn
Disable Enclosure Based Naming   vxddladm set namingscheme   vxddladm set namingscheme=obn
==============================   =========================   =====================================================

===
VCS
===

Installation
------------

There is nothing special for the installation - just following the installation guide is enough. After installation, the only thing to remember is installing ASL package as shown in the installer log:

The updates to VRTSaslapm package are released via the SORT web page: https://sort.veritas.com/asl.

Go to the website, choose your server architecture and OS release, then download the pacakge. There is a short introduction on how to install the package at the bottom of the download page -> Follow it -> Done

Configuration after Installation
--------------------------------

Below steps are based on RHEL Installation, however it should be similar on other platforms.

1. Version Verification:

   ::

     # /opt/VRTS/install/installer -version

     Enter the system names separated by spaces for version checking: (xha239194)

         Checking communication on xha239194 ................................................. Done
         Checking installed products on xha239194 ............................................ Done

     Platform of xha239194:
             Linux RHEL 7.2 x86_64

     Installed product(s) on xha239194:
             InfoScale Enterprise - 7.2 - Licensed

     Product:
             InfoScale Enterprise - 7.2 - Licensed

     Packages:
             Installed Required packages for InfoScale Enterprise 7.2:
               #PACKAGE     #VERSION
               VRTSamf      7.2.0.000
               VRTSaslapm   7.2.0.100
               VRTScavf     7.2.0.000
               VRTScps      7.2.0.000
               VRTSdbac     7.2.0.000
     …...

2. Environment Setup(PATH, MANPATH) - Follow the installation guide

3. Initialize VxVM(prepare for fencing during VCS configuration)

   ::

     # vxconfigd -k
     # vxdctl init
     # vxdisk scandisks
     # vxdctl enable
     # vxdisk list
     # vxdisksetup -i <disk name>
     # vxdisk list

     # dd if=/dev/zero of=/dev/<disk name>
     Note: Empty existing dg setup. There is no need to dd the full disk, just several MBs are enough

     # vxdctl enable ---> Restart vxconfigd daemon
     # vxdisksetup -if <disk name> ---> Initialize disk
     # vxdisk list ---> all disks to be used should become "online" from "online invalid" or other status

4. Initial Configuration with installer -> Follow the prompt

   ::

     # /opt/VRTS/install/installer -configure
     Note: the step which fails most frequently is fencing configuration, we can complete the VCS init
     configuration without caring about the failure and reconfigure fencing later with below command

     # /opt/VRTS/install/installer -fencing

5. Verification

   ::

     # hastatus
     attempting to connect....
     attempting to connect....connected


     group           resource             system               message
     --------------- -------------------- -------------------- --------------------
                                          xha239194            RUNNING
                                          xha239195            RUNNING
     vxfen                                xha239194            ONLINE
     vxfen                                xha239195            ONLINE
     -------------------------------------------------------------------------
                     coordpoint           xha239194            ONLINE
                     coordpoint           xha239195            ONLINE
                     RES_phantom_vxfen    xha239194            ONLINE
                     RES_phantom_vxfen    xha239195            ONLINE

Basic Usage
-----------

1. Start/Stop:

   ::

     # /opt/VRTS/install/installer -start/stop

2. Query Service Group

   ::

     # hagrp -state
     Group       Attribute             System     Value
     vxfen        State                 xha239194  |ONLINE|
     vxfen        State                 xha239195  |ONLINE|

     # hagrp -resources vxfen ---> Service Group name
     coordpoint
     RES_phantom_vxfen

     # hagrp -dep vxfen ---> List service group dependency
     …...
     vxfen        SourceFile            global     ./main.cf
     vxfen        SysDownPolicy         global
     vxfen        SystemList            global     xha239194 0       xha239195       1
     ……
     # hagrp -display vxfen ---> Display a service group's dependency

3. Query Resources:

   ::

     # hares -display ---> Display all resources
     Resource         Attribute                System     Value
     RES_phantom_vxfen Group                    global     vxfen
     RES_phantom_vxfen Type                     global     Phantom

4. Query Systems:

   ::

     # hasys -list
     xha239194
     xha239195

     # hasys -display xha239194
     #System    Attribute               Value
     xha239194  AgentsStopped           0
     xha239194  AvailableCapacity       CPU  39.72   Mem     62623.00        Swap    32255.00
     xha239194  CPUThresholdLevel       Critical     90      Warning 80      Note    70      Info    60
     ……

5. Query Clusters:

   ::

     # haclus -display
     #Attribute               Value
     AdministratorGroups
     Administrators
     AutoAddSystemToCSG       1
     AutoClearQ
     AutoStartTimeout         150
     BackupInterval           0
     CID                      {52f7ffbc-bd12-11e6-aaad-2fd1e77070e8}
     ClusState                RUNNING
     ClusterAddress
     ClusterLocation
     ClusterName              xha239194195
     …...

6. Query Cluster Status:

   ::

     # hastatus -summary

     -- SYSTEM STATE
     -- System               State                Frozen

     A  xha239194            RUNNING              0
     A  xha239195            RUNNING              0

     -- GROUP STATE
     -- Group           System               Probed     AutoDisabled    State

     B  vxfen           xha239194            Y          N               ONLINE
     B  vxfen           xha239195            Y          N               ONLINE

7. Query Logs:

   ::

     # hamsg -help
     # hamsg -list
     # hamsg -tail <name in hamsg -list output>

8. Change cluster master:

   ::

     # /etc/vx/bin/vxclustadm nidmap
     # /etc/vx/bin/vxclustadm setmaster node_name

9. Switch a service group:

   ::

     [root@xha239195 ~]# hagrp -state kc_sg
     #Group       Attribute             System     Value
     kc_sg        State                 xha239194  |ONLINE|
     kc_sg        State                 xha239195  |OFFLINE|
     [root@xha239195 ~]# hagrp -switch kc_sg -to xha239195
     [root@xha239195 ~]# hagrp -state kc_sg
     #Group       Attribute             System     Value
     kc_sg        State                 xha239194  |OFFLINE|
     kc_sg        State                 xha239195  |ONLINE|

CFS/Cluster File System
-----------------------

1. Check CFS status

   ::

     # cfscluster status
       NODE         CLUSTER MANAGER STATE            CVM STATE
     serverA        running                        not-running
     serverB        running                        not-running
     serverC        running                        not-running
     serverD        running                        not-running

       Error: V-35-41: Cluster not configured for data sharing application

     # vxdctl -c mode
     mode: enabled: cluster inactive

     # /etc/vx/bin/vxclustadm nidmap
     Out of cluster: No mapping information available

     # /etc/vx/bin/vxclustadm -v nodestate
     state: out of clusterf

     # hastatus -sum

     -- SYSTEM STATE
     -- System               State                Frozen

     A  serverA             RUNNING              0
     A  serverB             RUNNING              0
     A  serverC             RUNNING              0
     A  serverD             RUNNING              0

2. Configure CFS

   ::

     # cfscluster config

             The cluster configuration information as read from cluster
             configuration file is as follows.
                     Cluster : MyCluster
                     Nodes   : serverA serverB serverC serverD


             You will now be prompted to enter the information pertaining
             to the cluster and the individual nodes.

             Specify whether you would like to use GAB messaging or TCP/UDP
             messaging. If you choose gab messaging then you will not have
             to configure IP addresses. Otherwise you will have to provide
             IP addresses for all the nodes in the cluster.

             ------- Following is the summary of the information: ------
                     Cluster         : MyCluster
                     Nodes           : serverA serverB serverC serverD
                     Transport       : gab
             -----------------------------------------------------------


             Waiting for the new configuration to be added.

             ========================================================

             Cluster File System Configuration is in progress...
             cfscluster: CFS Cluster Configured Successfully

     # cfscluster status

       Node             :  serverA
       Cluster Manager  :  running
       CVM state        :  running
       No mount point registered with cluster configuration


       Node             :  serverB
       Cluster Manager  :  running
       CVM state        :  running
       No mount point registered with cluster configuration


       Node             :  serverC
       Cluster Manager  :  running
       CVM state        :  running
       No mount point registered with cluster configuration


       Node             :  serverD
       Cluster Manager  :  running
       CVM state        :  running
       No mount point registered with cluster configuration

     # vxdctl -c mode
     mode: enabled: cluster active - MASTER
     master: serverA

     # /etc/vx/bin/vxclustadm nidmap
     Name                             CVM Nid    CM Nid     State
     serverA                         0          0          Joined: Master
     serverB                         1          1          Joined: Slave
     serverC                         2          2          Joined: Slave
     serverD                         3          3          Joined: Slave

     # /etc/vx/bin/vxclustadm -v nodestate
     state: cluster member
             nodeId=0
             masterId=1
             neighborId=1
             members=0xf
             joiners=0x0
             leavers=0x0
             reconfig_seqnum=0xf0a810
             vxfen=off

     # hastatus -sum

     -- SYSTEM STATE
     -- System               State                Frozen

     A  serverA             RUNNING              0
     A  serverB             RUNNING              0
     A  serverC             RUNNING              0
     A  serverD             RUNNING              0

     -- GROUP STATE
     -- Group           System               Probed     AutoDisabled    State

     B  cvm             serverA             Y          N               ONLINE
     B  cvm             serverB             Y          N               ONLINE
     B  cvm             serverC             Y          N               ONLINE
     B  cvm             serverD             Y          N               ONLINE

3. Create a shared DG

   ::

     serverA # vxdctl -c mode
     mode: enabled: cluster active - MASTER
     master: serverA

     serverA # vxdisksetup -if EMC0_1
     serverA # vxdisksetup -if EMC0_2

     serverA # vxdg -s init mysharedg mysharedg01=EMC0_1 mysharedg02=EMC0_2

     serverA # vxdg list
     mysharedg    enabled,shared,cds   1231954112.163.serverA

     serverA # cfsdgadm add mysharedg all=sw
       Disk Group is being added to cluster configuration...

     serverA # grep mysharedg /etc/VRTSvcs/conf/config/main.cf
                     ActivationMode @serverA = { mysharedg = sw }
                     ActivationMode @serverB = { mysharedg = sw }
                     ActivationMode @serverC = { mysharedg = sw }
                     ActivationMode @serverD = { mysharedg = sw }

     serverA # cfsdgadm display
       Node Name : serverA
       DISK GROUP              ACTIVATION MODE
         mysharedg                    sw

       Node Name : serverB
       DISK GROUP              ACTIVATION MODE
         mysharedg                    sw

       Node Name : serverC
       DISK GROUP              ACTIVATION MODE
         mysharedg                    sw

       Node Name : serverD
       DISK GROUP              ACTIVATION MODE
         mysharedg                    sw

4. Create volumes and format, mount

   ::

     serverA # vxassist -g mysharedg make mysharevol1 100g
     serverA # vxassist -g mysharedg make mysharevol2 100g

     serverA # mkfs -t vxfs /dev/vx/rdsk/mysharedg/mysharevol1
     serverA # mkfs -t vxfs /dev/vx/rdsk/mysharedg/mysharevol2

     serverA # cfsmntadm add mysharedg mysharevol1 /mountpoint1 all=cluster
       Mount Point is being added...
       /mountpoint1 added to the cluster-configuration

     serverA # cfsmntadm add mysharedg mysharevol2 /mountpoint2 all=cluster
       Mount Point is being added...
       /mountpoint2 added to the cluster-configuration

     serverA # cfsmntadm display -v
       Cluster Configuration for Node: serverA
       MOUNT POINT        TYPE      SHARED VOLUME     DISK GROUP       STATUS        MOUNT OPTIONS
       /mountpoint1    Regular      mysharevol1       mysharedg        NOT MOUNTED   cluster

     …...

     serverA # cfsmount /mountpoint1

File System Resource/Service Group
----------------------------------

**Note:** the file system resource/service group here is not CFS, which can be accessed concurrently. It is a resource can be accessed/mounted on one node only and need to be failed over(switch) either automaticlly through configuration or manually

Method 1 - by Commands
++++++++++++++++++++++

1. Create a DG and a volume, and format:

   ::

     # vxdg init datadg disk01=c1t1d0s2 disk02=c1t2d0s2 disk03=c1t3d0s2 disk04=c1t4d0s2
     # vxassist -g datadg make vol01 maxsize
     # mkfs.vxfs /dev/vx/rdsk/datadg/vol01

2. Prepare a mount point:

   ::

     # mkdir /vol01

3. Create a service group:

   ::

     # haconf -makerw
     # hagrp -add newgroup
     # hagrp -modify newgroup SystemList <sysa> 0 <sysb> 1
     # hagrp -modify newgroup AutoStartList <sysa>

4. Create a disk group resource based on the DG:

   ::

     # hares -add data_dg DiskGroup newgroup
     # hares -modify data_dg DiskGroup datadg

5. Create a mount resouce based on the volume in the DG:

   ::

     # hares -add vol01_mnt Mount newgroup
     # hares -modify vol01_mnt BlockDevice /dev/vx/dsk/datadg/vol01
     # hares -modify vol01_mnt FSType vxfs
     # hares -modify vol01_mnt MountPoint /vol01
     # hares -modify vol01_mnt FsckOpt %-y

6. Link the mount resouce with the DG resource group:

   ::

     # hares -link vol01_mnt data_dg

7. Enable the resource and finish configuration:

   ::

     # hagrp -enableresources newgroup
     # haconf -dump -makero

8. Online the mount resouce:

   ::

     # hares -online vol02_mnt -sys sysa

9. Switch over the resource:

   ::

     # hagrp -switch newgroup -to sysb

Method 2 - by Configuration File
++++++++++++++++++++++++++++++++

::

  # hastop -all
  # cd /etc/VRTSvcs/conf/config
  # haconf -makerw
  # vi main.cf

  --- add below definition ---
  group newgroup (
  SystemList = { sysA =0, sysB=1}
  AutoStartList = { sysA }
  )

  DiskGroup data_dg (
  DiskGroup = datadg
  )

  Mount vol01_mnt (
  MountPoint = "/vol01"
  BlockDevice = " /dev/vx/dsk/datadg/vol01"
  FSType = vxfs
  )

  vol01_mnt requires data_dg

  # haconf -dump -makero
  # hastart -local

===============
MISC Operations
===============

1. Install SF on Solaris:

   - cd <Veritas Installation Image Directory>
   - cd perl/bin
   - chmod a+x perl

2. 6.0.500 is a patch: install 6.0.1, then install 6.0.5 patch(set PATH=/opt/VRTS/bin:$PATH before installing the patch); If volume groups exist before the upgrade, vxdg deport them before the upgrade and then vxdg import them back after upgrade.
3. Find Veritas version Info

   ::

     bash-3.2# modinfo | grep -i vx
      84 fffffffff7b9c000  5ffc8 271   1  vxdmp (VxVM 6.0.500.000 Multipathing D)
      91 fffffffff7c04000 395e80 272   1  vxio (VxVM 6.0.500.000 I/O driver)
      93 fffffffff7f6d000   1350 273   1  vxspec (VxVM 6.0.500.000 control/status)
     267 fffffffff83453b0    d80 274   1  vxportal (VxFS 6.0.500.000 portal driver)
     268 fffffffff90a3000 26dbc0  21   1  vxfs (VxFS 6.0.500.000 SunOS 5.10)
     285 fffffffff938d000   c720 275   1  fdd (VxQIO 6.0.500.000 Quick I/O dri)

4. Clean Veritas after uninstallation

   - rm -rf /etc/vx
   - rm -rf /dev/vx
   - devfsadm -Cv

5. Rebuild Veritas DMP device name

   - Background: dmp device name may be not in line with PP pseudo disk name sometimes after some LUN operations such as removal. E.g., name and dmpnodename may be emcpower0c and emcpower1s2. To make dmpnode name get the name emcpower0s2, some commands need to be run;
   - Commands:

     - Vxdctl disable
     - Rm /etc/vx/disk.info or echo > /etc/vx/disk.info
     - Vxdctl enable
     - Vxconfigd -k
     - Vxdmpadm getsubpaths ===> Verify

6. Install VxVM without DMP:

   - cd <Storage Fundation Version, say SFHA6.0.1>/pkgs
   - pkgadd -d ./VRTSvxvm.pkg
   - Pkgadd -d ./VRTSvxfs.pkg
   - Pkgadd -d ./VRTSvlic.pkg
   - rm /etc/vx/reconfig.d/state.d/install-db
   - vxconfigd -k -m enable
   - vxconfigd -k -m boot
   - vxdctl init
   - vxconfigd -k
   - vxdisk list

     ::

       DEVICE       TYPE            DISK         GROUP        STATUS
       aluadisk0_0  auto:none       -            -            online invalid
       aluadisk0_1  auto:none       -            -            online invalid
       aluadisk0_2  auto:none       -            -            online invalid
       aluadisk0_3  auto:none       -            -            online invalid
       …...

7. Enable evaluation/keyless license:

   ::

     # vxkeyless set SFENT_VVR_EVAL
     The following changes will take effect.
       Remove: Storage Foundation Standard Edition
       Add: Storage Foundation Enterprise Edition with VVR (EVALUATION only)
     Continue (y/n)? y

8. List installed license:

   ::

     # vxdctl license
     All features are available:
      Mirroring
      Root Mirroring
      Concatenation
      Disk-spanning
      Striping
      RAID-5
      RAID-5 Snapshot
      VxSmartSync
      DMP (multipath enabled)
      CDS
      Dynamic LUN Expansion
      Hardware assisted copy
      DMP Native Support

9. Clean previously configuration on disks:

   ::

     bash-3.2# vxdg init indus_200g emcpower4s2 emcpower11s2 emcpower25s2 emcpower29s2 emcpower30s2
     VxVM vxdg ERROR V-5-1-2349 Device emcpower11s2 appears to be owned by disk group dg1.
     VxVM vxdg ERROR V-5-1-2349 Device emcpower30s2 appears to be owned by disk group dg2.
     bash-3.2# vxdiskunsetup -f -C emcpower11
     bash-3.2# vxdiskunsetup -f -C emcpower30
     bash-3.2# vxdisksetup -i emcpower11
     bash-3.2# vxdisksetup -i emcpower30
     ash-3.2# vxdg init indus_200g emcpower4s2 emcpower11s2 emcpower25s2 emcpower29s2 emcpower30s2

10. Grow volume size after expand a LUN:

    ::

      bash-3.2# vxprint -g indus_1c6
      TY NAME         ASSOC        KSTATE   LENGTH   PLOFFS   STATE    TUTIL0  PUTIL0
      dg indus_1c6    indus_1c6    -        -        -        -        -       -

      dm emcpower1    emcpower1    -        633534160 -       -        -       -

      v  indus_1c6_vol1 fsgen      ENABLED  633532416 -       ACTIVE   -       -
      pl indus_1c6_vol1-01 indus_1c6_vol1 ENABLED 633532416 - ACTIVE   -       -
      sd emcpower1-01 indus_1c6_vol1-01 ENABLED 633532416 0   -        -       -
      bash-3.2# vxassist -g indus_1c6 maxsize
      VxVM vxassist ERROR V-5-1-15809 No free space remaining in diskgroup indus_1c6 with given constraints
      bash-3.2# vxdisk -f -g indus_1c6 resize emcpower1
      bash-3.2# vxassist -g indus_1c6 maxsize
      Maximum volume size: 3840000 (1875Mb)
      bash-3.2# vxassist -g indus_1c6 growby indus_1c6_vol1 3840000
      bash-3.2# vxprint -g indus_1c6
      TY NAME         ASSOC        KSTATE   LENGTH   PLOFFS   STATE    TUTIL0  PUTIL0
      dg indus_1c6    indus_1c6    -        -        -        -        -       -

      dm emcpower1    emcpower1    -        637374160 -       -        -       -

      v  indus_1c6_vol1 fsgen      ENABLED  637372416 -       ACTIVE   -       -
      pl indus_1c6_vol1-01 indus_1c6_vol1 ENABLED 637372416 - ACTIVE   -       -
      sd emcpower1-01 indus_1c6_vol1-01 ENABLED 637372416 0   -        -       -

11. Grow vxfs online:

    ::

      bash-3.2# vxprint -g indus_1c6
      TY NAME         ASSOC        KSTATE   LENGTH   PLOFFS   STATE    TUTIL0  PUTIL0
      dg indus_1c6    indus_1c6    -        -        -        -        -       -

      dm emcpower1    emcpower1    -        648894160 -       -        -       -

      v  indus_1c6_vol1 fsgen      ENABLED  648892416 -       ACTIVE   -       -
      pl indus_1c6_vol1-01 indus_1c6_vol1 ENABLED 648892416 - ACTIVE   -       -
      sd emcpower1-01 indus_1c6_vol1-01 ENABLED 648892416 0   -        -       -
      bash-3.2# df | grep indus
      /indus_vxfs1       (/dev/vx/dsk/indus_1c6/indus_1c6_vol1):640905568 blocks 80113196 files
      bash-3.2# vxresize -F vxfs -g indus_1c6 indus_1c6_vol1 648894160
      bash-3.2# df | grep indus
      /indus_vxfs1       (/dev/vx/dsk/indus_1c6/indus_1c6_vol1):648585432 blocks 81073179 files
