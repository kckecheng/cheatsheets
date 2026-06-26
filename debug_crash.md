---
tags: [debug, cheatsheet, crash, kernel]
aliases: ["crash", "crash utility", "vmcore"]
type: cheatsheet
---
# crash Utility
## The crash utility

NOTES:

- kernel debuginfo needs to be installed, the package will be named as kernel-debuginfo, kernel-debuginfo-common, etc. on most distributions.
- the crash utility can also be leveraged for analyzing vmcore files or a live system (read only + basic analysis + without qemu usage).

References:

- https://crash-utility.github.io/crash_whitepaper.html
- https://www.dedoimedo.com/computers/crash-analyze.html
- https://blogs.oracle.com/linux/post/extracting-kernel-stack-function-arguments-from-linux-x86-64-kernel-crash-dumps

### Help

```
apropos <command pattern>
help <command>
```

### Live debug

```
crash /usr/lib/debug/boot/vmlinux-$(uname -r) /proc/kcore
```

### Show the summary when system crashes

```
sys
sys -i
```

### Use gdb

```
gdb info variable task_struct
```

### Load kernel modules and related debug symbol

```
mod
# refer to https://crash-utility.github.io/help_pages/mod.html
# suppose kvm.ko is in the default path and kvm.ko.debug in the default debug symbol path
mod -s kvm.ko
# suppose kvm.ko in /custom/path/to/modules/ and kvm.ko.debug in /custom/path/to/debug/
mod -p /custom/path/to/modules/ -s /custom/path/to/debug/ kvm
# suppose vhost.ko and symbols are together as /usr/lib/debug/lib/modules/5.4.32-1_51211.virt/kernel/drivers/vhost/vhost.ko
mod -s vhost /usr/lib/debug/lib/modules/5.4.32-1_51211.virt/kernel/drivers/vhost/vhost.ko
```

### Search memory

```
search -c task_struct # Ctrl + c to exit search
```

### Show all symbols

```
# refer to man nm to see symbol type explanations, such as D, d, T, t, etc.
sym -l | grep vm_list | less -is
sym -q cpu
sym -m kvm
```

### Iterate over a list

```
# address is the list address
list <address> -s sli_event.event_type,event_id
```

### VA_BITS_ACTUAL error

```
# error as below may be seen on arm, specify -m vabits_actual to fix the issue
# crash: cannot determine VA_BITS_ACTUAL
crash /boot/vmlinux-5.4.119-19-0009.8 vmcore -m vabits_actual=48
```

### Show log

```
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
```

### Get more info from backtrace

```
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
```

### Show symbol definitions

```
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
```

### Check variables

```
mod -s kvm
# check definitions of a structure
struct kvm
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
```

### Find the struct address based on its member address

```
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
crash> p *(struct kvm *)0xffa0000066fc5000
$4 = {
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
```

### Disassemble

- If vmcore is available:

  ```
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
  ```

- If vmcore is not available

  ```
  # identify the backtrace found w/ dmesg/console, then search keywords from objdump -S xxx
  objdump -S /boot/vmlinux-xxx | less -is
  ```

### Check kernel memory of a task

```
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
```

## Related
- [[debug_kernel_gdb]]
- [[debug_gdb]]
- [[linux_kvm_libvirt]]

