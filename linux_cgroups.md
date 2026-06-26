---
tags: [linux, cheatsheet, cgroups]
aliases: ["cgroup", "cgroups", "resource control"]
type: cheatsheet
---
# Linux Cgroups
## list supported subsystems

```bash
lssubsys [-am]
lscgroup
```

## control cpu usage with cpu

1. Install libcgroup-tools which provides CLI tools for using cgroups
2. Create a cgroup named cpulimit

   ```bash
   cgcreate -g cpu:/cpulimit
   ```

3. Set how much CPU resources processes can use within the cgroup

   - Example 1: use 10% of 1 x CPU

     ```bash
     # Explanation:
     # - cfs_period_us: the time period to measure CPU usage, max 1s and min 1000us
     # - cfs_quota_us: the time all processes within the cgroup can use within each cfs_period_us
     # Result: processes within the cgroup get cfs_quota_us / cfs_period_us * 100% of 1 x CPU resource
     #         in this example, it is 10% of all CPU resouces
     cgset -r cpu.cfs_period_us=1000000 cpulimit
     cgset -r cpu.cfs_quota_us=100000 cpulimit
     cgget -g cpu:cpulimit
     ```

   - Example 2: use 10% of all CPUs

     ```bash
     # Provided there are 8 x CPUs in total
     cgset -r cpu.cfs_period_us=1000000 cpulimit
     cgset -r cpu.cfs_quota_us=$(( 1000000 * 8 * 0.1 )) cpulimit
     cgget -g cpu:cpulimit
     ```

   - Example 3: use 100% of 2 x CPUs

     ```bash
     # Provided there are 8 x CPUs in total
     cgset -r cpu.cfs_period_us=1000000 cpulimit
     cgset -r cpu.cfs_quota_us=$(( 1000000 * 2 )) cpulimit
     cgget -g cpu:cpulimit
     ```

4. Start processes and put them under the control of the cgroup

   ```bash
   cgexec -g cpu:cpulimit command1
   cgexec -g cpu:cpulimit command2
   ```

## control cpus process can use with cpuset

```bash
cgcreate -g cpuset:/testset
# cgset -r cpuset.cpus='0,2,4,6,8,10' testset
# cgset -r cpuset.cpus='0-3' testset
cgset -r cpuset.cpus=3 testset
cgset -r cpuset.mems=0 testset
cgexec -g cpuset:testset command
```

## control block io

```bash
# mount blkio if it is not mounted/enabled
# mount -t cgroup -o blkio none /sys/fs/cgroup/blkio
# echo "major:minor value > xxxx", where xxx is one of:
# blkio.throttle.read_bps_device
# blkio.throttle.write_bps_device
# blkio.throttle.read_iops_device
# blkio.throttle.write_iops_device
```

## convert cgroup v1 to v2

```bash
grubby --update-kernel=/boot/vmlinuz-5.4.119-19-0010 --args "systemd.unified_cgroup_hierarchy=1"
reboot
```

## move a process into a cgroup

```bash
cgcreate -g cpu:mygroup
# move a specified process into the cgroup
nohup xxxx &
pgrep xxxx # ge the process id of the process
echo <pid of xxxx> | tee /sys/fs/cgroup/cpu/mygroup/cgroup.procs
# move all processes started from current shell into the cgroup
# $$ is the current shell pid, all processes started from current shell share the same cgroup
echo $$ > /sys/fs/cgroup/cpu/mygroup/cgroup.procs
```


Unsorted kernel related hints, will be consolidated later.

## Related
- [[linux_process_cpu]]

