---
tags: [linux, cheatsheet, hardware]
aliases: ["ipmitool", "hardware", "edac", "initramfs"]
type: cheatsheet
---
# Linux Hardware
## Hardware information query

Besides individual tools like lspci, lscpu, etc. which can be used to list special kinds of hardware devices, dmidecode can be used to query almost all kind of hardware:

```bash
man dmidecode # check DMI TYPES section
dmidecode -t 4 # CPU information
dmidecode -t 17 # physical memory information
...
```

## Error Detection And Correction query

```bash
# memory related errors can be reported by EDAC module.
# refer to https://www.kernel.org/doc/html/latest/driver-api/edac.html for basic concepts
edac-util --report=ce
edac-util --report=simple -vvv
```

## ipmitool

- Get system status

  ```bash
  # IPMI interface will either lan or lanplus
  ipmitool -I lanplus -H 192.168.10.10 -U admin -P password chassis status
  ```

- Power Ops

  ```bash
  ipmitool -I lanplus -H 192.168.10.10 -U admin -P password power <on|off|soft|reset>
  ```

- Change boot order

  ```bash
  ipmitool -I lanplus -H 192.168.10.10 -U admin -P password chassis bootdev <bios|pxe|cdrom|...>
  ```

- Reset IPMI controller

  ```bash
  ipmitool -I lanplus -H 192.168.10.10 -U admin -P password mc reset [warm|cold]
  ```

- Create a console connection

  ```bash
  # deactivate at first
  ipmitool -I lanplus -H 192.168.10.10 -U admin -P password sol deactivate
  ipmitool -I lanplus -H 192.168.10.10 -U admin -P password sol activate
  # type ~. to quit the sol session
  ```

- Check sensors

  ```bash
  ipmitool sdr | grep Total_Power
  ipmitool-sensors
  ```

## Check initramfs contents

```bash
lsinitrd <initrd image>
```

## Linux symbol table

```bash
# find the introduction
man procfs
cat /proc/kallsyms
# for symbol type
man nm
```

## Create application core dump

```bash
# it is recommended to change ulimit in its configuration file
ulimit -c unlimited
kill -11 <pid> # different application may accept different signals to trigger a core dump
coredumpctl list
coredumpctl list <core dump pid>
```

## max number of open file descriptors

- it is well known that tuning nofile options within /etc/security/limits.conf can control the max num. of open fds;
- all documents including the manpage for limits.conf declare **-1** for nofile mean no limited;
- however, on some system, -1 may lead to login permission deny;
- hence, nofile should be set to a value less than or equal to **sysctl fs.nr_open**

## Display /proc/interrupts w/o wrapping

```bash
less -S /proc/interrupts
```

## Write message to serial log(dmesg)

```bash
echo "hello world" >>/dev/kmsg
```

## Device I/O

I/O port -> I/O memory -> Memory mapped I/O(MMIO) -> DMA -> IOMMU

## Related
- [[linux_storage]]
- [[linux_memory]]
- [[linux_system]]

