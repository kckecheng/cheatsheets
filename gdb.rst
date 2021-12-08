GDB
=====

GDB tips.

Kernel Debugging
-----------------

Linux kernel debugging tips.

Load linux gdb scripts
~~~~~~~~~~~~~~~~~~~~~~~~

Required options:

- CONFIG_DEBUG_INFO=y
- CONFIG_GDB_SCRIPTS=y
- CONFIG_DEBUG_INFO_REDUCED=n

After compiling the linux kernel, there will be symbol link named "vmlinux-gdb.py" points to scripts/gdb/vmlinux-gdb.py. To load it:

::

  echo "add-auto-load-safe-path /path/to/linux/src/root" > ~/.gdbinit
  gdb vmlinux
  info auto-load

Debug kernel with qemu
~~~~~~~~~~~~~~~~~~~~~~~~

- A qemu image containing the base system is required. Below methods can be referred to:

  * Manual installation: https://github.com/hardenedlinux/Debian-GNU-Linux-Profiles/blob/master/docs/harbian_qa/fuzz_testing/syzkaller_general.md
  * Build root: https://github.com/buildroot/buildroot (google search how to leverage qemu + buildroot together)
  * Syzkaller create-image: https://github.com/google/syzkaller/blob/master/docs/linux/setup_ubuntu-host_qemu-vm_x86-64-kernel.md#image

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
