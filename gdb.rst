GDB
=====

GDB tips.

gdb with args
---------------

::

  # arg1, arg2, ... can be something like --abc -d
  gdb --args <executable> arg1 arg2 ...

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

Load linux gdb scripts
~~~~~~~~~~~~~~~~~~~~~~~~

After compiling the linux kernel, there will be symbol link named "vmlinux-gdb.py" points to scripts/gdb/vmlinux-gdb.py. To load it:

::

  # scripts can be loaded manually as below:
  # gdb vmlinux
  # add-auto-load-safe-path /path/to/linux/src/root
  # source vmlinux-gdb.py
  echo "add-auto-load-safe-path /path/to/linux/src/root" > ~/.gdbinit
  gdb vmlinux
  info auto-load

Debug kernel with qemu
~~~~~~~~~~~~~~~~~~~~~~~~

- A qemu image containing the base system is required. Below methods can be referred to:

  * Manual installation: https://github.com/hardenedlinux/Debian-GNU-Linux-Profiles/blob/master/docs/harbian_qa/fuzz_testing/syzkaller_general.md
  * Build root: https://github.com/buildroot/buildroot (google search how to leverage qemu + buildroot together)
  * Syzkaller create-image(the recommended method): https://github.com/google/syzkaller/blob/master/docs/linux/setup_ubuntu-host_qemu-vm_x86-64-kernel.md#image

- Boot the compiled kernel with the qemu image(qemu cpu, mem, smp, etc. can be adjusted based on real cases):

  ::

    # KERNEL - kernel src/build dir
    # IMAGE - where the qemu image is stored
    qemu-system-x86_64 \
    -m 512m \
    -kernel $KERNEL/arch/x86/boot/bzImage \
    -append "console=ttyS0 root=/dev/sda earlyprintk=serial nokaslr net.ifnames=0" \
    -drive file=$IMAGE/buster.img,format=raw \
    -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
    -net nic,model=virtio \
    -nographic \
    -pidfile vm.pid \
    -s -S

- Attach to the qemu process with gdb:

  ::

    gdb vmlinux
    target remote :1234
    c

- TUI Usage

  * Ctr + x + a: toggle TUI
  * Ctr + x + 1/2: switch display layout

- Convenience Variables

  * Any name preceded by ‘$’ can be used for a convenience variable;
  * Reference https://sourceware.org/gdb/onlinedocs/gdb/Convenience-Vars.html
  * Usage:

    ::

      set $foo =  (struct CharDriverState)*0x4dfcb40).chr_write_lock
      p $foo
