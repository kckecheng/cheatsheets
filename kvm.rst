.. contents:: Linux Virtualization

=====================
Linux Virtualization
=====================

virsh
------

Host/Node Information
~~~~~~~~~~~~~~~~~~~~~~~

::

  virsh nodeinfo

List VMs
~~~~~~~~~

::

  # List all
  virsh list --all
  # List active
  virsh list

Auto Start a VM
~~~~~~~~~~~~~~~~

::

  virsh dominfo test
  virsh autostart [--disable] test

Power Control on VM
~~~~~~~~~~~~~~~~~~~~

::

  virsh <start|shutdown|destroy|reboot|suspend|resume> test

Destroy a VM Clearly
~~~~~~~~~~~~~~~~~~~~~

::

  virsh destroy test
  virsh undefine test
  virsh pool-refresh default
  virsh vol-delete --pool default <disk.qcow2>

Create a VM
~~~~~~~~~~~~

::

  sudo virt-install \
  --name centos7 \
  --description "CentOS 7" \
  --ram=1024 \
  --vcpus=2 \
  --os-type=Linux \
  --os-variant=rhel7 \
  --disk path=/var/lib/libvirt/images/centos7.qcow2,bus=virtio,size=10 \
  --graphics none \
  --location $HOME/iso/CentOS-7-x86_64-Everything-1611.iso \
  --network bridge:virbr0  \
  --console pty,target_type=serial -x 'console=ttyS0,115200n8 serial'

Connect to a VM
~~~~~~~~~~~~~~~~

::

  # Press Ctrl + ] or Ctrl + 5 to exit
  virsh console test

Edit VM xml
~~~~~~~~~~~

::

  virsh edit test
  EDITOR=vim virsh edit test

Save/Restore a VM
~~~~~~~~~~~~~~~~~~

::

   virsh save test <New Name>
   virsh restore <New Name>

Volume
~~~~~~~

Volume operations

Create
+++++++

::

  virsh vol-create-as default  test_vol2.qcow2  2G
  du -sh /var/lib/libvirt/images/test_vol2.qcow2

Attach
+++++++

::

  virsh attach-disk --domain test \
  --source /var/lib/libvirt/images/test_vol2.qcow2  \
  --persistent --target vdb

Detach
+++++++

::

  virsh detach-disk --domain test --persistent --live --target vdb

Resize
+++++++

::

  qemu-img resize /var/lib/libvirt/images/test.qcow2 +1G

Delete
+++++++

::

  virsh vol-delete test_vol2.qcow2  --pool default
  virsh pool-refresh  default
  virsh vol-list default

Snapshot
~~~~~~~~~

Snapshot operations.

Create
+++++++

::

  virsh snapshot-create-as --domain test \
  --name "test_vm_snapshot1" \
  --description "test vm snapshot 1-working"

List
+++++

::

  virsh snapshot-list test

Query
++++++

::

  virsh snapshot-info --domain test --snapshotname test_vm_snapshot1

Revert
+++++++

::

  virsh snapshot-revert --domain test  --snapshotname test_vm_snapshot1  --running

Delete
+++++++

::

   virsh snapshot-delete --domain test --snapshotname  test_vm_snapshot2

Clone a VM
~~~~~~~~~~~

::

  virt-clone --connect qemu:///system \
  --original test \
  --name test_clone \
  --file /var/lib/libvirt/images/test_clone.qcow2

Tune CPU
~~~~~~~~~

::

  virsh setvcpus --domain test --maximum 2 --config
  virsh setvcpus --domain test --count 2 --config
  virsh reboot test
  virsh dominfo test

Tune Memory
~~~~~~~~~~~~

::

  virsh setmaxmem test 2048 --config
  virsh setmem test 2048 --config
  virsh reboot test
  virsh dominfo test

Operate Files in VM
~~~~~~~~~~~~~~~~~~~~

::

  virt-ls -l -d test /root
  virt-cat -d test /etc/redhat-release
  virt-edit -d test /etc/hosts
  virt-df -d test
  virt-filesystems -l -d test

Show VM Stats
~~~~~~~~~~~~~~

::

  virt-top
  virt-top --debug

Check VM Log
~~~~~~~~~~~~~

::

  virt-log -d test

Copy Files to a VM
~~~~~~~~~~~~~~~~~~~

::

  # create an iso image
  genisoimage -o data.iso <files/folder>
  # find target device
  virsh dumpxml <ID/Name> # get the target device name, e.g. hdb
  # attach the iso
  virsh attach-disk <ID/Name> /<absolute path>/data.iso hdb --sourcetype block --driver qemu --subdriver raw --type cdrom
  # Mount in the VM
  virsh console <ID/Name>
  lsblk # or lsscsi
  mount /dev/sr0 /mnt

cpuid
--------

libvirt cpuid definition verification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

libvirt needs to understandard cpu features. To support this, src/cpu/cpu_map.xml is used.

To verify if a feature exists within vm, run cpuid from vm os:

- decode ebx='0x00000200' to binary as 0b1000000000
- cpuid -r -1 -l 7 # here 7 refers to eax_in='0x07'
- from cpuid output, decode ebx, say 0x209c03a9 to binary as 0b100000100111000000001110101001
- check 0b1000000000 & 0b100000100111000000001110101001, if it eauals to 0b1000000000, yes - feature enabled

::

  <feature name='erms'>
    <cpuid eax_in='0x07' ebx='0x00000200'/>
  </feature>

