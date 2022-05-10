GDB
=====

GDB tips.

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

  # Disamble
  objdump -S <ELF file>
  # Display dynamic symbol tables
  objdump -T <ELF file>
  readelf --dyn-syms <ELF file>
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
  eu-unstrip -c --core <core file> # the first entry points to the absolute path of the application

gdb with args
---------------

::

  # arg1, arg2, ... can be something like --abc -d
  gdb --args <executable> arg1 arg2 ...

Find commands
---------------

::

  # apropos <command regex>
  apropos info
  apropos break

TUI usage
-----------

TUI is short for text UI which can be used to display source code, asm, and registers during debugging:

- tui enable/disable:  toggle TUI, Ctr + x + a as the shortcut
- layout src/asm/splig: witch TUI display layout, Ctr + x + 1/2 as the shortcut

Convenience Variables
-----------------------

* Any name preceded by '$' can be used for a convenience variable;
* Reference https://sourceware.org/gdb/onlinedocs/gdb/Convenience-Vars.html
* Usage:

  ::

    set $foo =  (struct CharDriverState *)0x4dfcb40
    p $foo->chr_write_lock

Define a customized command
-----------------------------

::

  define idt_entry
  set $entry = *(uint64_t*)($idtr + 8 * $arg0)
  print (void *)(($entry>>48<<16)|($entry&0xffff))
  end
  set $idtr = 0xfffffe0000000000
  idt_entry 0
  idt_entry 1

Check registers
-----------------

::

  info registers
  info registers <register name>
  print /x $eax # every register gets a convenience variable assigned automationly as $<register name>
  x /x $eax
  monitor info registers # this is only available when debugging kernel with qemu(a qemu extension)

Kernel Debugging
-----------------

Linux kernel debugging tips.

Build linux kernel
~~~~~~~~~~~~~~~~~~~~

- Generate the init .config

  ::

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
      # Kernel hacking -> Compile the kernel with debug info:
      # - Compile the kernel with debug info: enabled
      # - Provide GDB scripts for kernel debugging: enabled
      make -j `nproc`

  * Run the qemu vm with gdb server on:

    * Edit buildroot/output/images/start-qemu.sh, adding **-s** to the qemu command line(start a qemu server)
    * Add **nokaslr** to the kernel cmdline
    * ./start-qemu.sh # login the vm as root without password
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

