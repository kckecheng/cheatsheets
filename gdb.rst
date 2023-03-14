GDB
=====

GDB tips. Refer to https://www.sourceware.org/gdb/current/onlinedocs/gdb.html for gdb reference.

Tools which facilitate gdb
---------------------------

Tools which can be used to get more information about the program being debugged before leveraging gdb.

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
  # Disamble
  objdump -S <ELF file>
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

Get core file's application info
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # sometimes, it is not easy to find which application triggers the core to be debugged just based on the core file's name
  eu-unstrip -n --core <core file> # the first entry points to the absolute path of the application

unstrip/combine files with degbugging info
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  file /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
  cp /usr/local/bin/qemu-system-x86_64 /usr/local/bin/qemu-system-x86_64.bak
  cp /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug.bak
  eu-unstrip /usr/local/bin/qemu-system-x86_64 /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug
  mv /usr/lib/debug/usr/local/bin/qemu-system-x86_64.debug /usr/local/bin/qemu-system-x86_64
  chmod a+x /usr/local/bin/qemu-system-x86_64

gdb common tips
-----------------

Common tips.

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

List source code
~~~~~~~~~~~~~~~~~~

::

  # some non-default usage of list
  list *0xc021e50e # list source from the line where the address points to
  list *vt_ioctl+0xda8 # list souce from the line based on the function address(*vt_ioctl) and its offset(+0xda8)
  list *$pc # list source from the line where the pc register points to
  # 1 x line of source code might be compiled into several lines of instructions, use info line linespec to show the starting and ending addresses
  info line *0xffffffff81026260 # show the starting and ending addresses for the source line the address 0xffffffff81026260 points to

Pretty print
~~~~~~~~~~~~~~

::

  # print struct pretty
  apropos pretty
  set print pretty
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

Print definition of an expression
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  ptype (struct task_struct *)0xffffffff81e12580

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

Set breakpoints on all functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  rbreak <regex> # set breakpoints on all functions matching the regular expression
  rbeak <file>:<regex> # set breakpoints on all functions matching the regular expression for the file
  rbreak . # break in all functions
  rbreak <file>:. # break in all functions for the file

Check registers
~~~~~~~~~~~~~~~~~

::

  info registers
  info registers <register name>
  print /x $eax # every register gets a convenience variable assigned automationly as $<register name>
  x /x $eax
  monitor info registers # this is only available when debugging kernel with qemu(a qemu extension)

Follow child processes
~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # gdb follows the parent process by default, to follow the child process
  set follow-fork-mode child
  # follow both the parent and the children
  set detach-on-fork off
  info inferiors
  inferior <parent or children id>

Binary values
~~~~~~~~~~~~~~~

::

  set $v1 = 0b10
  print /t $v1
  print $v1

Run gdb commands through CLI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  grep r--p /proc/6666/maps \
    | sed -n 's/^\([0-9a-f]*\)-\([0-9a-f]*\) .*$/\1 \2/p' \
    | while read start stop; do \
      gdb --batch --pid 6666 -ex "dump memory 6666-$start-$stop.dump 0x$start 0x$stop"; \
      done

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
  c
  bt
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
  set $counter = 1
  while ($counter <= 10)
  c
  bt
  set $counter = $counter + 1
  end
  q
  EOF
  gdb -q -p `pgrep -f qemu-system-x86_64` -x pbt.gdb
  # from another session, trigger the breakpint by executing below command:
  # virsh qmeu-monitor-command xxxxxx --hmp info cpus

trace into glibc
~~~~~~~~~~~~~~~~~~~

::

  # glibc debug information is not provided by default
  # install glibc debugging information
  # this is an example on ubuntu, other distros are similar
  sudo apt install -y libc6-dbg
  # except for the symbols, source code of glibc is also needed
  # here is an example on ubuntu, other distros are similar
  sudo apt install -y glibc-source
  cp /usr/src/glibc/glibc-2.31.tar.xz ~/
  tar -Jxf glibc-2.31.tar.xz
  # begin debug
  cd /path/to/program
  gdb /path/to/program
  set verbose on # to show how the glibc symbols are searched and loaded
  start # start will run the program and stop at main (different from run)
  list
  b printf # or any functions defined within glibc
  c
  # gdb may prompt that: printf.c: No such file or directory
  # add the source file direcotry
  find ~/glibc-2.31 -name printf.c
  directory ~/glibc-2.31/stdio-common
  list # the source code from glibc will be shown

Disable paging
~~~~~~~~~~~~~~~~

::

  # by default, bt and some other commands will page,
  # end users need to press return again and again
  # to disable it:
  set pagination off

Kernel Debugging
-----------------

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

- Build the kernel

  ::

    # vmlinux, arch/x86/boot/bzImage will be created
    make -j`nproc`

- Create initramfs file

  ::

    # sudo apt install -y dracut
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
      # Kernel debugging: enabled
      # Kernel hacking -> Compile-time checks and compiler options
      # - Compile the kernel with debug info: enabled
      # - Provide GDB scripts for kernel debugging: enabled
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

The crash utility
--------------------

The crash utility can also be leveraged for analyzing vmcore files or a live system(read only  + basic analysis + without qemu usage). Check https://crash-utility.github.io/crash_whitepaper.html for reference.

In the meanwhile, there is a great sample on how to use crash to anylyze a core dump - https://www.dedoimedo.com/computers/crash-analyze.html

Use gdb
~~~~~~~~~

::

  gdb info variable task_struct

Search memory
~~~~~~~~~~~~~~~~

::

  search -c task_struct # Ctrl + c to exit search

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

Disassemble
~~~~~~~~~~~~~

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
  crash> help dis
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

Check kernel memory of a task
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

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

Trigger panic when softlockup(or other problems) is hit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # sysctl -a | grep -i panic
  echo 1 > /proc/sys/kernel/softlockup_panic

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


