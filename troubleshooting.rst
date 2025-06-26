==================
Troubleshooting
==================

Techs for troubleshooting.

gdb tips
----------

Debuginfod
~~~~~~~~~~~~

Debuginfod is a service providing debug information over an HTTP API. This means that users will be able to debug programs without the need to manually install a distribution’s debuginfo packages once the debuginfod server(always provisioned by a distributor vendor, such as ubuntu, hence there is no need to configure it for most cases) and client(quite some tools now ship with the client, e.g., elfutils-debuginfod-client, libelf, gdb, perf, etc.) are configured.

If debuginfod client is enabled, there will be a configuraiton under /etc/debuginfod (or /usr/xxx), and env var DEBUGINFOD_URLS will be configured. If the client is configured but it cannot access the debuginfod server, related tools such as gdb/perf may work slowly during startup. To disable the client, export DEBUGINFOD_URLS="".

gdb verbose
~~~~~~~~~~~~

::

  # turn on verbose to let's gdb show where it find symbol files automatically, etc.
  set verbose on
  show verbose

breakpoint with regular expression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  rbreak <regex>

Set breakpoints on all functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  rbreak <regex> # set breakpoints on all functions matching the regular expression
  rbeak <file>:<regex> # set breakpoints on all functions matching the regular expression for the file
  rbreak . # break in all functions
  rbreak <file>:. # break in all functions for the file

Assocaite breakpoints with a bunch of commands
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

commands x: x is the breakpoint id, multiple ids can be provided, the last one will be used if not provided

::

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


Assocaite watchpoints with a bunch of commands
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

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

gdb with args
~~~~~~~~~~~~~~~

::

  # arg1, arg2, ... can be something like --abc -d
  gdb --args <executable> arg1 arg2 ...

Load separate debug files
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # keep a program's debugging information in a file separate from the executable itself
  # and allow gdb to search and load the information automatically
  # the setup can be added init .gdbinit
  set verbose on
  show debug-file-directory
  set debug-file-directory path1
  set debug-file-directory path2

Specify where to find source files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # it is recommended to start debugging from the source code directory(gdb will search source files from current dir automatically)
  # however, it is not always possible - for example, to show source code from glibc which is not under current directory
  # under such a situation, use directory to add source file search paths
  gdb /path/to/prog
  set verbose on
  start
  directory path1
  directory path2
  show directory

Find commands
~~~~~~~~~~~~~~~

::

  # apropos <command regex>
  apropos info
  apropos break

Search variables/functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

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
  # global/staic variables
  info variables
  info variables <variable name regex>
  # functions
  info funtsions
  info functions <func name regex>

Check macros
~~~~~~~~~~~~~~~

::

  # the program needs to be compiled with -g3
  info macro var1
  macro expand var1

List source code
~~~~~~~~~~~~~~~~~~

::

  # some non-default usage of list
  list *0xc021e50e # list source from the line where the address points to
  list *vt_ioctl+0xda8 # list souce from the line based on the function address(*vt_ioctl) and its offset(+0xda8)
  list *$pc # list source from the line where the pc register points to
  list kvm_virtio_pci_irqfd_use # list around a function(totally 10 lines)
  list 831,850 # list from line 831 to 850
  # set num of lines to list
  set listsize 20
  # 1 x line of source code might be compiled into several lines of instructions, use info line linespec to show the starting and ending addresses
  info line *0xffffffff81026260 # show the starting and ending addresses for the source line the address 0xffffffff81026260 points to

Pretty print
~~~~~~~~~~~~~~

::

  # print struct pretty
  apropos pretty
  set print pretty
  lx-ps
  p (struct task_struct *)0xffff888002ebb000

TUI usage
~~~~~~~~~~~

TUI is short for text UI which can be used to display source code, asm, and registers during debugging:

- tui enable/disable:  toggle TUI, Ctr + x + a as the shortcut
- layout src/asm/split/regs: witch TUI display layout, Ctr + x + 1/2 as the shortcut
- info win: list all displayed windows and their names, size, etc.
- winheight/wh src/cmd/asm/regs +/- <num. of lines>: change window's height based on its name gotten from info win

Automate with a command file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Simple script**

::

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
  # from another session, trigger the breakpint by executing below command:
  # virsh qmeu-monitor-command xxxxxx --hmp info cpus

**Script with a loop**

::

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
  # from another session, trigger the breakpint by executing below command:
  # virsh qmeu-monitor-command xxxxxx --hmp info cpus


Automation with python API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reference: https://sourceware.org/gdb/current/onlinedocs/gdb.html/Python-API.html#Python-API

Example:

::

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

Print definition of an expression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ptype (struct task_struct *)0xffffffff81e12580

Examine memory
~~~~~~~~~~~~~~~~~

::

  help x
  x /16xw 0xffffffff81e12580
  x # repeat last command

Show process memory mappings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  info proc mappings

Dump memory to a file
~~~~~~~~~~~~~~~~~~~~~~~

::

  dump memory mem.bin 0xXXXX 0xYYYY

Disassemble
~~~~~~~~~~~~~

::

  disassemble 0xffffffff816abe9e
  disassemble default_idle_call

Convenience Variables
~~~~~~~~~~~~~~~~~~~~~~~

* Any name preceded by '$' can be used for a convenience variable;
* Reference https://sourceware.org/gdb/onlinedocs/gdb/Convenience-Vars.html
* Usage:

  ::

    set $foo =  (struct CharDriverState *)0x4dfcb40
    p $foo->chr_write_lock

Define a customized command
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # this demo is based on x86_32
  define idt_entry
  set $entry = *(uint64_t*)($idtr + 8 * $arg0)
  print (void *)(($entry>>48<<16)|($entry&0xffff))
  end
  set $idtr = 0xfffffe0000000000
  idt_entry 0
  idt_entry 1

Check registers
~~~~~~~~~~~~~~~~~

::

  info registers
  info registers <register name>
  print /x $eax # every register gets a convenience variable assigned automationly as $<register name>
  x /x $eax
  monitor info registers # this is only available when debugging kernel with qemu(a qemu extension)

Get process id
~~~~~~~~~~~~~~~

::

  # while debuging a core file, this can be used to get the pid
  (gdb) info inferiors
    Num  Description       Executable
  * 1    process 204411    /usr/local/bin/qemu-system-x86_64

Follow child processes
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # gdb follows the parent process by default, to follow the child process
  set follow-fork-mode child
  # follow both the parent and the children
  set detach-on-fork off
  info inferiors
  inferior <parent or children id>

Switch among threads
~~~~~~~~~~~~~~~~~~~~~~~~

::

  b <some breakpoint>
  c
  info threads
  thread x
  bt
  # show backtrace of all threads
  thread apply all bt

Binary values
~~~~~~~~~~~~~~~

::

  set $v1 = 0b10
  print /t $v1
  print $v1

Array
~~~~~~

::

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

Run gdb commands through CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  grep r--p /proc/6666/maps \
    | sed -n 's/^\([0-9a-f]*\)-\([0-9a-f]*\) .*$/\1 \2/p' \
    | while read start stop; do \
      gdb --batch --pid 6666 -ex "dump memory 6666-$start-$stop.dump 0x$start 0x$stop"; \
      done

Run a command for specified times
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # while X command: while 10 next
  # while X
  # command1
  # command2
  # end
  while 10
  call sleep(1)
  c
  end

trace into glibc
~~~~~~~~~~~~~~~~~~~

::

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
  # add the source file direcotry
  directory ~/glibc-2.31/stdio-common
  list printf # the source code from glibc will be shown

Disable paging
~~~~~~~~~~~~~~~~

::

  # by default, bt and some other commands will page,
  # end users need to press return again and again
  # to disable it:
  set pagination off

Run shell command in the background
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  shell ls &

Grep output
~~~~~~~~~~~~~~

::

  set pagination off
  set logging on # or set logging file xxx
  bt
  set logging off
  shell tail gdb.txt # or tail xxx
  shell grep xxx gdb.txt

Kernel Debugging w/ gdb
--------------------------

Linux kernel debugging tips.

Notes: all demos used in this part is based on x86_64.

Build linux kernel
~~~~~~~~~~~~~~~~~~~~

- Generate the init .config

  ::

    make help
    make defconfig
    make kvm_guest.config

- Turn on below options within .config

  ::

    CONFIG_DEBUG_INFO=y
    CONFIG_GDB_SCRIPTS=y # if this is not on, run "make scripts_gdb" after kernel compiling
    CONFIG_DEBUG_INFO_REDUCED=n

- Regenerate the .config to reflect option updates

  ::

    make olddefconfig

- Define a customized kernel name suffix(optional)

  ::

    echo "CONFIG_LOCALVERSION=xxx" >> .config
    make oldconfig
    # or through menuconfig
    # make menuconfig->General setup->Local version->Enter xxx->Save->Exit

- Build the kernel

  ::

    # vmlinux, arch/x86/boot/bzImage will be created
    make -j`nproc`

- Create initramfs file

  ::

    # sudo apt install -y dracut
    make modules
    make modules_install INSTALL_MOD_PATH=/customized/module/installation/path
    dracut -k /customized/module/installation/path/lib/modules/kernel_version initrd.img

Create a qemu image and start it with the customized kernel and gdb server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The basic idea behind linux kernel debugging is running a qemu vm with a customized kernel(with debugging info) and a gdb server for remote debugging.

There are quite a lot methods to prepare such a qemu vm, 3 of them are introduced as below:

- Buildroot(recommended): https://github.com/buildroot/buildroot

  * Clone the code:

    ::

      # or git clone https://git.busybox.net/buildroot/
      git clone https://git.busybox.net/buildroot/

  * Check supported configurations: make list-defconfigs
  * Create a config and start building:

    ::

      make qemu_x86_64_defconfig
      make menuconfig
      # Build options:
      # - build packages with debugging symbols: enabled
      # - gcc debug level: 3
      # - strip target binaries: disabled
      # - gcc optimization level: optimize for debugging
      # Toolchain options:
      # - Host GDB Options: enable all
      # Kernel options:
      # - Kernel version: Latest version
      # Target packages options:
      # - Networking applications: openssh
      # Filesystem images options:
      # - ext2/3/4 root filesystem: ext4
      # save and exit
      make -j `nproc` # this will take quite some time
      # if build fails with error like "mkfs.ext2: Could not allocate block in ext2 filesystem while populating file system"
      # make menuconfig
      # Filesystem images -> exact size -> extend the default 60MB, say 120MB

  * Rebuild the kernel image with debug info

    ::

      make linux-menuconfig
      # Kernel hacking:
      # - Kernel debugging: enabled
      # Kernel hacking -> Compile-time checks and compiler options
      # - Debug information: Generate DWARF Version 5 debuginfo
      # - Provide GDB scripts for kernel debugging: enabled
      # Kernel hacking -> Generic Kernel Debugging Instruments
      # - Debug Filesystem
      # Kernel hacking -> Memory Debugging:
      # - Export kernel pagetable layout to userspace via debugfs
      make -j `nproc`

  * Run the qemu vm with gdb server on:

    * Edit buildroot/output/images/start-qemu.sh, adding **-s** to the qemu command line to start gdb server listening on tcp::1234
    * Edit buildroot/output/images/start-qemu.sh, adding **-S** to the qemu command line to disable CPU at startup(to capture everything, continue with gdb continue)
    * Modify network options as **-net nic,model=virtio -net user,hostfwd=tcp::36000-:22** (enable ssh from localhost:36000 on host)
    * Add **nokaslr** to the kernel cmdline
    * ./start-qemu.sh # login the vm as root without password
    * Edit /etc/ssh/sshd_config to enable root empty password login by adding 2 x lines: "PermitRootLogin yes", "PermitEmptyPasswords yes"
    * The script uses buildroot installed qemu-system-x86_64 binary instead of the default one on the system
    * To use the default qemu-system-x86_64 installed on your system, just type: qemu-system-x86_64 ...... directly from the cli

  * Start kernel debugging from another session

    ::

      # it is highly recommended to start gdb from the kernel source root directory
      cd buildroot/output/build/linux-x.y.z
      echo "add-auto-load-safe-path $PWD" >> ~/.gdbinit
      gdb vmlinux
      info auto-load
      target remote :1234
      lx-symbols
      apropos lx-

  * Pros: no need to build a kernel image in advance, buildroot will cover this
  * Cons: the build process is really time consuming

- The Linux Kernel Teaching Labs(the easiest method): https://linux-kernel-labs.github.io

  * git clone https://github.com/linux-kernel-labs/linux
  * cd linux/tools/labs && make docs # check raw docs under Documentation/teaching if the build fails
  * Then follow the docs (Virtual Machine Setup section) to kick start kernel debugging practices
  * Pros: well prepared lectures teaching how to perform kernel debug
  * Cons: the kernel shipped together is not up to date

- Syzkaller create-image: https://github.com/google/syzkaller/blob/master/docs/linux/setup_ubuntu-host_qemu-vm_x86-64-kernel.md#image

  * After creating the image, start the linux kernel as below with qemu(options like cpu, mem, smp, etc. can be adjusted based on real cases, **nokaslr** is always required):

    ::

      # KERNEL - kernel src/build dir
      # IMAGE - where the qemu image is stored
      # The initial ramdisk image can be loaded based on real use cases
      qemu-system-x86_64 \
      -m 512m \
      -kernel $KERNEL/arch/x86/boot/bzImage \
      -append "console=ttyS0 root=/dev/sda earlyprintk=serial nokaslr net.ifnames=0" \
      -drive file=$IMAGE/qemu_image.img,format=raw \
      -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
      -net nic,model=virtio \
      -nographic \
      -pidfile vm.pid \
      -s -S

Connect to the gdb server and begin kernel debugging
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Load linux gdb scripts: after compiling the linux kernel, there will be symbol link named "vmlinux-gdb.py" points to scripts/gdb/vmlinux-gdb.py.

  ::

    # scripts can be loaded manually as below:
    # it is highly recommended to start gdb from the kernel source root directory
    echo "add-auto-load-safe-path /path/to/linux/src/root" > ~/.gdbinit
    gdb
    info auto-load

- Attach to the qemu process with gdb:

  ::

    gdb vmlinux
    target remote :1234
    lx-symbols
    apropos lx- # list gdb scripts supported for kernel debugging
    hb start_kernel # if -S is used while starting the qemu vm
    c

Kernel gdb breakpoints
~~~~~~~~~~~~~~~~~~~~~~~~

gdb breakpoints can be set on kernel symbols which can be located as below:

::

  # to get user space system call summary
  # man syscalls
  # symbol type info: man nm
  cat /proc/kallsyms # the informaiton is the same as /boot/System.map-x.y.z

Here is an example - debug syscall open:

- Based on our knowledge, syscall open will be named as something like sys_open in the kernel;
- grep sys_open /proc/kallsyms: symbol T __x64_sys_open can be located;
- Then set gdb breakpoint on __x64_sys_open: break __x64_sys_open

Check special registers
~~~~~~~~~~~~~~~~~~~~~~~~~~

If kernel is debugged with qemu + gdb remotely, info registers will cover only common registers but not those special registers like control registers(CR0, CR1, etc.), protected mode registers(GDT, LDT, IDT, etc.). Refer to below docs for the introduction of registers.

- https://wiki.osdev.org/CPU_Registers_x86
- https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf

Qemu provides the ability to check all registers including special registers:

::

  # below is an example to dump interrupt description table
  gdb vmlinux
  target remote :1234
  monitor info registers # this is qemu specialized
  set $idtr = 0xfffffe0000001000 # 0xfffffe0000001000 is the value of IDT gotten from monitor info registers

Inspect GDT/LDT
~~~~~~~~~~~~~~~~

::

  monitor info registers
  set $gdtr = 0xfffffe0000001000 # 0xfffffe0000001000 is the GDT value
  # GDT/LDT is an array of struct desc_struct (segment descriptor)
  # - arch/x86/kernel/cpu/common.c DEFINE_PER_CPU_PAGE_ALIGNED
  # - arch/x86/include/asm/desc.h gdt_page
  # - arch/x86/include/asm/desc_defs.h desc_struct
  # print the 1st element
  print /x *(struct desc_struct *)$gdtr
  # print the 2nd element
  print /x *(struct desc_struct *)($gdtr + sizeof(struct desc_struct))

Inspect code selector
~~~~~~~~~~~~~~~~~~~~~~

::

  print /x $cs # output 0x10 - current code selector
  print $cs>>3 # output 0x2 or 2 in decimal, is the GDT/LDT index, refer to https://wiki.osdev.org/Segment_Selector
  monitor info registers
  set $gdtr = 0xfffffe0000000000 # 0xfffffe0000000000 is the GDT value
  # GDT/LDT entries are segment descriptors, refer to https://wiki.osdev.org/Global_Descriptor_Table
  # print the cs corresponding segment descriptor(based on the index, it should be 2nd)
  set $csp = (struct desc_struct *)($gdtr + 1 *sizeof(struct desc_struct)) # the 2nd is 1 * sizeof(struct desc_struct)
  print /x *csp
  # output {limit0 = 0xffff, base0 = 0x0, base1 = 0x0, type = 0xb, s = 0x1, dpl = 0x0, p = 0x1, limit1 = 0xf, avl = 0x0, l = 0x0, d = 0x1, g = 0x1, base2 = 0x0}
  # DPL
  print $csp->dpl # output is 0x0, which means ring 0 - kernel code is running, if it is 0x3, then user code is running
  # get base and limit - with x86_64, base and limit are ignored(works for x86_32), refer to:
  # - https://wiki.osdev.org/Global_Descriptor_Table: segment descriptor section
  # - https://nixhacker.com/segmentation-in-intel-64-bit
  # the limit: 0xfffff - construct with limit1(4 bits) and limit0(16 bits) together(totally 20 bits)
  # the base: 0x0 - construct with base2(8 bits), base1(8 bits) and base0(16 bits) together(totally 32 bits)

Inspect IDT
~~~~~~~~~~~~~

::

  # Refer to https://wiki.osdev.org/Interrupt_Descriptor_Table to find x64 IDT and gate descriptor layout
  monitor info registers
  # - arch/x86/include/asm/desc_defs.h desc_struct:
  # each entries in IDT is a gate descriptor, refer to https://wiki.osdev.org/Interrupt_Descriptor_Table
  p *(struct gate_struct *)$idtr
  set $gd4 = *(struct gate_struct *)($idtr + 128 * 3) # for x86_64, each gate decriptor takes 128 bit, 128 * 3 is the 4th gate descriptor
  print /x $gd4 # output is {offset_low = 0x80d8, segment = 0x10, bits = {ist = 0x0, zero = 0x0, type = 0xe, dpl = 0x0, p = 0x1}, offset_middle = 0x81f1, offset_high = 0xffffffff, reserved = 0x0}
  print (void *) 0xffffffff81f180d8 # 0xffffffff81f180d8 is a combination of offset_high(32 bits), offset_middle(16 bits) and offset_low(16 bits)
  # the above command output the interrupt handler: (void *) 0xffffffff81800b40 <asm_exc_double_fault>

Inspect system call table
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  p sys_call_table
  ptype sys_call_table
  x /16x sys_call_table
  x /16x &sys_call_table

Live debug w/ /proc/kcore
~~~~~~~~~~~~~~~~~~~~~~~~~~

gdb can be used to debug a running kernel with the help of vmlinux and /proc/kcore. The functions are limited, it can only gets a read only view of what is going on in the kernel space.

::

  grep linux_banner /proc/kallsyms
  ffffffff81e001c0 R linux_banner
  gdb vmlinux /proc/kcore
  x/s 0xffffffff81e001c0
  print (const char *) 0xffffffff81e001c0

The crash utility
--------------------

NOTES:

- kernel debuginfo needs to be installed, the package will be named as kernel-debuginfo, kernel-debuginfo-common, etc. on most distributions.
- the crash utility can also be leveraged for analyzing vmcore files or a live system(read only  + basic analysis + without qemu usage).

References:

- https://crash-utility.github.io/crash_whitepaper.html
- https://www.dedoimedo.com/computers/crash-analyze.html
- https://blogs.oracle.com/linux/post/extracting-kernel-stack-function-arguments-from-linux-x86-64-kernel-crash-dumps

Help
~~~~~~

::

  apropos <command pattern>
  help <command>

Live debug
~~~~~~~~~~~~

::

  crash /usr/lib/debug/boot/vmlinux-$(uname -r) /proc/kcore

Show the summary when system crashes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  sys
  sys -i

Use gdb
~~~~~~~~~

::

  gdb info variable task_struct

Load kernel modules and related debug symbol
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  mod
  # refer to https://crash-utility.github.io/help_pages/mod.html
  # suppose kvm.ko is in the default path and kvm.ko.debug in the default debug symbol path
  mod -s kvm.ko
  # suppose kvm.ko in /custom/path/to/modules/ and kvm.ko.debug in /custom/path/to/debug/
  mod -p /custom/path/to/modules/ -s /custom/path/to/debug/ kvm
  # suppose vhost.ko and symbols are together as /usr/lib/debug/lib/modules/5.4.32-1_51211.virt/kernel/drivers/vhost/vhost.ko
  mod -s vhost /usr/lib/debug/lib/modules/5.4.32-1_51211.virt/kernel/drivers/vhost/vhost.ko

Search memory
~~~~~~~~~~~~~~~~

::

  search -c task_struct # Ctrl + c to exit search

Show all symbols
~~~~~~~~~~~~~~~~~~

::

  # refer to man nm to see symbol type explanations, such as D, d, T, t, etc.
  sym -l | grep vm_list | less -is
  sym -q cpu
  sym -m kvm

Iterate over a list
~~~~~~~~~~~~~~~~~~~~~~

::

  # address is the list address
  list <address> -s sli_event.event_type,event_id

VA_BITS_ACTUAL error
~~~~~~~~~~~~~~~~~~~~~~

::

  # error as below may be seen on arm, specify -m vabits_actual to fix the issue
  # crash: cannot determine VA_BITS_ACTUAL
  crash /boot/vmlinux-5.4.119-19-0009.8 vmcore -m vabits_actual=48

Show log
~~~~~~~~~~

::

  crash> log
  [39199.057754] Kernel panic - not syncing: hung_task: blocked tasks
  [39199.295349] CPU: 8 PID: 93 Comm: khungtaskd Kdump: loaded Tainted: G           O      5.4.119-19.0009.27 #1
  [39199.297017] Hardware name: Tencent Cloud CVM, BIOS seabios-1.9.1-qemu-project.org 04/01/2014
  [39199.298362] Call Trace:
  [39199.299069]  dump_stack+0x57/0x6d
  [39199.299861]  panic+0xfb/0x2cb
  [39199.300612]  watchdog+0x2dc/0x340
  [39199.301395]  kthread+0x11a/0x140
  [39199.302157]  ? hungtask_pm_notify+0x50/0x50
  [39199.303002]  ? kthread_park+0x90/0x90
  [39199.303795]  ret_from_fork+0x1f/0x40
  ......
  crash> log | less
  crash> log | grep -C 5 NULL
  [145753.346080] cgroup1: Unknown subsys name 'debug'
  [145753.372424] cgroup1: Unknown subsys name 'debug'
  [145753.398409] cgroup1: Unknown subsys name 'debug'
  [145753.424387] cgroup1: Unknown subsys name 'debug'
  [145753.450265] cgroup1: Unknown subsys name 'debug'
  [145972.585235] BUG: kernel NULL pointer dereference, address: 0000000000000860
  [145972.586490] #PF: supervisor write access in kernel mode
  [145972.587509] #PF: error_code(0x0002) - not-present page
  [145972.588516] PGD 0 P4D 0
  [145972.589248] Oops: 0002 [#1] SMP NOPTI
  [145972.590104] CPU: 5 PID: 15045 Comm: kworker/5:17 Kdump: loaded Tainted: G           OE     5.4.241-1-tlinux4-0017.prerelease4 #1

Get more info from backtrace
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # Decode entry of a stack trace entry: #11 [ffffc9003360be38] kvm_async_build_parallel_tdp_worker+0x217 at ffffffffa0184767  [kvm]
  # #11 - the index number in the stack trace, #0 is the most recent
  # [ffffc9003360be38] - address of Instruction Pointer (IP)/Program Counter (PC) at the time the function was called, A.K.A the return address which would be used when the function call returns
  # kvm_async_build_parallel_tdp_worker - function name being called
  # +0x217 - offset of the function when the backtrace is printed
  # ffffffffa0184767 - memory address where the function is loaded
  # [kvm] - the module/component the function belongs to

  bt
  bt -sx
  bt -FFsx
  bt -l

Show symbol definitions
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  crash> help whatis
  crash> bt
  ...
   #9 [ffff80007442f990] misc_open at ffff80004878b0ec
  #10 [ffff80007442f9d0] chrdev_open at ffff80004838bfd8
  #11 [ffff80007442fa30] do_dentry_open at ffff8000483810fc
  #12 [ffff80007442fa70] vfs_open at ffff8000483827bc
  ...
  crash> whatis misc_open
  int misc_open(struct inode *, struct file *);

Check variables
~~~~~~~~~~~~~~~~~

::

  mod -s kvm
  # check definitions of a structure
  struck kvm
  # or just use the name
  kvm

  # check vm_list
  vm_list
  crash> vm_list
  vm_list = $4 = {
    next = 0xffa0000066fc6178,
    prev = 0xffa00000511d2178
  }
  crash> (struct list_head)0xffa0000066fc6178
  crash: command not found: (struct
  crash> (struct list_head)*0xffa0000066fc6178
  crash: command not found: (struct
  crash> vm_list->next
  crash: command not found: vm_list->next
  crash> print vm_list->next
  $5 = (struct list_head *) 0xffa0000066fc6178
  crash> print *(struct list_head *)vm_list->next
  $6 = {
    next = 0xffa000006306a178,
    prev = 0xffffffffa069f130 <vm_list>
  }
  crash> vm_list
  vm_list = $7 = {
    next = 0xffa0000066fc6178,
    prev = 0xffa00000511d2178
  }
  crash> p vm_list->next
  $8 = (struct list_head *) 0xffa0000066fc6178
  crash> p *(struct list_head *)vm_list->next
  $9 = {
    next = 0xffa000006306a178,
    prev = 0xffffffffa069f130 <vm_list>
  }
  crash> p *(struct list_head *)0xffffffffa069f130
  $10 = {
    next = 0xffa0000066fc6178,
    prev = 0xffa00000511d2178
  }

Find the struct address based on its member address
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # use the struct command struct -ox name or just name -ox
  # let's find the owner(struct kvm) address based on a vm_list address
  crash> mod -s kvm
       MODULE       NAME                        TEXT_BASE         SIZE  OBJECT FILE
  ffffffffa06b9cc0  kvm                      ffffffffa0620000  1392640  /usr/lib/debug/lib/modules/6.6.64-19.0007.virt.tl2.x86_64/kernel/arch/x86/kvm/kvm.ko.debug
  crash> mod -s kvm_amd
       MODULE       NAME                        TEXT_BASE         SIZE  OBJECT FILE
  ffffffffa0897680  kvm_amd                  ffffffffa0aa3000   258048  /usr/lib/debug/lib/modules/6.6.64-19.0007.virt.tl2.x86_64/kernel/arch/x86/kvm/kvm-amd.ko.debug
  crash> vm_list
  vm_list = $1 = {
    next = 0xffa0000066fc6178,
    prev = 0xffa00000511d2178
  }
  crash> struct -ox kvm
  struct kvm {
       [0x0] rwlock_t mmu_lock;
       [0x8] struct mutex slots_lock;
      [0x28] struct mutex slots_arch_lock;
      [0x48] struct mm_struct *mm;
      [0x50] unsigned long nr_memslot_pages;
      [0x58] struct kvm_memslots __memslots[2][2];
    [0x1118] struct kvm_memslots *memslots[2];
    [0x1128] struct xarray vcpu_array;
    [0x1138] atomic_t nr_memslots_dirty_logging;
    [0x113c] spinlock_t mn_invalidate_lock;
    [0x1140] unsigned long mn_active_invalidate_count;
    [0x1148] struct rcuwait mn_memslots_update_rcuwait;
    [0x1150] spinlock_t gpc_lock;
    [0x1158] struct list_head gpc_list;
    [0x1168] atomic_t online_vcpus;
    [0x116c] int max_vcpus;
    [0x1170] int created_vcpus;
    [0x1174] int last_boosted_vcpu;
    [0x1178] struct list_head vm_list;
    [0x1188] struct mutex lock;
    [0x11a8] struct kvm_io_bus *buses[5];
             struct {
    [0x1188]     spinlock_t lock;
                 struct list_head items;
                 struct list_head resampler_list;
                 struct mutex resampler_lock;
    [0x11d0] } irqfds;
    [0x1218] struct list_head ioeventfds;
    [0x1228] struct kvm_vm_stat stat;
    [0x12a0] struct kvm_arch arch;
    [0x98d0] refcount_t users_count;
    [0x98d8] struct kvm_coalesced_mmio_ring *coalesced_mmio_ring;
    [0x98e0] spinlock_t ring_lock;
    [0x98e8] struct list_head coalesced_zones;
    [0x98f8] struct mutex irq_lock;
    [0x9918] struct kvm_irq_routing_table *irq_routing;
    [0x9920] struct hlist_head irq_ack_notifier_list;
    [0x9928] struct mmu_notifier mmu_notifier;
    [0x9968] unsigned long mmu_invalidate_seq;
    [0x9970] long mmu_invalidate_in_progress;
    [0x9978] gfn_t mmu_invalidate_range_start;
    [0x9980] gfn_t mmu_invalidate_range_end;
    [0x9988] struct list_head devices;
    [0x9998] u64 manual_dirty_log_protect;
    [0x99a0] struct dentry *debugfs_dentry;
    [0x99a8] struct kvm_stat_data **debugfs_stat_data;
    [0x99b0] struct srcu_struct srcu;
    [0x99c8] struct srcu_struct irq_srcu;
    [0x99e0] pid_t userspace_pid;
    [0x99e4] bool override_halt_poll_ns;
    [0x99e8] unsigned int max_halt_poll_ns;
    [0x99ec] u32 dirty_ring_size;
    [0x99f0] bool dirty_ring_with_bitmap;
    [0x99f1] bool vm_bugged;
    [0x99f2] bool vm_dead;
    [0x99f8] struct notifier_block pm_notifier;
    [0x9a10] struct xarray mem_attr_array;
    [0x9a20] char stats_id[48];
  }
  SIZE: 0x9a50
  # in kernel space, the address is gotten reversely: vm_list(0xffa0000066fc6178) - offset(0x1178)
  crash> eval 0xffa0000066fc6178 - 0x1178
  hexadecimal: ffa0000066fc5000  (17988010232102676KB)
      decimal: 18419722477673140224  (-27021596036411392)
        octal: 1776400000014677050000
       binary: 1111111110100000000000000000000001100110111111000101000000000000
  crash> p 0xffa0000066fc5000
  $2 = 18419722477673140224
  crash> p (struct kvm *)0xffa0000066fc5000
  $3 = (struct kvm *) 0xffa0000066fc5000
  crash> p *(struct kvm *)0xffa0000066fc5000                                                                                                                                                                                                                                                         $4 = {
    mmu_lock = {
      raw_lock = {
        {
          cnts = {
            counter = 0
          },
          {
            wlocked = 0 '\000',
            __lstate = "\000\000"
          }
        },
        wait_lock = {
          {
            val = {
              counter = 0
            },
            {
              locked = 0 '\000',
              pending = 0 '\000'
            },
            {
              locked_pending = 0,
              tail = 0
            }
          }
        }
      }
    },
    slots_lock = {
    ...

Disassemble
~~~~~~~~~~~~~

- If vmcore is available:

  ::

    crash> bt
    PID: 0      TASK: ffff8887fcb68000  CPU: 10  COMMAND: "swapper/10"
     #0 [ffffc900002a8bd0] machine_kexec at ffffffff810621ef
     #1 [ffffc900002a8c28] __crash_kexec at ffffffff8112bf62
     #2 [ffffc900002a8cf8] panic at ffffffff81bf88f4
     #3 [ffffc900002a8d78] watchdog_timer_fn.cold.9 at ffffffff81bff156
    crash> dis ffffffff81bf88f4
    0xffffffff81bf88f4 <panic+267>: xor    %edi,%edi
    crash> dis ffffffff81bf88f4 5
    0xffffffff81bf88f4 <panic+267>: xor    %edi,%edi
    0xffffffff81bf88f6 <panic+269>: mov    0xe3e6fb(%rip),%rax        # 0xffffffff82a36ff8 <smp_ops+24>
    0xffffffff81bf88fd <panic+276>: callq  0xffffffff82001000 <__x86_indirect_thunk_rax>
    0xffffffff81bf8902 <panic+281>: jmp    0xffffffff81bf8909 <panic+288>
    0xffffffff81bf8904 <panic+283>: callq  0xffffffff81063470 <crash_smp_send_stop>
    crash> help dis # dis -s, dis -rx are used frequently
    crash> dis -s ffffffff81bf88f4
    FILE: /usr/src/debug/kernel-5.4.119-19.0009.16/kernel-5.4.119-19.0009.16/arch/x86/include/asm/smp.h
    LINE: 72

      67    #ifdef CONFIG_SMP
      68    extern struct smp_ops smp_ops;
      69
      70    static inline void smp_send_stop(void)
      71    {
    * 72            smp_ops.stop_other_cpus(0);
      73    }

    crash> dis -s ffffffff81bf88f4 5
    FILE: /usr/src/debug/kernel-5.4.119-19.0009.16/kernel-5.4.119-19.0009.16/arch/x86/include/asm/smp.h
    LINE: 72

      67    #ifdef CONFIG_SMP
      68    extern struct smp_ops smp_ops;
      69
      70    static inline void smp_send_stop(void)
      71    {
    * 72            smp_ops.stop_other_cpus(0);
      73    }
      74
      75    static inline void stop_other_cpus(void)
      76    {
      77            smp_ops.stop_other_cpus(1);

- If vmcore is not available

  ::

    # identify the backtrace found w/ dmesg/console, then search keywords from objdump -S xxx
    objdump -S /boot/vmlinux-xxx | less -is

Check kernel memory of a task
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  crash> kmem -i
                   PAGES        TOTAL      PERCENTAGE
      TOTAL MEM  16137886      61.6 GB         ----
           FREE  16016721      61.1 GB   99% of TOTAL MEM
           USED   121165     473.3 MB    0% of TOTAL MEM
         SHARED    10454      40.8 MB    0% of TOTAL MEM
        BUFFERS     1878       7.3 MB    0% of TOTAL MEM
         CACHED    39042     152.5 MB    0% of TOTAL MEM
           SLAB    16582      64.8 MB    0% of TOTAL MEM

     TOTAL HUGE        0            0         ----
      HUGE FREE        0            0    0% of TOTAL HUGE

     TOTAL SWAP        0            0         ----
      SWAP USED        0            0    0% of TOTAL SWAP
      SWAP FREE        0            0    0% of TOTAL SWAP

   COMMIT LIMIT  8068943      30.8 GB         ----
      COMMITTED   108376     423.3 MB    1% of TOTAL LIMIT
  crash> bt
  PID: 0      TASK: ffff8887fcb68000  CPU: 10  COMMAND: "swapper/10"
   #0 [ffffc900002a8bd0] machine_kexec at ffffffff810621ef
   #1 [ffffc900002a8c28] __crash_kexec at ffffffff8112bf62
   #2 [ffffc900002a8cf8] panic at ffffffff81bf88f4
   #3 [ffffc900002a8d78] watchdog_timer_fn.cold.9 at ffffffff81bff156
   #4 [ffffc900002a8db0] __hrtimer_run_queues at ffffffff8110b1e7
  ...
  crash> kmem ffff8887fcb68000
  CACHE             OBJSIZE  ALLOCATED     TOTAL  SLABS  SSIZE  NAME
  ffff8887fc80a680     9984        232       291     97    32k  task_struct
    SLAB              MEMORY            NODE  TOTAL  ALLOCATED  FREE
    ffffea001ff2da00  ffff8887fcb68000     0      3          3     0
    FREE / [ALLOCATED]
    [ffff8887fcb68000]

      PID: 0
  COMMAND: "swapper/10"
     TASK: ffff8887fcb68000  (1 of 16)  [THREAD_INFO: ffff8887fcb68000]
      CPU: 10
    STATE: TASK_RUNNING (PANIC)

        PAGE        PHYSICAL      MAPPING       INDEX CNT FLAGS
  ffffea001ff2da00 7fcb68000 ffff8887fc80a680        0  1 17ffffc0010200 slab,head

MISC
------

Check shared object/library dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ldd <object or executable file>
  LD_DEBUG=libs ldd <object or executable file>

Check object/executable file information
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- objdump: display info for object files
- nm: list symbols from object files
- pahole: show data structures of object files(including running kernels)
- readelf: display info for ELF files
- ldd: print object dependencies
- elfutils: a set of tools used to read, create and modify elf files(refer to https://sourceware.org/elfutils/)

::

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

debuginfo-install
~~~~~~~~~~~~~~~~~~~~~

::

  # work on rpm based distributions, part of yum-utils
  debuginfo-install search ethtool
  debuginfo-install install ethtool-debuginfo

Get core file's application info
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # sometimes, it is not easy to find which application triggers the core to be debugged just based on the core file's name
  eu-unstrip -n --core <core file> # the first entry points to the absolute path of the application
  eu-unstrip -n -e /path/to/binary # check if the hash for a binary is the same as in the core

unstrip/combine files with degbugging info
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  file /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
  cp /usr/local/bin/qemu-system-x86_64 /usr/local/bin/qemu-system-x86_64.bak
  cp /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug.bak
  eu-unstrip /usr/local/bin/qemu-system-x86_64 /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
  mv /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug /usr/local/bin/qemu-system-x86_64
  chmod a+x /usr/local/bin/qemu-system-x86_64

Create core file for a running process
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  gcore <pid>

Extract bits w/ bitwise ops
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # 1. create a suitable binary mask with ones only covering the position needed;
  # 2. perform a bitwise and operation between the number and the mastk;
  # 3. right shift;
  # Example: get the middle 48 bits(totally 64 bits) from 0xffffffff81e0a000
  d = 0xffffffff81e0a000
  mask = 0x00ffffffffffff00 # with prefix and suffix total 16 bits as 0
  d & mask # 0xffffff81e0a000
  0xffffff81e0a000 >> 8 # 0xffffff81e0a0

Trigger panic when softlockup(or other problems) is hit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # sysctl -a | grep -i panic
  echo 1 > /proc/sys/kernel/softlockup_panic

Trigger a vmcore to analyze system problems
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  echo b > /proc/sysrq-trigger

Change kernel log level
~~~~~~~~~~~~~~~~~~~~~~~~~~

Append loglevel=X to cmdline(refer to kernel-parameters.txt):

- 0 ~ 7
- 0: KERN_EMERG
- 1: KERN_ALERT
- 2: KERN_CRIT
- 3: KERN_ERR
- 4: KERN_WARNING
- 5: KERN_NOTICE
- 6: KERN_INFO
- 7: KERN_DEBUG

Work around PATH|LD_LIBRARY_PATH compiling error
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # This works for not just kernel but also other projects.
  # Below error might be hit:
  You seem to have the current working directory in your <PATH|LD_LIBRARY_PATH> environment variable. This doesn't work.
  # Fix
  export PATH=`echo $PATH | sed -e 's/::/:/g'`
  export LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | sed -e 's/::/:/g'`
  make

Get kernel memory mappings
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # make sure below options are enabled during kernel compilation
  # Kernel hacking -> Generic Kernel Debugging Instruments
  # - Debug Filesystem(DEBUG_FS)
  # Kernel hacking -> Memory Debugging:
  # - Export kernel pagetable layout to userspace via debugfs(PTDUMP_DEBUGFS)
  # make sure debugfs is mouted, if not: mount -t debugfs none /sys/kernel/debug
  cat /sys/kernel/debug/page_tables/kernel

Get kernel memory layout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/iomem
  cat /boot/System.map-`uname -r` | grep -w -e '_text' -e '_etext' -e '_edata' -e '_end'

Get I/O ports information
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  cat /proc/ioports

Decode dmesg timestamp
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # some old version linux does not support changing dmesg timestamp to human friendly format
  # meanwhile, dmesg during crash cannot be decoded as human friendly format
  # get the timestamp when the system is booted
  uptime -s
  # dmesg timestamp is the seconds passed since the boot time, just add it to boot time
  # cat /proc/stat | grep btime # the seconds since the Epoch

System boot-up performance profile
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  systemd-analyze blame

Tracing
---------

Overview
~~~~~~~~~~~

- https://jvns.ca/blog/2017/07/05/linux-tracing-systems/#data-sources

strace
~~~~~~~~~

Trace system calls and signals:

::

  strace -c xxx
  strace -c -f xxx
  strace xxx

LD_DEBUG
~~~~~~~~~~

Work similarly as strace but focus on dynamic linker operations. Especially useful when debugging program compile realted issues:

::

  LD_DEBUG=help ls
  LD_DEBUG=all ls
  export LD_DEBUG=all
  make

perf-tool
~~~~~~~~~~~~~~

Performance analysis tools based on Linux perf_events (aka perf) and ftrace:

- bitesize
- cachestat
- execsnoop
- funccount
- funcgraph
- funcslower
- functrace
- iolatency
- iosnoop
- killsnoop
- kprobe
- opensnoop
- perf-stat-hist
- reset-ftrace
- syscount
- tcpretrans
- tpoint
- uprobe

References:

- https://perf.wiki.kernel.org/index.php/Tutorial

Example 0: Help

::

  # tune maxed num. of open files
  ulimit -n 65536
  perf help
  # list supported events
  perf list
  perf list 'sched:*'

Example 1: Scheduler Analysis

::

  # Record all scheduler events within 1 second
  perf sched record -- sleep 1
  # To check detailed events
  perf script [--header]
  # Summarize scheduler latencies by task
  perf sched latency [-s max]

Example 2: Performance Analysis

::

  # the whole system performance stat
  perf stat record -a sleep 10
  perf kvm stat record -a sleep 10
  # specified vcpu performance
  perf kvm stat record -a -p <vcpu tid> -a sleep 10
  # report
  perf stat report
  perf kvm stat report

Example 3: perf trace

::

  # trace a process
  perf trace record --call-graph dwarf -p $PID -- sleep 10
  # trace a group of processes
  mkdir /sys/fs/cgroup/perf_event/bpftools/
  echo 22542 >> /sys/fs/cgroup/perf_event/bpftools/tasks
  echo 20514 >> /sys/fs/cgroup/perf_event/bpftools/tasks
  perf trace -G bpftools -a -- sleep 10

Example 4: what is running on a specific cpu

::

  perf record -C 1 -F 99 -- sleep 10
  perf report

Example 5: system profiling overview

::

  perf top
  perf top --sort pid,comm,dso,symbol

Example 6: record with call graph

::

  perf record -ag -e 'sched:*' -- sleep 10
  perf report -g --stdio

Example 7: dynamic tracepoint

::

  # the function(tracepoint) needs to be enabled at first
  # if the application is in kernel space, add it as below:
  # perf probe -m kvm -a func_name
  perf probe -l
  perf probe -f -x /usr/lib64/libc-2.28.so -a inet_pton
  perf probe -l
  # start a process which triggers inet_pton in another terminal
  perf record -e probe_libc:inet_pton ...
  perf report --stdio
  perf probe -d probe_libc:inet_pton

Example 8: visualize total system behavior

::

  perf timechart record
  perf report
  # open the output svg

trace-cmd
~~~~~~~~~~

trace-cmd is a frontend for ftrace, and its cli works similar as perf. Use it directly instead of using ftrace whenever possible.

::

  trace-cmd list
  trace-cmd record -P `pidof qemu` -e kvm
  trace-cmd report
  trace-cmd record -p function_graph -P `pidof top`
  trace-cmd report
  trace-cmd record -e kvm:*irq* -P `pidof qemu` -p function_graph sleep 5
  trace-cmd report
  trace-cmd list -f | grep kvm_create
  trace-cmd record -l kvm_create_* -p function_graph
  trace-cmd stop
  trace-cmd clear # or trace-cmd reset

ftrace
~~~~~~~~~

Ftrace is an internal tracer designed to help out developers and designers of systems to find what is going on inside the kernel. It can be used for debugging or analyzing latencies and performance issues that take place outside of user-space. Refer to https://www.kernel.org/doc/Documentation/trace/ftrace.txt for information on ftrace.

event tracing
****************

**tracing**

::

  # method 1 - through event toggle
  cd /sys/kernel/debug/tracing/
  cat available_events # list all availabel events which can be traced
  ls events # list all available events which is organized in groups
  echo 1 > events/path/to/event/enable # enable the event tracing, multiple events can be traced
  echo 1 > tracing_on
  echo > trace
  cat trace # check trace results
  # method 2 - through set_event
  echo > set_event # clear previous events
  echo "event1" > set_event # multiple event tracing: echo "event2" >> set_event
  echo 1 > tracing_on
  echo > trace
  cat trace

**filtering**

::

  # event filter
  cat events/path/to/event/format # understand the supported event format
  echo "filter expression" > events/path/to/event/filter
  echo 0 > events/path/to/event/filter # clear the filter
  # event subsystem filter
  cd events/subsystem/path
  echo 0 > filter
  echo "filter expression" > filter

**pid filtering**

::

  cd /sys/kernel/debug/tracing
  echo <PID> > set_event_pid # filtering multiple PIDs: echo <PID1> <PID2> <...> >> set_event_pid
  ...

function tracing
*******************

**tracing**

::

  cat available_tracers # list all available traces, function, function_graph are used most frequently
  # function
  echo function > current_tracer
  cat available_filter_functions # get filters which can be used for function tracing
  echo <available filter> > set_ftrace_filter # multiple filter can be used - echo <another filter> >> set_ftrace_filter
  # multiple function filters can be configured as : echo <function_name_prefix>* > set_ftrace_filter
  echo > trace
  cat trace # check trace results
  # function graph: function graph will provides latency data which is recommended
  echo function_graph > current_tracer
  cat available_filter_functions # get filters which can be used for function graph tracing
  echo <available filter> > set_graph_function # multiple filter can be used - echo <another filter> >> set_graph_function
  echo 10 > max_graph_depth
  echo > trace
  cat trace # check trace results

**trace_pipe**

::

  # trace_pipe only contains newer data compared with last read, suitable for redirection
  cat trace_pipe
  cat trace_pipe > /tmp/trace.log

kprobe
*********

TBD

uprobe
********

The usage of uprobe is more complicated than kprobe. Let's demonstrace how to trace the function hmp_info_cpus of application qemu-system-x86_64.

**Calculate function offset**

1. Find the function offset:

::

  # refer to https://www.kernel.org/doc/html/latest/_sources/filesystems/proc.rst.txt for information on /proc/PID/maps
  objdump -tT /usr/local/bin/qemu-system-x86_64 | grep hmp_info_cpus
  # the output is: 00000000005ce6d0 g    DF .text  0000000000000158  Base        hmp_info_cpus
  # the offset is 00000000005ce6d0
  cat /proc/`pidof qemu-system-x86_64`/maps | grep r-xp | grep qemu-system-x86_64
  # th output is: 00400000-00baf000 r-xp 00000000 08:03 131826                             /usr/local/bin/qemu-system-x86_64
  # the output indicates the code segment address(r-xp) range for the application(qemu-system-x86_64),
  # for other user applications on the same system, the range actually will be the same value.
  # based on 0x00400000(code segment begins) and 0x5ce6d0(hmp_info_cpus offset), the real offset
  # of hmp_info_cpus compared with the staring address can be gotten as: 0x5ce6d0-0x400000 = 0x1ce6d0

2. Enable uprobe tracers:

::

  # refer to https://www.kernel.org/doc/Documentation/trace/uprobetracer.txt for information on uprobe usage syntax
  # refer to https://docs.kernel.org/_sources/trace/uprobetracer.rst.txt for uprobe examples
  cd /sys/kernel/debug/tracing
  echo 0 > tracing_on # disable ftrace
  echo 0 > events/uprobes/enable # disable uprobes
  echo > uprobe_events # clear
  # pitfalls: the application to be traced must have been started before issuing below commands
  echo 'p:hmp_info_cpus_entry /usr/local/bin/qemu-system-x86_64:0x1ce6d0' > uprobe_events # uprobe
  echo 'r:hmp_info_cpus_exit /usr/local/bin/qemu-system-x86_64:0x1ce6d0' >> uprobe_events # uretprobe
  # after running the above commands, events/uprobes/hmp_info_cpus/ will be created dynamically
  # check the event format: cat events/uprobes/hmp_info_cpus/format
  # enable the individual uprobe events: echo 1 > events/uprobes/hmp_info_cpus/enable
  echo 1 > events/uprobes/enable # enable all uprobes
  echo 1 > tracing_on # turn on ftrace
  echo > trace
  virsh qemu-monitor-command xxxxxx --hmp info cpus # trigger the hmp_info_cpus function
  cat trace # the tracing result
  # show user space stack
  # make sure the application is compiled with debugging info,
  # otherwise, the user stack trace will be memory addresses based
  echo 1 > options/latency-format # enable latency output format
  echo 1 > options/userstacktrace # enable user stack strace
  echo 1 > options/sym-userobj
  echo 1 > options/sym-addr
  echo 1 > options/sym-offset
  echo > trace
  virsh qemu-monitor-command xxxxxx --hmp info cpus
  cat trace

blktrace
~~~~~~~~~~~

1. **blktrace** is a block layer IO tracing mechanism which provides detailed information about request queue operations up to user space. The trace result is stored in a binary format, which obviously doesn't make for convenient reading;
2. The tool for that job is **blkparse**, a simple interface for analyzing the IO traces dumped by blktrace;
3. However, the plaintext trace result generated by blkparse is still not quite easy for reading, another tool **btt** can be used to generate misc reports, such as latency report, seek time report, etc;
4. Besides, a tool named **Seekwatcher** can be used to genrate graphs for blktrace, which will help a lot comparing IO patterns and performance;
5. In the meanwhile, **btrecord** and **btreplay** can be used to recreate IO loads recorded by blktrace.

