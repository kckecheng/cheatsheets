.. contents:: Soalris Tips

========
Commands
========

Solaris 10 Software Packages
----------------------------

- pkgchk -l -p /usr/bin/ls => find the owner of a file;
- pkginfo => Get the list of all packages;
- pkginfo -l <Name> => List information such as version of a package;
- Pkgchk -l <Name> => List of files installed by a package;
- pkgadd/pkgrm => Add/remove a package;

Solaris 11 Software Packages
----------------------------

- pkg search -l/-r -o pkg.name \*svm*
- pkg search <file> ===> Find owner of a file
- pkg install -g /var/spool/pkg/EMCpower system/EMCpower
- pkg list
- Install p5p file: pkg install -g ovs-dlm-3.3.3-b1080.p5p dlm
- Install "package datastream":

  ::

    root@sun103214:/var/spool/pkg# file chef-12.12.13-1.sparc.solaris
    chef-12.12.13-1.sparc.solaris:  package datastream
    root@sun103214:/var/spool/pkg# pkgadd chef-12.12.13-1.sparc.solaris

Uninstall pacakge which is broken(Soalris 11 as an example)
-----------------------------------------------------------

::

  # pkg uninstall VRTSaslapm
  Creating Plan (Finding local manifests): /
  pkg: Unknown publisher 'Veritas'.

  Note: Copy the content of the original install media(DVD) to a directory, say /root/dvd1-sol_sparc/sol11_sparc
  # pkg set-publisher -p /root/dvd1-sol_sparc/sol11_sparc/pkgs/VRTSpkgs.p5p
  # pkg uninstall VRTSaslapm

Set a local repo
----------------

::

  pkg set-publisher -p file://<absolute path to the repo>
    --- OR---
  pkg set-publisher -G '*' -M '*' -g /net/host1/export/repoSolaris11/ solaris
  Pkg publisher ===> Verify
  Note: The official online repo: http://pkg.oracle.com/solaris/release/

Set multiple local repositories with the same publisher name
------------------------------------------------------------

This is mandatory when SRU needs to be installed (the base ISO repo or the official online repo + the SRU local repo).

::

   pkg set-publisher -G '*' -g http://pkg.oracle.com/solaris/release/ -g file:///IPS_SRU_27_4/ solaris
   pkg publisher
   pkg update --accept

Query package in the repo
-------------------------

::

  root@LXH10SER4:/var/share/pkg/repositories# pkg info -r svm
            Name: storage/svm
         Summary: Solaris Volume Manager (SVM)
     Description: The Solaris Volume Manager is a legacy mechanism for managing
                  disk storage, including creating, modifying, and using RAID-0
                  (concatenation and stripe) volumes, RAID-1 (mirror) volumes,
                  RAID-5 volumes, and soft partitions.
        Category: System/Core
           State: Not installed
       Publisher: solaris
         Version: 0.5.11
   Build Release: 5.11
          Branch: 0.175.3.0.0.22.2
  Packaging Date: May 10, 2015 03:20:18 AM
            Size: 3.29 MB
            FMRI: pkg://solaris/storage/svm@0.5.11,5.11-0.175.3.0.0.22.2:20150510T032018Z

Check Log
---------

tail -f /var/adm/messages

Rescan Devices
--------------

- cfgadm -al
- cfgadm -c configure <c#>

Determine Solaris 32/64 bit
---------------------------

::

  # isainfo -kv
  64-bit amd64 kernel modules

Dump Related
------------

- Dump file with kmem_flags enabled to have more information on who corrupted the buffer: echo "kmem_flags/W 0x1f" | mdb -kw
- kmdb = mdb -k
- echo "MpxLogMask/W 0xFFFFFFFF" | mdb -kw ---> Enable complete powerepath loggging, revert back with command "echo "MpxLogMask/W 0x60" | mdb -kw";

/etc/path_to_inst
-----------------

define mapping between physical device names and instance numbers(major num., driver name, etc.)

Grub recovery
-------------

1. Boot OS into failsafe mode;
2. Mount disk contains the OS to a directory, say /a;
3. installgrub /a/boot/grub/stage1  /a/boot/grub/stage2 /dev/rdsk/<device mounted at "/a"> (Note: based on "df" output, "/a" can be found as c1t210000FF780d0sX)
4. bootadm update-archive -R /a
5. Done
6. --- If above method does not work, try below ---
7. Replace step "c" above as:

   ::

     # cd /a/boot/grub/
     # installgrub -fm stage1 stage2 /dev/rdsk/<device mounted at "/a">

8. Replace step "d" above as: # bootadm update-archive -fv -R /a
9. Done

Control Services
----------------

- List all services: svcs
- Stop/Start/Restart a service: svcadm stop/start/restart <Name>
- Examples:

  - Restart network interface: svcadm restart physical
  - Restart syslogd: svcadm restart system-log

Mount CD/DVD
------------

::

  root@lxh10ser4:~# iostat -En | more
  c1t0d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
  Vendor: SEAGATE  Product: ST973451SSUN72G  Revision: 0302 Serial No: 0907V2BW7G
  Size: 73.41GB <73407865856 bytes>
  Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
  Illegal Request: 15 Predictive Failure Analysis: 0 Non-Aligned Writes: 0
  c4t0d0           Soft Errors: 3030 Hard Errors: 0 Transport Errors: 0
  Vendor: KVM      Product: vmDisk-CD        Revision: 0.01 Serial No:
  Size: 0.73GB <726183936 bytes>
  Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
  Illegal Request: 6 Predictive Failure Analysis: 0 Non-Aligned Writes: 0
  c3t0d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
  Vendor: TSSTcorp Product: CDDVDW TS-T633A  Revision: SR00 Serial No:
  Size: 0.00GB <0 bytes>
  Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
  Illegal Request: 1010 Predictive Failure Analysis: 0 Non-Aligned Writes: 0

  root@lxh10ser4:~#  mount -F hsfs -o ro /dev/dsk/c4t0d0<s0|p0|s2> /mnt/

Show Solaris Build Information
------------------------------

::

  root@lxh10ser4:~# pkg info kernel
            Name: system/kernel
         Summary: Core Kernel
     Description: Core operating system kernel, device drivers and other modules.
        Category: System/Core
           State: Installed
       Publisher: solaris
         Version: 0.5.11
   Build Release: 5.11
          Branch: 0.175.3.0.0.19.0
  Packaging Date: March 29, 2015 04:47:35 PM
            Size: 32.71 MB
            FMRI: pkg://solaris/system/kernel@0.5.11,5.11-0.175.3.0.0.19.0:20150329T164735Z
  ---OR---
  root@lxh10ser4:~# pkg info entire
            Name: entire
         Summary: Incorporation to lock all system packages to the same build
     Description: This package constrains system package versions to the same
                  build.  WARNING: Proper system update and correct package
                  selection depend on the presence of this incorporation.
                  Removing this package will result in an unsupported system.
        Category: Meta Packages/Incorporations
           State: Installed
       Publisher: solaris
         Version: 0.5.11 (Oracle Solaris 11.3.0.19.0)
   Build Release: 5.11
          Branch: 0.175.3.0.0.19.0
  Packaging Date: March 30, 2015 01:39:50 PM
            Size: 5.46 kB
            FMRI: pkg://solaris/entire@0.5.11,5.11-0.175.3.0.0.19.0:20150330T133950Z

Disable GUI Login
-----------------

/usr/dt/bin/dtconfig -d

Smbios
------

dmidecode on Linux

Reinstall Solaris SPARC
-----------------------
- Reboot the system;
- If system run into OK prompt, skip this step. Otherwise, run "init 0" from the normal Solaris OS;
- devalias ===> Locate the cdrom device
- boot <device name: cdrom/rcdrom/etc.> - nowin

Mount ISO
---------

::

  root@SOH13SER1PD2:~# lofiadm -a osc-4_3-24-repo-full.iso
  /dev/lofi/1
  root@SOH13SER1PD2:~# mount -F hsfs -o ro /dev/lofi/1 /sc43_iso/
  root@SOH13SER1PD2:~# umount /sc43_iso/
  root@SOH13SER1PD2:~# lofiadm -d /dev/lofi/1

Set service properties
----------------------

::

  root@SOH13SER1PD2:/var/cluster/logs# svccfg -s svc:/network/ssh:default
  svc:/network/ssh:default> help
  General commands:        help set repository end
  Manifest commands:       inventory validate import export
  Profile commands:        apply extract
  Entity commands:         list select unselect add delete describe
  Snapshot commands:       listsnap selectsnap revert
  Instance commands:       refresh
  Property group commands: listpg addpg delpg
  Property commands:       listprop setprop delprop editprop
  Customization commands:  listcust delcust
  Property value commands: addpropvalue delpropvalue setenv unsetenv
  Notification parameters: listnotify setnotify delnotify
  svc:/network/ssh:default> list
  :properties
  svc:/network/ssh:default> listprop
  general                            framework
  general/complete                  astring
  general/enabled                   boolean     true
  restarter                          framework            NONPERSISTENT
  restarter/logfile                 astring     /var/svc/log/network-ssh:default.log
  restarter/contract                count       131
  restarter/start_pid               count       702
  restarter/start_method_timestamp  time        1444982937.336603000
  restarter/start_method_waitstatus integer     0
  restarter/auxiliary_state         astring     dependencies_satisfied
  restarter/next_state              astring     none
  restarter/state                   astring     online
  restarter/state_timestamp         time        1444982937.341984000
  restarter_actions                  framework            NONPERSISTENT
  restarter_actions/enable_complete time        1444982937.347762000

Get service information such as logs, status, etc.
--------------------------------------------------

::

  root@SOH13SER1PD2:~# svcs -x /system/mdmonitor
  svc:/system/mdmonitor:default (SVM monitor)
   State: online since October 29, 2015 03:41:51 AM UTC
     See: mdmonitord(1M)
     See: /var/svc/log/system-mdmonitor:default.log
  Impact: None.

NFS configuration: share/unshare
--------------------------------

::

  root@SOH13SER1PD3:~# share -A ===> Display NFS exported
  global_clset2_d30_osc_nfs_data  /global/clset2/d30/osc_nfs/data nfs     sec=default,rw

Check existing reservation keys for Solaris cluster disks
----------------------------------------------------------

::

  root@SOH13SER1PD3:~# /usr/cluster/lib/sc/scsi -c inkeys -d /dev/did/rdsk/d3s2
  Reservation keys(2):
  0x561c71a900000001
  0x561c71a900000002

Get CPU and Mem info
--------------------

- Prtconf | grep Memory
- Psrinfo -pv

Get PCI Solt Info
-----------------

- Locate the HBA WWN and devfs-path

  ::

    ~# prtpicl -v -c scsi-fcp | egrep 'node-wwn|model|driver|devfs-path'
      :devfs-path    /pci@400/pci@2/pci@0/pci@8/SUNW,emlxs@0
      :driver-name   emlxs
      :model         LPe12002-S
      :devfs-path    /pci@400/pci@2/pci@0/pci@8/SUNW,emlxs@0,1
      :driver-name   emlxs
      :node-wwn      20  00  00  c0  dd  14  c2  b5
      :model         QLE8142
- Based on the devfs-path, locate the PCI slot info(PCIE0, A.K.A PCIE slot 0)

  ::

    ~# prtdiag -v
    /SYS/MB/PCIE0     PCIE  SUNW,emlxs-pciex10df,fc40         LPe12002-S 5.0GT/x8   2.5GT/x8
                            /pci@400/pci@2/pci@0/pci@8/SUNW,emlxs@0
    /SYS/MB/PCIE0     PCIE  SUNW,emlxs-pciex10df,fc40         LPe12002-S 5.0GT/x8   2.5GT/x8
                            /pci@400/pci@2/pci@0/pci@8/SUNW,emlxs@0,1

Access console from iLOM
------------------------

* Normal

  1. ssh root@<ilom address>
  2. start /SP/console (wait for quite a while)
  3. Refer to: https://docs.oracle.com/cd/E19910-01/E21500-01/z40002fe1298584.html

* Force: console does not accept input sometimes, follow below steps after ssh to ilom

  ::

    set /HOST send_break_action=break
    start /SP/console -force

===
SVM
===

1. Identify the disk partition for holding metadb(local disk is preferred, ~100M should be enough):

::

  root@LXH10SER4:~# format c1t0d0
  selecting c1t0d0
  [disk formatted]
  /dev/dsk/c1t0d0s1 is part of active ZFS pool rpool. Please see zpool(1M).
  /dev/dsk/c1t0d0s6 contains an SVM mdb. Please see metadb(1M).
  ……
  format> partition

  ……
  partition> print
  Current partition table (original):
  Total disk sectors available: 143358287 + 16384 (reserved sectors)

  Part      Tag    Flag     First Sector         Size         Last Sector
    0  BIOS_boot    wm               256      256.00MB          524543
    1        usr    wm            524544       60.00GB          126353663
    2 unassigned    wm                 0           0               0
    3 unassigned    wm                 0           0               0
    4 unassigned    wm                 0           0               0
    5 unassigned    wm                 0           0               0
    6       root    wm         126353664        1.00GB          128450815
    8   reserved    wm         143358208        8.00MB          143374591
  …...

2. Initialize/Check/Delete metadb:

   - Initialize:

     ::

        ~# metadb -a -f -c 3 c1t0d0s6

   - Check:

     ::

       ~ # metadb
              flags           first blk       block count
           a        u         16              8192            /dev/dsk/c1t0d0s6
           a        u         8208            8192            /dev/dsk/c1t0d0s6
           a        u         16400           8192            /dev/dsk/c1t0d0s6
       ~ # metadb -i
              flags           first blk       block count
           a        u         16              8192            /dev/dsk/c1t0d0s6
           a        u         8208            8192            /dev/dsk/c1t0d0s6
           a        u         16400           8192            /dev/dsk/c1t0d0s6
       r - replica does not have device relocation information
       o - replica active prior to last mddb configuration change
       u - replica is up to date
       l - locator for this replica was read successfully
       c - replica's location was in /etc/lvm/mddb.cf
       p - replica's location was patched in kernel
       m - replica is master, this is replica selected as input
       t - tagged data is associated with the replica
       W - replica has device write errors
       a - replica is active, commits are occurring to this replica
       M - replica had problem with master blocks
       D - replica had problem with data blocks
       F - replica had format problems
       S - replica is too small to hold current data base
       R - replica had device read errors
       B - tagged data associated with the replica is not valid

   - Delete metadb

     ::

       ~# metadb -f -d c1t0d0s6
       (Remember to label disks before creating SVM volumes on disks;
       For SVM volumes within SVM metaset, there is no need to label disks)

3. RAID0:

   - Stripe:

     ::

       root@LXH10SER4:~# metainit c_r0_s1 1 2 emcpower0c emcpower1c
       c_r0_s1: Concat/Stripe is setup
       root@LXH10SER4:~# metastat c_r0_s1
       c_r0_s1: Concat/Stripe
           Size: 41844736 blocks (19 GB)
           Stripe 0: (interlace: 1024 blocks)
               Device                Start Block  Dbase        Reloc
               /dev/dsk/emcpower0c          0     No           No
               /dev/dsk/emcpower1c      16384     No           No

       Device Relocation Information:
       Device                Reloc     Device ID
       /dev/dsk/emcpower0c   No        -
       /dev/dsk/emcpower1c   No        -

   - Concatenation:

     ::

       root@LXH10SER4:~# metainit c_r0_c1 2 1 emcpower2c 1 emcpower3c
       c_r0_c1: Concat/Stripe is setup
       root@LXH10SER4:~# metastat c_r0_c1
       c_r0_c1: Concat/Stripe
           Size: 41861120 blocks (19 GB)
           Stripe 0:
               Device                Start Block  Dbase        Reloc
               /dev/dsk/emcpower2c          0     No           No
           Stripe 1:
               Device                Start Block  Dbase        Reloc
               /dev/dsk/emcpower3c      16384     No           No

       Device Relocation Information:
       Device                Reloc     Device ID
       /dev/dsk/emcpower2c   No        -
       /dev/dsk/emcpower3c   No        -

4. RAID1:

   ::

     root@LXH10SER4:~# metainit c_r0_s21 1 2 emcpower4c emcpower5c
     c_r0_s21: Concat/Stripe is setup
     root@LXH10SER4:~# metainit c_r0_s22 1 2 emcpower6c emcpower7c
     c_r0_s22: Concat/Stripe is setup
     root@LXH10SER4:~# metastat -c
     c_r0_s22         s   19GB /dev/dsk/emcpower6c /dev/dsk/emcpower7c
     c_r0_s21         s   19GB /dev/dsk/emcpower4c /dev/dsk/emcpower5c
     c_r0_c1          s   19GB /dev/dsk/emcpower2c /dev/dsk/emcpower3c
     c_r0_s1          s   19GB /dev/dsk/emcpower0c /dev/dsk/emcpower1c
     root@LXH10SER4:~# metainit c_r0_m20 -m c_r0_s21
     c_r0_m20: Mirror is setup
     root@LXH10SER4:~# metattach c_r0_m20 c_r0_s22
     c_r0_m20: submirror c_r0_s22 is attached
     root@LXH10SER4:~# metastat -c c_r0_m20
     c_r0_m20         m   19GB c_r0_s21 c_r0_s22 (resync-1%)
         c_r0_s21     s   19GB /dev/dsk/emcpower4c /dev/dsk/emcpower5c
         c_r0_s22     s   19GB /dev/dsk/emcpower6c /dev/dsk/emcpower7c

5. RAID5:

   ::

     root@LXH10SER4:~# metainit c_r5_v1 -r emcpower8c emcpower9c emcpower10c emcpower11c emcpower12c
     c_r5_v1: RAID is setup
     root@LXH10SER4:~# metastat -c
     c_r0_m20         m   19GB c_r0_s21 c_r0_s22 (resync-32%)
         c_r0_s21     s   19GB /dev/dsk/emcpower4c /dev/dsk/emcpower5c
         c_r0_s22     s   19GB /dev/dsk/emcpower6c /dev/dsk/emcpower7c
     c_r5_v1          r   39GB /dev/dsk/emcpower8c (initializing) /dev/dsk/emcpower9c (initializing)...
     c_r0_c1          s   19GB /dev/dsk/emcpower2c /dev/dsk/emcpower3c
     c_r0_s1          s   19GB /dev/dsk/emcpower0c /dev/dsk/emcpower1c
     root@LXH10SER4:~# metastat c_r5_v1
     c_r5_v1: RAID
         State: Initializing
         Initialization in progress: 47.6% done
         Interlace: 1024 blocks
         Size: 83640320 blocks (39 GB)
     Original device:
         Size: 83644416 blocks (39 GB)
             Device                 Start Block  Dbase        State Reloc  Hot Spare
             /dev/dsk/emcpower8c       26634        No Initializing   No
             /dev/dsk/emcpower9c       26634        No Initializing   No
             /dev/dsk/emcpower10c      22794        No Initializing   No
             /dev/dsk/emcpower11c      26634        No Initializing   No
             /dev/dsk/emcpower12c      26634        No Initializing   No

     Device Relocation Information:
     Device                 Reloc    Device ID
     /dev/dsk/emcpower8c    No       -
     /dev/dsk/emcpower9c    No       -
     /dev/dsk/emcpower10c   No       -
     /dev/dsk/emcpower11c   No       -
     /dev/dsk/emcpower12c   No       -

6. Destroy metadevice:

   - Destroy RAID0/5:

     ::

       root@LXH10SER4:~# metastat -c
       x_r5_v1          r   39GB /dev/dsk/emcpower24c /dev/dsk/emcpower25c /dev/dsk/emcpower26c......
       x_r0_c1          s   19GB /dev/dsk/emcpower18c /dev/dsk/emcpower19c
       root@LXH10SER4:~# metaclear x_r0_c1
       x_r0_c1: Concat/Stripe is cleared
       root@LXH10SER4:~# metaclear x_r5_v1
       x_r5_v1: RAID is cleared

   - Destroy RAID1:

     ::

       root@LXH10SER4:~# metastat -c
       c_r0_m20         m   19GB c_r0_s21 (maint) c_r0_s22 (maint)
           c_r0_s21     s   19GB /dev/dsk/emcpower4c /dev/dsk/emcpower5c
           c_r0_s22     s   19GB /dev/dsk/emcpower6c /dev/dsk/emcpower7c
       root@LXH10SER4:~# metaclear -r c_r0_m20
       c_r0_m20: Mirror is cleared
       c_r0_s21: Concat/Stripe is cleared
       c_r0_s22: Concat/Stripe is cleared

7. MISC Commands:

   - Display configurations for each metadevice:

     ::

       root@LXH10SER4:~# metastat -p
       x_r0_m20 -m /dev/md/rdsk/x_r0_s21 /dev/md/rdsk/x_r0_s22 1
       x_r0_s21 1 2 /dev/rdsk/emcpower20c /dev/rdsk/emcpower21c -i 1024b
       x_r0_s22 1 2 /dev/rdsk/emcpower22c /dev/rdsk/emcpower23c -i 1024b
       c_r0_m20 -m /dev/md/rdsk/c_r0_s21 /dev/md/rdsk/c_r0_s22 1
       c_r0_s21 1 2 /dev/rdsk/emcpower4c /dev/rdsk/emcpower5c -i 1024b
       c_r0_s22 1 2 /dev/rdsk/emcpower6c /dev/rdsk/emcpower7c -i 1024b
       x_r5_v1 -r /dev/rdsk/emcpower24c /dev/rdsk/emcpower25c /dev/rdsk/emcpower26c ......
       c_r5_v1 -r /dev/rdsk/emcpower8c /dev/rdsk/emcpower9c /dev/rdsk/emcpower10c ......
       x_r0_c1 2 1 /dev/rdsk/emcpower18c \
                1 /dev/rdsk/emcpower19c
       x_r0_s1 1 2 /dev/rdsk/emcpower16c /dev/rdsk/emcpower17c -i 1024b
       c_r0_c1 2 1 /dev/rdsk/emcpower2c \
                1 /dev/rdsk/emcpower3c
       c_r0_s1 1 2 /dev/rdsk/emcpower0c /dev/rdsk/emcpower1c -i 1024b

   - Display a summary of all metedevices:

     ::

       root@LXH10SER4:~# metastat -c
       x_r0_m20         m   19GB x_r0_s21 (maint) x_r0_s22 (maint)
           x_r0_s21     s   19GB /dev/dsk/emcpower20c /dev/dsk/emcpower21c
           x_r0_s22     s   19GB /dev/dsk/emcpower22c /dev/dsk/emcpower23c
       c_r0_m20         m   19GB c_r0_s21 (maint) c_r0_s22 (maint)
           c_r0_s21     s   19GB /dev/dsk/emcpower4c /dev/dsk/emcpower5c
           c_r0_s22     s   19GB /dev/dsk/emcpower6c /dev/dsk/emcpower7c
       x_r5_v1          r   39GB /dev/dsk/emcpower24c /dev/dsk/emcpower25c ......
       c_r5_v1          r   39GB /dev/dsk/emcpower8c /dev/dsk/emcpower9c ......
       x_r0_c1          s   19GB /dev/dsk/emcpower18c /dev/dsk/emcpower19c
       x_r0_s1          s   19GB /dev/dsk/emcpower16c /dev/dsk/emcpower17c
       c_r0_c1          s   19GB /dev/dsk/emcpower2c /dev/dsk/emcpower3c
       c_r0_s1          s   19GB /dev/dsk/emcpower0c /dev/dsk/emcpower1c

   - If a metaset is used, metastat won’t display information without option -s <metaset name>

8. Create UFS file system for meta device:

   ::

     bash-3.2# newfs /dev/md/rdsk/d11
     newfs: construct a new file system /dev/md/rdsk/d11: (y/n)? y
     /dev/md/rdsk/d11:       67119536 sectors in 246763 cylinders of 16 tracks, 17 sectors
             32773.2MB in 1210 cyl groups (204 c/g, 27.09MB/g, 3456 i/g)
     super-block backups (for fsck -F ufs -o b=#) at:
      32, 55552, 111072, 166592, 222112, 277632, 333152, 388672, 444192, 499712,
     Initializing cylinder groups:
     .......................
     super-block backups for last 10 cylinder groups at:
      66585632, 66641152, 66696672, 66752192, 66807712, 66863232, 66918752,
      66974272, 67029792, 67085312
     bash-3.2# mount -F ufs /dev/md/dsk/d11 /svm_indus1/

9. Create a SVM volume within a metaset:

   ::

     root@sun103215:~# metaset -s oscsr-test -a -h sun103215
     root@sun103215:~# metaset -s oscsr-test

     Set name = oscsr-test, Set number = 1

     Host                Owner
       sun103215
     root@sun103215:~# metaset -s oscsr-test -a c0t6000144000000010F00268EC3F369388d0
     (Note: label disks before this step)
     root@sun103215:~# metaset -s oscsr-test

     Set name = oscsr-test, Set number = 1

     Host                Owner
       sun103215          Yes

     Drive                                   Dbase

     c0t6000144000000010F00268EC3F369388d0   Yes
     root@sun103215:~# metainit -s oscsr-test d60 1 1 c0t6000144000000010F00268EC3F369388d0s0
     oscsr-test/d60: Concat/Stripe is setup
     root@sun103215:~# metastat -s oscsr-test
     oscsr-test/d60: Concat/Stripe
         Size: 20963328 blocks (10.0 GB)
         Stripe 0:
             Device                                    Start Block  Dbase    Reloc
             c0t6000144000000010F00268EC3F369388d0s0          0     No       Yes

     Device Relocation Information:
     Device                                  Reloc   Device ID
     c0t6000144000000010F00268EC3F369388d0   Yes     id1,ssd@n6000144000000010f00268ec3f369388

10. Import SVM metaset

    ::

      root@sun103214:~# metastat -s xio_test1
      xio_test1/d101: Concat/Stripe
          Size: 41846784 blocks (19 GB)
          Stripe 0: (interlace: 1024 blocks)
              Device                    Start Block  Dbase    Reloc
              c0t514F0C5B14C0001Dd0s0          0     No       Yes
              c0t514F0C5B14C0001Ed0s0          0     No       Yes

      Device Relocation Information:
      Device                  Reloc   Device ID
      c0t514F0C5B14C0001Dd0   Yes     id1,ssd@n514f0c5b14c0001d
      c0t514F0C5B14C0001Ed0   Yes     id1,ssd@n514f0c5b14c0001e

      root@sun103215:~# metaimport -r -v
      metaimport: sun103215: /dev/did/rdsk/d22: Invalid argument

      partial 3 /dev/dsk/c0t514F0C5B14C0001Dd0s7 5,5s7,blk 6,6s7,raw
      partial 3 /dev/dsk/c0t514F0C5B14C0001Ed0s7 6,6s7,blk 6,6s7,raw
      ……
      root@sun103215:~# metaimport -s xio_test1 -f -v c0t514F0C5B14C0001Dd0

11. Create SVM volume with md.tab:

    ::

      root@sun103214:~# cat /etc/lvm/md.tab
      xioset1/d11 1 2 /dev/did/rdsk/d5s0 /dev/did/rdsk/d6s0
      vmaxset1/d21 1 2 /dev/did/rdsk/d11s0 /dev/did/rdsk/d12s0
      vnxset1/d31 1 2 /dev/did/rdsk/d23s0 /dev/did/rdsk/d24s0
      root@sun103214:~# metainit -s ovm_set1 -a
      ovm_set1/d41: Concat/Stripe is setup
      root@sun103214:~# metastat -s ovm_set1
      ovm_set1/d41: Concat/Stripe
          Size: 50263808 blocks (23 GB)
          Stripe 0: (interlace: 1024 blocks)
              Device   Start Block  Dbase     Reloc
              d7s0            0     No        Yes
              d13s0           0     No        Yes
              d25s0           0     No        Yes

      Device Relocation Information:
      Device   Reloc  Device ID
      d7    Yes       id1,did@n514f0c5b14c0001f
      d13   Yes       id1,did@n60000970000196701162533030333138
      d25   Yes       id1,did@n60060160882037003a200d1dca94e511

=======
Network
=======

1. NCP - Solaris(since 11) uses network configuration profile  to control how IP address will be configured:

   - Manual - DefaultFixed
   - Automatic
   - "netadm" can be used to show current NCP:

     ::

       root@LXH10SER4:~# netadm  list
        TYPE        PROFILE        STATE
        ncp         Automatic      disabled
        ncp         DefaultFixed   online
        loc         DefaultFixed   online
        loc         Automatic      offline
        loc         NoNet          offline

   - If NCP=Automatic exists, DHCP will be used to assign IP. To disable it, just enable "DefaultFixed"

     ::

       root@LXH10SER4:~# netadm enable -p ncp DefaultFixed

2. Find available network interface:

   ::

     root@LXH10SER4:~# dladm show-phys
     LINK              MEDIA                STATE      SPEED  DUPLEX    DEVICE
     net7              Ethernet             unknown    0      unknown   ixgbe1
     net8              Ethernet             up         10     full      usbecm0
     net5              Ethernet             down       0      unknown   qlcnic1
     net2              Ethernet             unknown    0      unknown   igb2
     net0              Ethernet             up         1000   full      igb0
     net4              Ethernet             down       0      unknown   qlcnic0
     net6              Ethernet             unknown    0      unknown   ixgbe0
     net3              Ethernet             unknown    0      unknown   igb3
     net1              Ethernet             unknown    0      unknown   igb1

3. Configure IP address(non-persistent):

   ::

     root@LXH10SER4:~# dladm show-phys | grep -i ixgbe
     net7              Ethernet             unknown    0      unknown   ixgbe1
     net6              Ethernet             unknown    0      unknown   ixgbe0
     root@LXH10SER4:~# ifconfig net6 plumb
     root@LXH10SER4:~# ifconfig net7 plumb
     root@LXH10SER4:~# dladm show-phys | grep -i ixgbe
     net7              Ethernet             up         10000  full      ixgbe1
     net6              Ethernet             up         10000  full      ixgbe0
     root@LXH10SER4:~# ifconfig net6 20.10.10.83 netmask 255.255.255.0 up
     root@LXH10SER4:~# ifconfig net7 20.10.11.83 netmask 255.255.255.0 up
     root@LXH10SER4:~# ipadm
     NAME              CLASS/TYPE STATE        UNDER      ADDR
     lo0               loopback   ok           --         --
        lo0/v4         static     ok           --         127.0.0.1/8
        lo0/v6         static     ok           --         ::1/128
     net0              ip         ok           --         --
        net0/v4        static     ok           --         10.108.106.83/24
     net6              ip         ok           --         --
        net6/v4        static     ok           --         20.10.10.83/24
     net7              ip         ok           --         --
        net7/v4        static     ok           --         20.10.11.83/24
     net8              ip         ok           --         --
        net8/v4        static     ok           --         169.254.182.77/24
     root@LXH10SER4:~# ping 20.10.10.71
     20.10.10.71 is alive
     root@LXH10SER4:~# ping 20.10.11.71
     20.10.11.71 is alive

4. Configure IP address(persistent):

   ::

     root@LXH10SER4:~# dladm show-phys | grep -I ixgbe
     LINK              MEDIA                STATE      SPEED  DUPLEX    DEVICE
     net7              Ethernet             unknown    0      unknown   ixgbe1
     net6              Ethernet             unknown    0      unknown   ixgbe0
     root@LXH10SER4:~# ipadm create-ip net6
     root@LXH10SER4:~# ipadm create-ip net7
     root@LXH10SER4:~# dladm show-phys | grep -i ixgbe
     net7              Ethernet             up         10000  full      ixgbe1
     net6              Ethernet             up         10000  full      ixgbe0
     root@LXH10SER4:~# ipadm show-if
     IFNAME     CLASS    STATE    ACTIVE OVER
     lo0        loopback ok       yes    --
     net0       ip       ok       yes    --
     net6       ip       down     no     --
     net7       ip       down     no     --
     net8       ip       down     no     --
     root@LXH10SER4:~# ipadm create-addr -T static -a 20.10.10.83/24 net6
     net6/v4
     root@LXH10SER4:~# ipadm create-addr -T static -a 20.10.11.83/24 net7
     net7/v4
     root@LXH10SER4:~# ipadm show-addr
     ADDROBJ           TYPE     STATE        ADDR
     lo0/v4            static   ok           127.0.0.1/8
     net0/v4           static   ok           10.108.106.83/24
     net6/v4           static   ok           20.10.10.83/24
     net7/v4           static   ok           20.10.11.83/24
     lo0/v6            static   ok           ::1/128
     net8/v4           static   disabled     169.254.182.77/24

5. Remove an IP addr:

   ::

     root@LXH10SER4:~# ipadm delete-addr net7/v4

6. Add a default route(ignore '-p' will add a route temporarily):

   ::

     root@LXH10SER4:~# route -p show
     No persistent routes are defined
     root@LXH10SER4:~# route -p add default 10.108.106.1
     add net default: gateway 10.108.106.1: entry exists
     add persistent net default: gateway 10.108.106.1
     root@LXH10SER4:~# route -p show
     persistent: route add default 10.108.106.1
     (To delete: route -p delete)

7. List all route:

   ::

     # netstat -nr

8. DNS Client Configuration:

   ::

     # svccfg -s network/dns/client
     svc:/network/dns/client> setprop config/search = astring: ("test.com" "service.test.com") ===>(Optional)
     svc:/network/dns/client> setprop config/nameserver = net_address: (192.168.10.10 192.168.10.11)
     svc:/network/dns/client> exit

     #svcadm refresh dns/client
     #svcadm restart dns/client
     # cat /etc/resolv.conf  ===> To verify

     # svccfg -s system/name-service/switch
     svc:/system/name-service/switch> setprop config/host = astring: "files dns"
     svc:/system/name-service/switch>exit

     #svcadm refresh name-service/switch
     #svcadm restart  name-service/switch

     grep host /etc/nsswitch.conf ===> To verify

9. Change Domain name

   ::

     root@sun103214:~# echo sun103214.lss.emc.com > /etc/defaultdomain
     root@sun103214:~# domainname sun103214.lss.emc.com

10. Solaris 11 change hostname:

    ::

      root@sun103162:~# svccfg -s system/identity:node listprop config
      config                       application
      config/enable_mapping       boolean     true
      config/ignore_dhcp_hostname boolean     false
      config/loopback             astring
      config/nodename             astring     sun103162
      root@sun103162:~# svccfg -s system/identity:node setprop config/nodename="sun103163"
      root@sun103162:~# svccfg -s system/identity:node setprop config/loopback="sun103163"
      root@sun103162:~# svccfg -s system/identity:node refresh
      root@sun103162:~# svcadm restart system/identity:node
      root@sun103162:~# svccfg -s system/identity:node listprop config
      config                       application
      config/enable_mapping       boolean     true
      config/ignore_dhcp_hostname boolean     false
      config/nodename             astring     sun103163

      config/loopback             astring     sun103163

=====
MPxIO
=====

1. MPxIO is also called STMS
2. Enable/Disable MPxIO: stmsboot -e/-d
3. Get help: mpathadm -?
4. List pseudo devices and path summary:

   ::

     bash-3.2# mpathadm list lu
             /dev/rdsk/c9t60060160D3403C0055FCBE557B38B8DCd0s2
                     Total Path Count: 4
                     Operational Path Count: 4
             /dev/rdsk/c9t60060160D3403C0045FCBE555DD19203d0s2
                     Total Path Count: 4
                     Operational Path Count: 4
             /dev/rdsk/c9t60060160D3403C0039FCBE556679DD08d0s2
                     Total Path Count: 4
                     Operational Path Count: 4

5. Show detailed path information for a pseudo device:

   ::

     bash-3.2# mpathadm show lu /dev/rdsk/c9t60000970000196701162533030313741d0s2
     Logical Unit:  /dev/rdsk/c9t60000970000196701162533030313741d0s2
             mpath-support:  libmpscsi_vhci.so
             Vendor:  EMC
             Product:  SYMMETRIX
             Revision:  5977
             Name Type:  unknown type
             Name:  60000970000196701162533030313741
             Asymmetric:  no
             Current Load Balance:  round-robin
             Logical Unit Group ID:  NA
             Auto Failback:  on
             Auto Probing:  NA

             Paths:
                     Initiator Port Name:  10000090faa8ae83
                     Target Port Name:  500009735012284b
                     Override Path:  NA
                     Path State:  OK
                     Disabled:  no

6. List native device to MPxIO pseudo device name mapping

   ::

     bash-3.2# stmsboot -L
     non-STMS device name                    STMS device name
     ------------------------------------------------------------------
     /dev/rdsk/c8t500009735012284Bd23        /dev/rdsk/c9t60000970000196701162533030314544d0
     /dev/rdsk/c8t500009735012284Bd22        /dev/rdsk/c9t60000970000196701162533030314543d0
     /dev/rdsk/c8t500009735012284Bd21        /dev/rdsk/c9t60000970000196701162533030314542d0
     /dev/rdsk/c8t500009735012284Bd20        /dev/rdsk/c9t60000970000196701162533030314541d0
     /dev/rdsk/c8t500009735012284Bd19        /dev/rdsk/c9t60000970000196701162533030314539d0
     …...

7. Make MPxIO works for both VMAX and XtremIO

   ::

     Edit /kernel/drv/scsi_vhci.conf (Solaris 10) with below content:
     device-type-scsi-options-list =
     "EMC     SYMMETRIX", "symmetric-option",
     "XtremIO XtremApp", "symmetric-option";

     symmetric-option = 0x1000000;

8. MPxIO device will be shown as c0**** in format command:

   ::

     root@SOH13SER1PD2:~# echo | format
     …...
     3. c0t6000144000000010E00308ACF28AB439d0 <EMC-Invista-5500 cyl 5118 alt 2 hd 16 sec 256> ===> MPxIO Pseudo
               /scsi_vhci/ssd@g6000144000000010e00308acf28ab439
     …...
     10. c1t500014426002F201d1 <EMC-Invista-5400 cyl 5118 alt 2 hd 16 sec 256>  ARG_10C ===> Native
               /pci@b00/pci@1/pci@0/pci@4/SUNW,emlxs@0/fp@0,0/ssd@w500014426002f201,1

=======
Cluster
=======

1. Show details of cluster status: scstat
2. Remove a metaset/device group exists in "cluster status" but not "metaset"

   ::

     #/usr/cluster/lib/sc/dcs_config -c remove -s <name>

3. Change owner of a device group:

   ::

     # clresourcegroup switch [-n node-zone-list] resource-group

4. Mount a global filesystem:

   ::

     # mount -g /dev/md/xio59_set1/dsk/xio59_set1_r0s0 /global/xio59_set1/d4/

===============
Disk Operations
===============

1. cfgadm -al -o show_FCP_dev => Show FC connections
2. fcinfo hba-port -l ---> Get HBA info
3. luxadm:

   - luxadm -e dump_map /dev/cfg/c8
   - luxadm -e port
   - luxadm -e dump_map /devices/pci@400/pci@1/pci@0/pci@8/SUNW,qlc@0,1/fp@0,0:devctl
   - luxadm -e forcelip /devices/pci@400/pci@1/pci@0/pci@8/SUNW,qlc@0/fp@0,0:devctl
   - luxadm display 20000024ff4d1a2c
   - luxadm -e offline /devices/pci@400/pci@1/pci@0/pci@8/SUNW,qlc@0
   - luxadm -e online /devices/pci@400/pci@1/pci@0/pci@8/SUNW,qlc@0

4. devfsadm:

   - devfsadm -i emcp ===> Configure driver emcp
   - devfsadm -Cv ===> Prompt devfsadm to cleanup dangling /dev links that are not normally removed

5. Discover newly provisioned disks

    - cfgadm -al
    - devfsadm -c disk
    - luxadm probe
    - echo | format

6. Identify HBA port based on path name

   ::

     bash-3.2# powermt display dev=emcpower48a
     Pseudo name=emcpower48a
     CLARiiON ID=FNM00150600587 [Host_5]
     Logical device ID=60060160D3403C00A4A63855FFB706DD [KC_SOH11SER12-09]
     state=alive; policy=CLAROpt; queued-IOs=0
     Owner: default=SP B, current=SP B       Array failover mode: 4
     ==============================================================================
     --------------- Host ---------------   - Stor -  -- I/O Path --   -- Stats ---
     ###  HW Path               I/O Paths    Interf.  Mode     State   Q-IOs Errors
     ==============================================================================
     3073 pci@0,0/pci8086,340c@5/pci1077,138@0,1/fp@0,0 c5t5006016909200C7Ad9s0 SP B1......
     3072 pci@0,0/pci8086,340c@5/pci1077,138@0/fp@0,0 c4t5006016109200C7Ad9s0 SP A1......

     bash-3.2# luxadm -e dump_map /devices/pci@0,0/pci8086,340c@5/pci1077,138@0,1/fp@0,0
     Pos  Port_ID Hard_Addr Port WWN         Node WWN         Type
     0    680740  0        500009735008845f 50000973500887ff 0x0  (Disk device)
     1    680600  0        5000097350088444 50000973500887ff 0x0  (Disk device)
     2    110011  0        5006016909200c7a 5006016089200c7a 0x0  (Disk device)
     3    b50000  0        2101001b323cc965 2001001b323cc965 0x1f (Unknown Type,Host Bus Adapter)
     bash-3.2# luxadm -e dump_map /devices/pci@0,0/pci8086,340c@5/pci1077,138@0/fp@0,0
     Pos  Port_ID Hard_Addr Port WWN         Node WWN         Type
     0    330700  0        5006016109200c7a 5006016089200c7a 0x0  (Disk device)
     1    1f2600  0        21000024ff580be0 20000024ff580be0 0x0  (Disk device)
     2    1eaf00  0        500009735008849f 50000973500887ff 0x0  (Disk device)
     3    1ecd40  0        5000097350088484 50000973500887ff 0x0  (Disk device)
     4    1f2400  0        21000024ff580eb4 20000024ff580eb4 0x0  (Disk device)
     5    280a00  0        2100001b321cc965 2000001b321cc965 0x1f (Unknown Type,Host Bus Adapter)
     bash-3.2# luxadm -e port
     /devices/pci@0,0/pci8086,340c@5/pci1077,138@0/fp@0,0:devctl        CONNECTED
     /devices/pci@0,0/pci8086,340c@5/pci1077,138@0,1/fp@0,0:devctl      CONNECTED
     /devices/pci@0,0/pci8086,340d@6/pci10df,f100@0/fp@0,0:devctl       NOT CONNECTED
     /devices/pci@0,0/pci8086,340d@6/pci10df,f100@0,1/fp@0,0:devctl     CONNECTED
     bash-3.2# fcinfo hba-port
     HBA Port WWN: 2100001b321cc965
             OS Device Name: /dev/cfg/c4
             Manufacturer: QLogic Corp.
             Model: QLE2462
             Firmware Version: 05.06.04
             FCode/BIOS Version:  BIOS: 1.08; fcode: 1.13; EFI: 1.02;
             Serial Number: RFC0832S61065
             Driver Name: qlc
             Driver Version: 20120717-4.01
             Type: N-port
             State: online
             Supported Speeds: 1Gb 2Gb 4Gb
             Current Speed: 4Gb
             Node WWN: 2000001b321cc965
     HBA Port WWN: 2101001b323cc965
             OS Device Name: /dev/cfg/c5
             Manufacturer: QLogic Corp.
             Model: QLE2462
             Firmware Version: 05.06.04
             FCode/BIOS Version:  BIOS: 1.08; fcode: 1.13; EFI: 1.02;
             Serial Number: RFC0832S61065
             Driver Name: qlc
             Driver Version: 20120717-4.01
             Type: N-port
             State: online
             Supported Speeds: 1Gb 2Gb 4Gb
             Current Speed: 4Gb
             Node WWN: 2001001b323cc965
7. Display a summary of all disks(including CD/DVD):

   - iostat

     ::

       # iostat -En
       c3t0d0           Soft Errors: 0 Hard Errors: 0 Transport Errors: 0
       Vendor: ORACLE   Product: SSM              Revision: PMAP Serial No:
       Size: 4.01GB <4009754624 bytes>
       Media Error: 0 Device Not Ready: 0 No Device: 0 Recoverable: 0
       Illegal Request: 23 Predictive Failure Analysis: 0
       c2t500009735008849Cd0 Soft Errors: 0 Hard Errors: 1 Transport Errors: 0
       Vendor: EMC      Product: SYMMETRIX        Revision: 5977 Serial No: 700545001000
       Size: 0.01GB <5897728 bytes>
       Media Error: 0 Device Not Ready: 0 No Device: 1 Recoverable: 0
       Illegal Request: 0 Predictive Failure Analysis: 0

   - echo | format

     ::

       # echo | format
       Searching for disks...done

       c2t500009735008849Cd0: configured with capacity of 1.88MB
       c10t500009735008849Cd0: configured with capacity of 1.88MB
       emcpower0p3: configured with capacity of 5.00GB
       emcpower1p4: configured with capacity of 1022.98MB
       emcpower6p2: configured with capacity of 5.00GB
       emcpower8p4: configured with capacity of 5.00GB
       ......

8. Show detail SAN LUN information":

   ::

     Pseudo name=emcpower8a
     VNX ID=APM00140800017 [doris_SOH2SER2_Qlogic]
     Logical device ID=6006016021003500D7D9099BB7EFE311 []
     state=alive; policy=CLAROpt; queued-IOs=0
     Owner: default=SP B, current=SP B       Array failover mode: 4
     ==============================================================================
     --------------- Host ---------------   - Stor -  -- I/O Path --   -- Stats ---
     ###  HW Path               I/O Paths    Interf.  Mode     State   Q-IOs Errors
     ==============================================================================
     3074 pci@0,0/pci8086,e08@3/pci10df,e20e@0,2/fp@0,0 c1t5006016E086029A9d3s0 SP B6......

     bash-3.2# luxadm display /dev/rdsk/c1t5006016E086029A9d3s2
     DEVICE PROPERTIES for disk: /dev/rdsk/c1t5006016E086029A9d3s2
       Vendor:               DGC
       Product ID:           RAID 5
       Revision:             0533
       Serial Num:           APM00140800017
       Unformatted capacity: 5120.000 MBytes
       Read Cache:           Enabled
         Minimum prefetch:   0x0
         Maximum prefetch:   0x0
       Device Type:          Disk device
       Path(s):

       /dev/rdsk/c1t5006016E086029A9d3s2
       /devices/pci@0,0/pci8086,e08@3/pci10df,e20e@0,2/fp@0,0/disk@w5006016e086029a9,3:c,raw
        Controller           /dev/cfg/c1
         Device Address              5006016e086029a9,3
         Host controller port WWN    10000090fa43fcd6

9. mpxio-disable="yes" in /kernel/drv/fp.conf, /kernel/drv/iscsi.conf, /kernel/drv/scsi_vhci.conf to make Powerpath manages LUNs over MPxIO;
10. MPxIO now is called STMS which can also be controlled through command stmsboot -e/-d;
11. /etc/vfstab ===> /etc/fstab on Linux
12. Add devices to Solaris:

    - Provisioning LUNs at storage array side;
    - devfs -Cv
    - cfgadm -al
    - cfgadm -c configure /dev/cfg/c<X> ===> device name can be gotten from "fcinfo hba-port -l"
    - echo | format
    - powermt check; powermt config

13. Label a disk:

    ::

      # format emcpower18a

      emcpower18a: configured with capacity of 19.99GB
      selecting emcpower18a
      [disk formatted]


      FORMAT MENU:
              disk       - select a disk
              type       - select (define) a disk type
              partition  - select (define) a partition table
              current    - describe the current disk
              format     - format and analyze the disk
              repair     - repair a defective sector
              label      - write label to the disk
              analyze    - surface analysis
              defect     - defect list management
              backup     - search for backup labels
              verify     - read and display labels
              save       - save new disk/partition definitions
              inquiry    - show disk ID
              volname    - set 8-character volume name
              !<cmd>     - execute <cmd>, then return
              quit
      format> label
      Ready to label disk, continue? yes

      format> quit
      21. Another way to list all LUNs:
      bash-3.2# fcinfo logical-unit
      OS Device Name: /dev/rdsk/c5t5006016909200C7Ad0s2
      OS Device Name: /dev/rdsk/c5t5006016909200C7Ad1s2
      …...

14. Check if two devices are from the same array:

    - Get serial num. of the first device:

      ::

        bash-3.2# luxadm display /dev/rdsk/c4t21000024FF580588d0s2
        DEVICE PROPERTIES for disk: /dev/rdsk/c4t21000024FF580588d0s2
          Vendor:               XtremIO
          Product ID:           XtremApp
          Revision:             4000
          Serial Num:           APM00141802544
          Unformatted capacity: 102400.000 Mbytes
        …...

    - Get the serial num. of the second device:

      ::

        bash-3.2# luxadm display /dev/rdsk/c5t21000024FF580589d0s2
        DEVICE PROPERTIES for disk: /dev/rdsk/c5t21000024FF580589d0s2
          Vendor:               XtremIO
          Product ID:           XtremApp
          Revision:             4000
          Serial Num:           APM00141802544
          Unformatted capacity: 102400.000 MBytes
        ……

    - Since serial num. are the same, hence the same array(Notice: some times, serial num. of an array may be consisted as "SAN ID" + "LUN ID". Under such condition, the serial num. field may be different)

15. Solaris format:  after changing slice/partition with format, "label" should be used again to save the changes

    ::

      root@LXH10SER4:~# format -e
      Searching for disks...done


      AVAILABLE DISK SELECTIONS:
             0. c1t0d0 <SEAGATE-ST973451SSUN72G-0302-68.37GB>
                /pci@0,0/pci8086,340c@5/pci1000,3150@0/sd@0,0
                /dev/chassis/SYS/BAY-0/disk
      Specify disk (enter its number): 0
      selecting c1t0d0
      [disk formatted]
      /dev/dsk/c1t0d0s1 is part of active ZFS pool rpool. Please see zpool(1M).
      ……
      format> partition
      ……
      partition> print
      Current partition table (original):
      Total disk sectors available: 143358287 + 16384 (reserved sectors)

      Part      Tag    Flag     First Sector         Size         Last Sector
        0  BIOS_boot    wm               256      256.00MB          524543
        1        usr    wm            524544       60.00GB          126353663
        2 unassigned    wm                 0           0               0
        3 unassigned    wm                 0           0               0
        4 unassigned    wm                 0           0               0
        5 unassigned    wm                 0           0               0
        6 unassigned    wm                 0           0               0
        7 unassigned    wm                 0           0               0
        8   reserved    wm         143358208        8.00MB          143374591
      ……
      partition> 6
      Part      Tag    Flag     First Sector         Size         Last Sector
        6 unassigned    wm                 0           0               0

      Enter partition id tag[usr]: ?
      Expecting one of the following: (abbreviations ok):
              unassigned    boot          root          swap
              usr           backup        stand         var
              home          alternates    reserved      system
              BIOS_boot

      Enter partition id tag[usr]: root
      Enter partition permission flags[wm]:
      Enter new starting sector[143374592]: 126353664
      Enter partition size[0b, 126353663e, 0mb, 0gb, 0tb]: 1gb
      partition> print
      Current partition table (unnamed):
      Total disk sectors available: 143358287 + 16384 (reserved sectors)

      Part      Tag    Flag     First Sector         Size         Last Sector
        0  BIOS_boot    wm               256      256.00MB          524543
        1        usr    wm            524544       60.00GB          126353663
        2 unassigned    wm                 0           0               0
        3 unassigned    wm                 0           0               0
        4 unassigned    wm                 0           0               0
        5 unassigned    wm                 0           0               0
        6       root    wm         126353664        1.00GB          128450815
        7 unassigned    wm                 0           0               0
        8   reserved    wm         143358208        8.00MB          143374591
      partition> label
      [0] SMI Label
      [1] EFI Label
      Specify Label type[1]: 0
      Warning: This disk has an EFI label. Changing to SMI label will erase
      all current partitions.
      Continue? no
      partition> label
      [0] SMI Label
      [1] EFI Label
      Specify Label type[1]:
      Ready to label disk, continue? yes
      partition> quit
      ……
      format> verify

      Volume name = <        >
      ascii name  = <SEAGATE-ST973451SSUN72G-0302-68.37GB>
      bytes/sector    =  512
      sectors = 143374737
      accessible sectors = 143374704
      Part      Tag    Flag     First Sector         Size         Last Sector
        0  BIOS_boot    wm               256      256.00MB          524543
        1        usr    wm            524544       60.00GB          126353663
        2 unassigned    wm                 0           0               0
        3 unassigned    wm                 0           0               0
        4 unassigned    wm                 0           0               0
        5 unassigned    wm                 0           0               0
        6       root    wm         126353664        1.00GB          128450815
        7 unassigned    wm                 0           0               0
        8   reserved    wm         143358208        8.00MB          143374591

16. List all FC disks

    ::

      root@SOH13SER1PD2:~# cfgadm -al -o show_FCP_dev
      Ap_Id                          Type         Receptacle   Occupant     Condition
      c1                             fc-fabric    connected    configured   unknown
      c1::50001442e0030801,0         disk         connected    configured   unknown
      c1::50001442e0030801,1         disk         connected    configured   unknown
      c1::50001442e0030801,2         disk         connected    configured   unknown
      c1::50001442e0030801,3         disk         connected    configured   unknown
      c1::50001442e0030801,4         disk         connected    configured   unknown
      c1::50001442e0030801,5         disk         connected    configured   unknown

17. Label several disks together:

    ::

      root@solvhba103218:~# cat LUNs.txt
      /dev/rdsk/c0t514F0C5B14C0002Bd0s2
      /dev/rdsk/c0t514F0C5B14C0002Cd0s2
      /dev/rdsk/c0t514F0C5B14C0002Dd0s2
      /dev/rdsk/c0t514F0C5B14C0002Ed0s2
      /dev/rdsk/c0t514F0C5B14C0002Fd0s2
      root@solvhba103218:~# cat fmt.cmd
      label
      quit

      root@solvhba103218:~# for i in `cat LUNs.txt`; do format -f fmt.cmd $i ; done

18. Disk Naming:

    - SPARC:

      - VTOC:

        - powerpath psedudo: emcpower#[a-h]
        - native: c#t#d#s[0-7]

      - EFI

        - powerpath psedudo: emcpower#[a-g], emcpower# represents the whole disk
        - native: c#t#d#[0-6], c#t#d# represents the whole disk

    - x86

      - VTOC

        - powerpath psedudo: emcpower#[a-p]
        - native: c#t#d#s[0-15] - slices, c#t#d#p[0-4] - fdisk partition

19. Creating and Examining a Disk Label - http://docs.oracle.com/cd/E23824_01/html/821-1459/disksprep-34.html
20. Remove a failed disk:

    ::

      # cfgadm -al -o show_SCSI_LUN | egrep 'unusable|failing'
      # luxadm -e offline <device listed in above command>

=======================
SPARC 11 BFS with VxDMP
=======================

*References:*

- How to create a Mirrored Root Pool - http://docs.oracle.com/cd/E19253-01/819-5461/gkdep/index.html
- Solaris HCG section 'Enabling and disabling DMP support for the ZFS root pool'

*Commands:*

::

  root@soh12ser2:~# vxdmpadm settune dmp_native_support=on

  root@soh12ser2:~# vxdmpadm getsubpaths dmpnodename=emc_clariion0_75
  NAME         STATE[A]   PATH-TYPE[M] CTLR-NAME      ENCLR-TYPE   ENCLR-NAME    ATTRS       PRIORITY
  ===================================================================================================
  c17t5006016247E41654d0s2  ENABLED      Active/Non-Optimized  c17          EMC_CLARiiON  emc_clariion0     -         -
  c17t5006016A47E41654d0s2  ENABLED(A)   Active/Optimized(P)  c17          EMC_CLARiiON  emc_clariion0     -         -
  c18t5006016247E41654d0s2  ENABLED      Active/Non-Optimized  c18          EMC_CLARiiON  emc_clariion0     -         -
  c18t5006016A47E41654d0s2  ENABLED(A)   Active/Optimized(P)  c18          EMC_CLARiiON  emc_clariion0     -         -

  root@soh12ser2:~# readlink /dev/dsk/c17t5006016247E41654d0s2
  ../../devices/pci@500/pci@2/pci@0/pci@a/SUNW,qlc@0/fp@0,0/ssd@w5006016247e41654,0:c
  root@soh12ser2:~# readlink /dev/dsk/c17t5006016A47E41654d0s2
  ../../devices/pci@500/pci@2/pci@0/pci@a/SUNW,qlc@0/fp@0,0/ssd@w5006016a47e41654,0:c
  root@soh12ser2:~# readlink /dev/dsk/c18t5006016247E41654d0s2
  ../../devices/pci@500/pci@2/pci@0/pci@a/SUNW,qlc@0,1/fp@0,0/ssd@w5006016247e41654,0:c
  root@soh12ser2:~# readlink /dev/dsk/c18t5006016A47E41654d0s2
  ../../devices/pci@500/pci@2/pci@0/pci@a/SUNW,qlc@0,1/fp@0,0/ssd@w5006016a47e41654,0:c

  root@soh12ser2:~# eeprom boot-device
  boot-device=/pci@400/pci@2/pci@0/pci@e/scsi@0/disk@w5000c500478063fd,0:a /pci@400/pci@2/pci@0/pci@e/scsi@0/disk@w5000c500478317f9,0:a disk1

  root@soh12ser2:~# eeprom use-nvramrc?
  use-nvramrc?=false
  root@soh12ser2:~# eeprom use-nvramrc?=true
  root@soh12ser2:~# eeprom use-nvramrc?
  use-nvramrc?=true

  root@soh12ser2:~# format c17t5006016247E41654d0s2 ---> create a partition the same size or a little bit larger than the local root disk
  root@soh12ser2:~# zpool attach rpool  disk_0s0 /dev/vx/dmp/emc_clariion0_75s0

  root@soh12ser2:~# installboot -f -F zfs /usr/platform/`uname -i`/lib/fs/zfs/bootblk /dev/vx/rdmp/emc_clariion0_75s0

  root@soh12ser2:~# init 0

  {0} ok boot probe-scsi-all
  {0} ok boot /pci@500/pci@2/pci@0/pci@a/SUNW,qlc@0/disk@w5006016247e41654,0:a

  (Run this command to verify if the LUN is used for OS boot: prtconf -vp | grep bootpath)

======================
ZFS Commands Reference
======================

Pool Related Commands
---------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zpool create datapool c0t0d0                                             Create a basic pool named datapool
# zpool create -f datapool c0t0d0                                          Force the creation of a pool
# zpool create -m /data datapool c0t0d0                                    Create a pool with a different mount point than the default.
# zpool create datapool raidz c3t0d0 c3t1d0 c3t2d0                         Create RAID-Z vdev pool
# zpool add datapool raidz c4t0d0 c4t1d0 c4t2d0                            Add RAID-Z vdev to pool datapool
# zpool create datapool raidz1 c0t0d0 c0t1d0 c0t2d0 c0t3d0 c0t4d0 c0t5d0   Create RAID-Z1 pool
# zpool create datapool raidz2 c0t0d0 c0t1d0 c0t2d0 c0t3d0 c0t4d0 c0t5d0   Create RAID-Z2 pool
# zpool create datapool mirror c0t0d0 c0t5d0                               Mirror c0t0d0 to c0t5d0
# zpool create datapool mirror c0t0d0 c0t5d0 mirror c0t2d0 c0t4d0          disk c0t0d0 is mirrored with c0t5d0 and disk c0t2d0 is mirrored withc0t4d0
# zpool add datapool mirror c3t0d0 c3t1d0                                  Add new mirrored vdev to datapool
# zpool add datapool spare c1t3d0                                          Add spare device c1t3d0 to the datapool
## zpool create -n geekpool c1t3d0                                         Do a dry run on pool creation
=========================================================================  ==========================================================================

Show Pool Information
---------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zpool status -x                                                          Show pool status
# zpool status -v datapool                                                 Show individual pool status in verbose mode
# zpool list                                                               Show all the pools
"# zpool list -o name                                                      size", "Show particular properties of all the pools (here, name and size)"
# zpool list -Ho name                                                      Show all pools without headers and columns
=========================================================================  ==========================================================================

File-system/Volume related commands
-----------------------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zfs create datapool/fs1                                                  Create file-system fs1 under datapool
# zfs create -V 1gb datapool/vol01                                         Create 1 GB volume (Block device) in datapool
# zfs destroy -r datapool                                                  destroy datapool and all datasets under it.
# zfs destroy -fr datapool/data                                            destroy file-system or volume (data) and all related snapshots
=========================================================================  ==========================================================================

Set ZFS file system properties
------------------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zfs set quota=1G datapool/fs1                                            Set quota of 1 GB on filesystem fs1
# zfs set reservation=1G datapool/fs1                                      Set Reservation of 1 GB on filesystem fs1
# zfs set mountpoint=legacy datapool/fs1                                   Disable ZFS auto mounting and enable mounting through /etc/vfstab.
# zfs set sharenfs=on datapool/fs1                                         Share fs1 as NFS
# zfs set compression=on datapool/fs1                                      Enable compression on fs1
=========================================================================  ==========================================================================

File-system/Volume related commands
-----------------------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zfs create datapool/fs1                                                  Create file-system fs1 under datapool
# zfs create -V 1gb datapool/vol01                                         Create 1 GB volume (Block device) in datapool
# zfs destroy -r datapool                                                  destroy datapool and all datasets under it.
# zfs destroy -fr datapool/data                                            destroy file-system or volume (data) and all related snapshots
=========================================================================  ==========================================================================

Show file system info
---------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zfs list                                                                 List all ZFS file system
# zfs get all datapool”                                                    List all properties of a ZFS file system
=========================================================================  ==========================================================================

Mount/Umount Related Commands
-----------------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zfs set mountpoint=/data datapool/fs1                                    Set the mount-point of file system fs1 to /data
# zfs mount datapool/fs1                                                   Mount fs1 file system
# zfs umount datapool/fs1                                                  Umount ZFS file system fs1
# zfs mount -a                                                             Mount all ZFS file systems
# zfs umount -a                                                            Umount all ZFS file systems
=========================================================================  ==========================================================================

ZFS I/O performance
-------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zpool iostat 2                                                           Display ZFS I/O Statistics every 2 seconds
# zpool iostat -v 2                                                        Display detailed ZFS I/O statistics every 2 seconds
=========================================================================  ==========================================================================

ZFS maintenance commands
------------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zpool scrub datapool                                                     Run scrub on all file systems under data pool
# zpool offline -t datapool c0t0d0                                         Temporarily offline a disk (until next reboot)
# zpool online                                                             Online a disk to clear error count
# zpool clear                                                              Clear error count without a need to the disk
=========================================================================  ==========================================================================

Import/Export Commands
----------------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zpool import                                                             List pools available for import
# zpool import -a                                                          Imports all pools found in the search directories
# zpool import -d                                                          To search for pools with block devices not located in /dev/dsk
# zpool import -d /zfs datapool                                            Search for a pool with block devices created in /zfs
# zpool import oldpool newpool                                             Import a pool originally named oldpool under new name newpool
# zpool import 3987837483                                                  Import pool using pool ID
# zpool export datapool                                                    Deport a ZFS pool named mypool
# zpool export -f datapool                                                 Force the unmount and deport of a ZFS pool
=========================================================================  ==========================================================================

Snapshot Commands
-----------------

==========================================================================  ==========================================================================
Command                                                                     Description
==========================================================================  ==========================================================================
# zfs snapshot datapool/fs1@12jan2014                                       Create a snapshot named 12jan2014 of the fs1 filesystem
# zfs list -t snapshot                                                      List snapshots
# zfs rollback -r datapool/fs1@10jan2014                                    Roll back to 10jan2014 (recursively destroy intermediate snapshots)
# zfs rollback -rf datapool/fs1@10jan2014                                   Roll back must and force unmount and remount
# zfs destroy datapool/fs1@10jan2014                                        Destroy snapshot created earlier
# zfs send datapool/fs1@oct2013 > /geekpool/fs1/oct2013.bak                 Take a backup of ZFS snapshot locally
# zfs receive anotherpool/fs1 < /geekpool/fs1/oct2013.bak                   Restore from the snapshot backup backup taken
# zfs send datapool/fs1@oct2013 | zfs receive anotherpool/fs1
# zfs send datapool/fs1@oct2013 | ssh node02 “zfs receive testpool/testfs”  Send the snapshot to a remote system node02
==========================================================================  ==========================================================================

Clone Commands
--------------

=========================================================================  ==========================================================================
Command                                                                    Description
=========================================================================  ==========================================================================
# zfs clone datapool/fs1@10jan2014 /clones/fs1                             Clone an existing snapshot
# zfs destroy datapool/fs1@10jan2014                                       Destroy clone
=========================================================================  ==========================================================================
