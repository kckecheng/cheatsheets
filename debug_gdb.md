---
tags: [debug, cheatsheet, gdb]
aliases: ["gdb", "debugger"]
type: cheatsheet
---
# gdb Tips
## gdb tips

### Debuginfod

Debuginfod is a service providing debug information over an HTTP API. This means that users will be able to debug programs without the need to manually install a distribution's debuginfo packages once the debuginfod server (always provisioned by a distributor vendor, such as ubuntu, hence there is no need to configure it for most cases) and client (quite some tools now ship with the client, e.g., elfutils-debuginfod-client, libelf, gdb, perf, etc.) are configured.

If debuginfod client is enabled, there will be a configuration under /etc/debuginfod (or /usr/xxx), and env var DEBUGINFOD_URLS will be configured. If the client is configured but it cannot access the debuginfod server, related tools such as gdb/perf may work slowly during startup. To disable the client, export DEBUGINFOD_URLS="".

### gdb verbose

```
# turn on verbose to let gdb show where it finds symbol files automatically, etc.
set verbose on
show verbose
```

### breakpoint with regular expression

```
rbreak <regex>
```

### Set breakpoints on all functions

```
rbreak <regex> # set breakpoints on all functions matching the regular expression
rbreak <file>:<regex> # set breakpoints on all functions matching the regular expression for the file
rbreak . # break in all functions
rbreak <file>:. # break in all functions for the file
```

### Associate breakpoints with a bunch of commands

commands x: x is the breakpoint id, multiple ids can be provided, the last one will be used if not provided

```
info b
break func1
commands 1
set $count = 0
bt
c
while $count < 6
bt
set $count = $count + 1
c
end
end
q
```

### Associate watchpoints with a bunch of commands

```
info watch
watch var1
# print var1 everytime var1 is hit
commands
print var1
end
# NOTE: the same can be achieved with breakpoints which is more flexible
info b
b path/to/file:lineX
commands
print var1
c
end
```

### gdb with args

```
# arg1, arg2, ... can be something like --abc -d
gdb --args <executable> arg1 arg2 ...
```

### Load separate debug files

```
# keep a program's debugging information in a file separate from the executable itself
# and allow gdb to search and load the information automatically
# the setup can be added init .gdbinit
set verbose on
show debug-file-directory
set debug-file-directory path1
set debug-file-directory path2
```

### Specify where to find source files

```
# it is recommended to start debugging from the source code directory (gdb will search source files from current dir automatically)
# however, it is not always possible - for example, to show source code from glibc which is not under current directory
# under such a situation, use directory to add source file search paths
gdb /path/to/prog
set verbose on
start
directory path1
directory path2
show directory
```

### Find commands

```
# apropos <command regex>
apropos info
apropos break
```

### Search variables/functions

```
bt
# args for current stack
info args
info args <arg name regex>
# locals for current stack
info locals
info locals <local name regex>
# change to another frame/stack and repeat
frame xxx
info xxx
# global/static variables
info variables
info variables <variable name regex>
# functions
info functions
info functions <func name regex>
```

### Check macros

```
# the program needs to be compiled with -g3
info macro var1
macro expand var1
```

### List source code

```
# some non-default usage of list
list *0xc021e50e # list source from the line where the address points to
list *vt_ioctl+0xda8 # list source from the line based on the function address(*vt_ioctl) and its offset(+0xda8)
list *$pc # list source from the line where the pc register points to
list kvm_virtio_pci_irqfd_use # list around a function(totally 10 lines)
list 831,850 # list from line 831 to 850
# set num of lines to list
set listsize 20
# 1 x line of source code might be compiled into several lines of instructions, use info line linespec to show the starting and ending addresses
info line *0xffffffff81026260 # show the starting and ending addresses for the source line the address 0xffffffff81026260 points to
```

### Pretty print

```
# print struct pretty
apropos pretty
set print pretty
lx-ps
p (struct task_struct *)0xffff888002ebb000
```

### TUI usage

TUI is short for text UI which can be used to display source code, asm, and registers during debugging:

- tui enable/disable: toggle TUI, Ctrl + x + a as the shortcut
- layout src/asm/split/regs: switch TUI display layout, Ctrl + x + 1/2 as the shortcut
- info win: list all displayed windows and their names, size, etc.
- winheight/wh src/cmd/asm/regs +/- <num. of lines>: change window's height based on its name gotten from info win

### Automate with a command file

**Simple script**

```
# print backtrace automatically when a function is hit, then exit
cat >pbt.gdb<<EOF
set verbose off
set confirm off
set pagination off
set logging file gdb.txt
set logging on
set width 0
set height 0
file /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
break hmp_info_cpus
commands 1
bt
c
end
q
EOF
gdb -q -p `pgrep -f qemu-system-x86_64` -x pbt.gdb
# from another session, trigger the breakpoint by executing below command:
# virsh qemu-monitor-command xxxxxx --hmp info cpus
```

**Script with a loop**

```
# print backtrace automatically when a function is hit, then exit
cat >pbt.gdb<<EOF
set verbose off
set confirm off
set pagination off
set logging file gdb.txt
set logging on
set width 0
set height 0
file /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
break hmp_info_cpus
commands
set $counter = 0
c
end
while $counter < 10
bt
set $counter = $counter + 1
c
end
q
EOF
gdb -q -p `pgrep -f qemu-system-x86_64` -x pbt.gdb
# from another session, trigger the breakpoint by executing below command:
# virsh qemu-monitor-command xxxxxx --hmp info cpus
```

### Automation with python API

Reference: https://sourceware.org/gdb/current/onlinedocs/gdb.html/Python-API.html#Python-API

Example:

```python
# usage: gdb -p `pidof libvirtd`  -ex "source demo.py" -ex "set pagination off"
import gdb
import time
import os

class qemuMigrationDriveMirror(gdb.Breakpoint):
    def __init__(self):
        gdb.Breakpoint.__init__(self, "qemuMigrationDriveMirrorReady")

    def stop(self):
        os.system("kill -9 $(pidof qemu-system-x86_64)")

        gdb.write("\nqemu process killed\n")
        gdb.execute("bt")

        return False

class qemuMigrationCancelDriveMirror(gdb.Breakpoint):
    def __init__(self):
        gdb.Breakpoint.__init__(self, "qemuMigrationCancelDriveMirror")

    def stop(self):
        frame = gdb.selected_frame()
        gdb.write(f"Hit breakpoint at: {frame.name()}")

        return False

qemuMigrationDriveMirror()
qemuMigrationCancelDriveMirror()
gdb.execute("continue")
```

### Attach to a process once it is started

```
inotifywait -e open /usr/local/bin/qemu-system-x86_64
pid=$(pgrep -f c8668dee-48c0-4968-aad6-e8a4fb0dd1ef)
# pitfall:
# - the process may not the one we want to debug, but it is paused by gdb as we want
# - info proc to check the real exe, if it is not the one
# - pgrep -f again to find the real process, then gdb -p xxx again
gdb -q /usr/bin/qemu-system-x86_64 -p $pid
info proc
# start a new connection
pgrep -f /usr/bin/qemu-system-x86_64
gdb -p xxx
```

### Print definition of an expression

```
ptype (struct task_struct *)0xffffffff81e12580
```

### Examine memory

```
help x
x /16xw 0xffffffff81e12580
x # repeat last command
```

### Show process memory mappings

```
info proc mappings
```

### Dump memory to a file

```
dump memory mem.bin 0xXXXX 0xYYYY
```

### Disassemble

```
disassemble 0xffffffff816abe9e
disassemble default_idle_call
```

### Convenience Variables

- Any name preceded by '$' can be used for a convenience variable;
- Reference https://sourceware.org/gdb/onlinedocs/gdb/Convenience-Vars.html
- Usage:

```
set $foo =  (struct CharDriverState *)0x4dfcb40
p $foo->chr_write_lock
```

### Define a customized command

```
# this demo is based on x86_32
define idt_entry
set $entry = *(uint64_t*)($idtr + 8 * $arg0)
print (void *)(($entry>>48<<16)|($entry&0xffff))
end
set $idtr = 0xfffffe0000000000
idt_entry 0
idt_entry 1
```

### Check registers

```
info registers
info registers <register name>
print /x $eax # every register gets a convenience variable assigned automatically as $<register name>
x /x $eax
monitor info registers # this is only available when debugging kernel with qemu(a qemu extension)
```

### Get process id

```
# while debugging a core file, this can be used to get the pid
(gdb) info inferiors
  Num  Description       Executable
* 1    process 204411    /usr/local/bin/qemu-system-x86_64
```

### Follow child processes

```
# gdb follows the parent process by default, to follow the child process
set follow-fork-mode child
# follow both the parent and the children
set detach-on-fork off
info inferiors
inferior <parent or children id>
```

### Switch among threads

```
b <some breakpoint>
c
info threads
thread x
bt
# show backtrace of all threads
thread apply all bt
```

### Binary values

```
set $v1 = 0b10
print /t $v1
print $v1
```

### Array

```
(gdb) list 7
2       #include <string.h>
3
4       int main() {
5           char *s[] = {"Hello", "world", "!"};
6
7           printf("s: ");
8           for (int i = 0; i < 3; i++) {
9               printf("%s ", s[i]);
10          }
11          printf("\n");
(gdb) p *s@0
Invalid number 0 of repetitions.
(gdb) p *s@1
$21 = {0x555555556004 "Hello"}
(gdb) p *s@2
$22 = {0x555555556004 "Hello", 0x55555555600a "world"}
(gdb) p *s@3
$23 = {0x555555556004 "Hello", 0x55555555600a "world", 0x555555556010 "!"}
(gdb) p *s@4
$24 = {0x555555556004 "Hello", 0x55555555600a "world", 0x555555556010 "!", 0x6a1689e82a6cdf00 <error: Cannot access memory at address 0x6a1689e82a6cdf00>}
(gdb) p/x s
$25 = {0x555555556004, 0x55555555600a, 0x555555556010}
```

### Run gdb commands through CLI

```
grep r--p /proc/6666/maps \
  | sed -n 's/^\([0-9a-f]*\)-\([0-9a-f]*\) .*$/\1 \2/p' \
  | while read start stop; do \
    gdb --batch --pid 6666 -ex "dump memory 6666-$start-$stop.dump 0x$start 0x$stop"; \
    done
```

### Run a command for specified rounds

```
# while X command: while 10 next
# while X
# command1
# command2
# end
while 10
call sleep(1)
c
end
```

### trace into glibc

```
# glibc debug information is not provided by default
# install glibc debugging information
# for centos
# yum --enablerepo="*" install -y glibc-debuginfo
# for ubuntu
sudo apt install -y libc6-dbg
# begin debug
cd /path/to/program
gdb /path/to/program
set verbose on # to show how the glibc symbols are searched and loaded
start # start will run the program and stop at main (different from run)
b printf # or any functions defined within glibc
c
info symbol printf
info function printf
list printf
# gdb may prompt that: printf.c: No such file or directory
# get the source files
sudo apt install -y glibc-source # or apt source glibc
cp /usr/src/glibc/glibc-2.31.tar.xz ~/
tar -Jxf glibc-2.31.tar.xz
find ~/glibc-2.31 -name printf.c
# add the source file directory
directory ~/glibc-2.31/stdio-common
list printf # the source code from glibc will be shown
```

### Disable paging

```
# by default, bt and some other commands will page,
# end users need to press return again and again
# to disable it:
set pagination off
```

### Run shell command in the background

```
shell ls &
```

### Grep output

```
set pagination off
set logging on # or set logging file xxx
bt
set logging off
shell tail gdb.txt # or tail xxx
shell grep xxx gdb.txt
```

## Related
- [[debug_kernel_gdb]]
- [[debug_binutils]]

