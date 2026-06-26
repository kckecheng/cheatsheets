---
tags: [linux, cheatsheet, storage, disk]
aliases: ["scsi", "nvme", "lvm", "disk"]
type: cheatsheet
---
# Linux Storage & Disks
## List all SCSI devices

**sg_map** can be used to list all devices support SCSI, such as sd, sr, st, etc. In the meanwhile, it can also list the well known host:bus:scsi:lun information as lsscsi.

Note: sg stands for generic SCSI driver, it is generalized (but lower level) than its siblings(sd, sr, etc.) and tends to be used on SCSI devices that don't fit into the already serviced categories. When the type for a SCSI device cannot be recognized, it will be shown as a sg device.

```bash
# sg_map -x
/dev/sg0  1 0 0 0  5  /dev/sr0
/dev/sg1  2 0 0 0  0  /dev/sda
```

**lsblk** can also help list quite some information about block devices:

```bash
# List SCSI devices
lsblk -S
# Show topology information
lsblk -Tt
# Show devices and associated file system information
lsblk -f
# Show device paths
lsblk -p
```

## Create a LV with all free space

```bash
lvcreate -l 100%FREE -n <LV name> <VG name>
```

## Find the corresponding dm-X device for a lv

```bash
dmsetup ls # find the major, minor number for lv device
ls -l /dev/dm-* # based on the major, minor number for the dm-X device
```

## Query disk basic info like model, sn, firmware, etc.

```bash
smartctl -i /dev/sda
```

## gdisk

- Designed for GUID partition table;
- Able to backup and load partition data(sgdisk -b/-l)

## sg_inq/sg3_inq

```bash
# sg_inq -p 0 /dev/<device name>
 Only hex output supported. sg_vpd decodes more pages.
VPD INQUIRY, page code=0x00:
   [PQual=0  Peripheral device type: disk]
   Supported VPD pages:
     0x0        Supported VPD pages
     0x80       Unit serial number
     0x83       Device identification
     0x8f       Third party copy
     0xb0       Block limits (sbc2)
     0xb1       Block device characteristics (sbc3)
     0xb2       Logical block provisioning (sbc3)
# sg_inq -p 0x83 /dev/<device name>
```

## Rescan/discover LUN/disk without reboot

- FC

  ```bash
  # find . -name "scan"
  # echo '- - -' > ./devices/pci0000:00/0000:00:07.1/ata1/host0/scsi_host/host0/scan
  ---OR---
  # echo '- - -' > /sys/class/scsi_host/host0/scan
  …
  # lsblk
  ```

- iSCSI

  ```bash
  iscsiadm -m session
  iscsiadm -m session --sid=<session ID> --rescan
  # or rescan all sessions
  iscsiadm -m session --rescan
  ```

## Remove a SCSI/SAN disk when it is dead

```bash
~$ sudo lsscsi
[0:2:0:0]    disk    Lenovo   720i             4.23  /dev/sda
[0:2:1:0]    disk    Lenovo   720i             4.23  /dev/sdb
[0:2:2:0]    disk    Lenovo   720i             4.23  /dev/sdc
[0:2:3:0]    disk    Lenovo   720i             4.23  /dev/sdd
[1:0:0:0]    disk    Single   Flash Reader     1.00  /dev/sde
[4:0:0:0]    cd/dvd  PLDS     DVD-RW DU8A5SH   BL61  /dev/sr0
[14:0:1:0]   disk    DGC      LUNZ             4100  /dev/sdf

~$ echo 1 | sudo tee /sys/bus/scsi/devices/${H:B:T:L}/delete
(Note: H:B:T:L is the bus address output of lsscsi for sdf)

~$ sudo lsscsi
[0:2:0:0]    disk    Lenovo   720i             4.23  /dev/sda
[0:2:1:0]    disk    Lenovo   720i             4.23  /dev/sdb
[0:2:2:0]    disk    Lenovo   720i             4.23  /dev/sdc
[0:2:3:0]    disk    Lenovo   720i             4.23  /dev/sdd
[1:0:0:0]    disk    Single   Flash Reader     1.00  /dev/sde
[4:0:0:0]    cd/dvd  PLDS     DVD-RW DU8A5SH   BL61  /dev/sr0
```

## Change I/O Scheduler

```bash
# persistent - may not work for some systems
grubby --update-kernel=ALL --args="elevator=bfq"
# on the fly
cat /sys/block/sda/queue/scheduler
echo bfq > /sys/block/sda/queue/scheduler
cat /sys/block/sda/queue/scheduler
```

## View/Create/Remove SCSI Persistent Reservation Keys

Refer to https://access.redhat.com/solutions/43402

### Tool needed - sg3_utils

```bash
yum install sg3_utils
```

### View registered keys

```bash
sg_persist --in -k -d /dev/<DEVICE>
```

### View the reservations

```bash
sg_persist --in -r -d /dev/<DEVICE>
```

### View more info about keys

```bash
sg_persist --in -s -d /dev/<DEVICE>
```

### Register a key

```bash
sg_persist --out --register --param-sark=<KEY> /dev/<DEVICE>
```

### Take out a reservation

```bash
sg_persist --out --reserve --param-rk=<KEY> --prout-type=<TYPE> /dev/<DEVICE>
```

### Release a reservation

```bash
sg_persist --out --release --param-rk=<KEY> --prout-type=<TYPE> /dev/<DEVICE>
```

### Unregister a key

```bash
sg_persist --out --register --param-rk=<KEY> /dev/<DEVICE>
```

### Clear the reservation and all registered keys

```bash
sg_persist --out --clear --param-rk=<KEY> /dev/<DEVICE>
```

### A simple script to clear all reservations

```bash
#!/usr/bin/bash

DEVICE=$1

KEYS=`sg_persist --in -k -d $DEVICE | grep '^ \+0x' | awk '{print $1}' | uniq`

for k in $KEYS; do
  sg_persist --out --clear --param-rk=${k} ${DEVICE}
done
```

## NVME

Refer to below docs:

- https://narasimhan-v.github.io/2020/06/12/Managing-NVMe-Namespaces.html
- https://www.drewthorst.com/posts/nvme/namespaces/readme/

### Delete a NVME name space

```bash
[root@devbox ~]# nvme list
Node             SN                   Model                                    Namespace Usage                      Format           FW Rev
---------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme0n1     S5G3NA0R107888       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme1n1     S5G3NA0R107886       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme2n1     S5G3NA0R107879       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme3n1     S5G3NA0R107885       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
[root@devbox ~]# nvme id-ctrl /dev/nvme0 | grep cntlid
cntlid    : 41
[root@devbox ~]# nvme detach-ns /dev/nvme0 -n 1 -c 0x41
detach-ns: Success, nsid:1
[root@devbox ~]# nvme ns-rescan /dev/nvme0
[root@devbox ~]# nvme list
Node             SN                   Model                                    Namespace Usage                      Format           FW Rev
---------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme1n1     S5G3NA0R107886       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme2n1     S5G3NA0R107879       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme3n1     S5G3NA0R107885       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
```

### Create a NVMe name space

```bash
# nvme multipath:
# cat /sys/module/nvme_core/parameters/multipath
# grubby --update-kernel=ALL --args="nvme_core.multipath=Y" # enable
# grubby --update-kernel=ALL --args="nvme_core.multipath=N" # disable
# when nvme multipath is on, /sys/bus/pci/devices/<pci addr>/nvme/nvmeX will have a dir named nvmeXc0n1
# when nvme multipath is off, /sys/bus/pci/devices/<pci addr>/nvme/nvmeX will have a dir named nvmeXn1
[root@devbox ~]# nvme list-subsys
nvme-subsys0 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107888
\
 +- nvme0 pcie 0000:81:00.0 live
nvme-subsys1 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107886
\
 +- nvme1 pcie 0000:82:00.0 live
nvme-subsys2 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107879
\
 +- nvme2 pcie 0000:83:00.0 live
nvme-subsys3 - NQN=nqn.1994-11.com.samsung:nvme:PM1733:2.5-inch:S5G3NA0R107885
\
 +- nvme3 pcie 0000:84:00.0 live
[root@devbox ~]# ls -l /dev/nvme*
crw------- 1 root root 243, 0 Dec 29 17:27 /dev/nvme0
crw------- 1 root root 243, 1 Dec 29 17:27 /dev/nvme1
brw-rw---- 1 root disk 259, 3 Dec 29 19:33 /dev/nvme1n1
crw------- 1 root root 243, 2 Dec 29 17:27 /dev/nvme2
brw-rw---- 1 root disk 259, 5 Dec 29 19:33 /dev/nvme2n1
crw------- 1 root root 243, 3 Dec 29 17:27 /dev/nvme3
brw-rw---- 1 root disk 259, 7 Dec 29 19:33 /dev/nvme3n1
[root@devbox ~]# nvme id-ctrl /dev/nvme0 | grep cap
tnvmcap   : 3840755982336
unvmcap   : 0
sanicap   : 0x3
anacap    : 0
[root@devbox ~]# echo 3840755982336 / 4096 | bc
937684566
[root@devbox ~]# nvme create-ns /dev/nvme0 -s 937684566 -c 937684566 -b 4096
create-ns: Success, created nsid:1
[root@devbox ~]# nvme list-ns /dev/nvme0 -a
[   0]:0x1
[root@devbox ~]# nvme id-ctrl /dev/nvme0 | grep cntlid
cntlid    : 41
[root@devbox ~]# nvme attach-ns /dev/nvme0 -n 0x1 -c 0x41
attach-ns: Success, nsid:1
[root@devbox ~]# nvme ns-rescan /dev/nvme0
[root@devbox ~]# nvme list
Node             SN                   Model                                    Namespace Usage                      Format           FW Rev
---------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme0n1     S5G3NA0R107888       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme1n1     S5G3NA0R107886       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme2n1     S5G3NA0R107879       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
/dev/nvme3n1     S5G3NA0R107885       SAMSUNG MZWLJ3T8HBLS-0007C               1           3.84  TB /   3.84  TB      4 KiB +  0 B   EPK9BJ5Q
[root@devbox ~]# ls -l /dev/nvme*
crw------- 1 root root 243, 0 Dec 29 17:27 /dev/nvme0
brw-rw---- 1 root disk 259, 8 Dec 29 20:07 /dev/nvme0n1
crw------- 1 root root 243, 1 Dec 29 17:27 /dev/nvme1
brw-rw---- 1 root disk 259, 3 Dec 29 19:33 /dev/nvme1n1
crw------- 1 root root 243, 2 Dec 29 17:27 /dev/nvme2
brw-rw---- 1 root disk 259, 5 Dec 29 19:33 /dev/nvme2n1
crw------- 1 root root 243, 3 Dec 29 17:27 /dev/nvme3
brw-rw---- 1 root disk 259, 7 Dec 29 19:33 /dev/nvme3n1
```

## Related
- [[linux_hardware]]
- [[linux_kvm_libvirt]]

