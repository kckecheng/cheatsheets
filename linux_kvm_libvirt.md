---
tags: [linux, cheatsheet, kvm, qemu, libvirt]
aliases: ["kvm", "qemu", "libvirt", "virsh"]
type: cheatsheet
---
# Linux KVM & Libvirt
## Host/Node Information

```bash
virsh nodeinfo
```

## Auto Start a VM

```bash
virsh dominfo test
virsh autostart [--disable] test
```

## Destroy a VM Clearly

```bash
virsh destroy test
virsh undefine test
virsh pool-refresh default
virsh vol-delete --pool default <disk.qcow2>
```

## Create a VM

```bash
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
```

## Capture a screenshot

```bash
# screenshot is saved as ppm file which needs to be opened with special software(there exists online tools)
virsh screenshot xxxx --file snap1.ppm
```

## Edit VM live xml

```bash
virsh edit test
EDITOR=vim virsh edit test
```

## Image Resize

```bash
qemu-img resize /var/lib/libvirt/images/test.qcow2 +1G
```

## Tune CPU

```bash
virsh setvcpus --domain test --maximum 2 --config
virsh setvcpus --domain test --count 2 --config
virsh reboot test
virsh dominfo test
```

## Tune Memory

```bash
virsh setmaxmem test 2048 --config
virsh setmem test 2048 --config
virsh reboot test
virsh dominfo test
```

## Copy Files to a VM

```bash
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
```

## libvirt cpuid definition verification

libvirt needs to understand cpu features. To support this, src/cpu/cpu_map.xml is used.

To verify if a feature exists within vm, run cpuid from vm os:

- decode ebx='0x00000200' to binary as 0b1000000000
- cpuid -r -1 -l 7 # here 7 refers to eax_in='0x07'
- from cpuid output, decode ebx, say 0x209c03a9 to binary as 0b100000100111000000001110101001
- check 0b1000000000 & 0b100000100111000000001110101001, if it equals to 0b1000000000, yes - feature enabled

```xml
<feature name='erms'>
  <cpuid eax_in='0x07' ebx='0x00000200'/>
</feature>
```

## Non-interactive ops with vm

```bash
# login
while : ; do
  pty=$(virsh ttyconsole $uuid)
  timeout 1 cat $pty > serial_log
  result=`tail -n 1 serial_log`

  if [[ $result =~ "login:"  ]]; then
    echo $username > $pty
    echo > $pty
    continue
  elif [[ $result =~ "Password:"  ]]; then
    echo $passwd > $pty
    echo  > $pty
    echo
  elif [[ $result =~ "root@"  ]]; then
    break
  else
    echo > $pty
  fi
  sleep 3
done

# reboot
echo reboot > $pty
echo > $pty
```

## Related
- [[linux_storage]]
- [[debug_kernel_gdb]]
- [[debug_crash]]

