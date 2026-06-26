---
tags: [debug, cheatsheet, binutils]
aliases: ["objdump", "readelf", "debuginfo", "core dump"]
type: cheatsheet
---
# Binary & Debug Tools
## MISC

### Check shared object/library dependencies

```
ldd <object or executable file>
LD_DEBUG=libs ldd <object or executable file>
```

### Check object/executable file information

- objdump: display info for object files
- nm: list symbols from object files
- pahole: show data structures of object files (including running kernels)
- readelf: display info for ELF files
- ldd: print object dependencies
- elfutils: a set of tools used to read, create and modify elf files (refer to https://sourceware.org/elfutils/)

```
# if objdump hit errors such, try eu-objdump
# Disassemble
objdump -d <ELF file>
objdump -S <ELF file>
# disassemble a module
cat /proc/modules # get module name and alive address
modinfo <module name> # get module path
objdump -S path/to/module --adjust-vma=<live address>
# Display symbol tables
objdump -t <ELF file>
# Display dynamic symbol tables
objdump -T <ELF file>
readelf --dyn-syms <ELF file>
# Display static + dynamic symbols
objdump -tT <ELF file>
# Show dynamic dependencies
readelf -d <ELF file> | grep -i need
# Show section information
readelf -S vmlinux
ldd <ELF file>
# show struct task_struct of running kernel
pahole task_struct
# just an example: locate source code info based on the pc register during kernel oops
# - say the oops pc is as: [   88.635314 ] pc : [<c01b063c>]    lr : [<c01b0640>]    psr: a0000013
# - get the source code info based on the pc value
addr2line -f -e vmlinux c01b063c # this tells the source code function name mapped to the pc address c01b063c
```

### debuginfo-install

```
# work on rpm based distributions, part of yum-utils
debuginfo-install search ethtool
debuginfo-install install ethtool-debuginfo
```

### Get core file's application info

```
# sometimes, it is not easy to find which application triggers the core to be debugged just based on the core file's name
eu-unstrip -n --core <core file> # the first entry points to the absolute path of the application
eu-unstrip -n -e /path/to/binary # check if the hash for a binary is the same as in the core
```

### unstrip/combine files with debugging info

```
file /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
cp /usr/local/bin/qemu-system-x86_64 /usr/local/bin/qemu-system-x86_64.bak
cp /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug.bak
eu-unstrip /usr/local/bin/qemu-system-x86_64 /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
mv /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug /usr/local/bin/qemu-system-x86_64
chmod a+x /usr/local/bin/qemu-system-x86_64
```

### Create core file for a running process

```
gcore <pid>
```

### Extract bits w/ bitwise ops

```
# 1. create a suitable binary mask with ones only covering the position needed;
# 2. perform a bitwise and operation between the number and the mask;
# 3. right shift;
# Example: get the middle 48 bits(totally 64 bits) from 0xffffffff81e0a000
d = 0xffffffff81e0a000
mask = 0x00ffffffffffff00 # with prefix and suffix total 16 bits as 0
d & mask # 0xffffff81e0a000
0xffffff81e0a000 >> 8 # 0xffffff81e0a0
```

### Trigger panic when softlockup (or other problems) is hit

```
# sysctl -a | grep -i panic
echo 1 > /proc/sys/kernel/softlockup_panic
```

### Trigger a vmcore to analyze system problems

```
echo b > /proc/sysrq-trigger
```

### Change kernel log level

Append loglevel=X to cmdline (refer to kernel-parameters.txt):

- 0 ~ 7
- 0: KERN_EMERG
- 1: KERN_ALERT
- 2: KERN_CRIT
- 3: KERN_ERR
- 4: KERN_WARNING
- 5: KERN_NOTICE
- 6: KERN_INFO
- 7: KERN_DEBUG

### Work around PATH|LD_LIBRARY_PATH compiling error

```
# This works for not just kernel but also other projects.
# Below error might be hit:
You seem to have the current working directory in your <PATH|LD_LIBRARY_PATH> environment variable. This doesn't work.
# Fix
export PATH=`echo $PATH | sed -e 's/::/:/g'`
export LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | sed -e 's/::/:/g'`
make
```

### Get kernel memory mappings

```
# make sure below options are enabled during kernel compilation
# Kernel hacking -> Generic Kernel Debugging Instruments
# - Debug Filesystem(DEBUG_FS)
# Kernel hacking -> Memory Debugging:
# - Export kernel pagetable layout to userspace via debugfs(PTDUMP_DEBUGFS)
# make sure debugfs is mounted, if not: mount -t debugfs none /sys/kernel/debug
cat /sys/kernel/debug/page_tables/kernel
```

### Get kernel memory layout

```
cat /proc/iomem
cat /boot/System.map-`uname -r` | grep -w -e '_text' -e '_etext' -e '_edata' -e '_end'
```

### Get I/O ports information

```
cat /proc/ioports
```

### Decode dmesg timestamp

```
# some old version linux does not support changing dmesg timestamp to human friendly format
# meanwhile, dmesg during crash cannot be decoded as human friendly format
# get the timestamp when the system is booted
uptime -s
# dmesg timestamp is the seconds passed since the boot time, just add it to boot time
# cat /proc/stat | grep btime # the seconds since the Epoch
```

### System boot-up performance profile

```
systemd-analyze blame
```

## Related
- [[debug_gdb]]
- [[debug_tracing]]

