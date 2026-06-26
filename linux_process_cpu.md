---
tags: [linux, cheatsheet, process, cpu]
aliases: ["top", "ps", "taskset", "cpu affinity"]
type: cheatsheet
---
# Linux Process & CPU
## Operations on CPU/Process

### Show CPU Summary

Show CPU architecture, features, sockets, cores, etc.

```bash
lscpu
```

### Show cpu and cache topology

```bash
# Install hwloc and hwloc-gui at first
lstopo-no-graphics --no-io --no-legend --of txt
```

### Show CPU frequency and idle statistics

Refer to https://metebalci.com/blog/a-minimum-complete-tutorial-of-cpu-power-management-c-states-and-p-states/ for C-states

```bash
# note: if a vm with mwait enabled is monitored:
# - top: all vcpus will be shown with almost 100% cpu usage
# - turbostat: the real cpu usage is shown since turbostat
turbostat # https://www.linux.org/docs/man8/turbostat.html
cpupower monitor # https://www.linux.org/docs/man1/cpupower.html
powertop
```

### Make a process run on specified cpu cores

```bash
# query current affinity
taskset -acp <pid>
# change the affinity
taskset -cp <cpu cores, such as 1,2,3> <pid>

# run a program directly on specified cpu cores
# taskset -c 0,36 stress-ng --cpu 2 -l 100
taskset -c 0 stress-ng --cpu 1 -l 100 &
taskset -c 36 stress-ng --cpu 1 -l 100 &
mpstat -P 0,36 1 # monitor the effects
```

### Change limit settings for running process

```bash
prlimit --nofile=40960:40960 -p 107613
```

### Show cpu, memory, etc. usage per process

ps command can be used with customized output format to show per process information including cpu, mem, cgroups, etc.

```bash
ps -e -o "pid,%cpu,%mem,state,tname,time,command"
```

### List Non-Kernel Process

```bash
ps --ppid 2 -p 2 --deselect
```

### List Task/Process Switch Stats

```bash
pidstat -w
```

### Show working dir of a process

```bash
pwdx <pid>
```

### Sort based on fields with top

```bash

# Refer to section "FIELDS / Columns" of "man top" for supported fields
# non-interactive
top -b -o '+%MEM'
# interactive: press f->up/down to select a filed->press s->press q
top # then press keys accordingly
```

### Only show activities of specified cpu cores

```bash
# 1. top interactive
top
# then follow below steps:
# press f -> select filed "P" -> press <Space> to toggle display
# select "P" -> press <Right> -> press <Up> to move "P" to the top
# press q to go back to the display
# press "o" to filter -> enter P=0 to filter only process on process 0/10/...
# press "=" to clear filters
# notes: only one condition is supported

# 2. top non-interactive
top
# then follow below steps:
# press f -> select filed "P" -> press <Space> to toggle display
# select "P" -> press <Right> -> press <Up> to move "P" to the top
# press q to go back to the display
# press W to write persistent top config .toprc
top -bc | awk '$1==0 || $1==36'
# note: remember to delete .toprc after usage
```

### Only show specified processes with top

```bash
top -c -p <process id, ...>
```

### Show process threads

```bash
ps -T -p <pid>
top -H -p <pid>
```

### Show the CPU process/thread is running on

```bash
# psr is the physical cpu
ps -F -p <pid>
ps -T -F -p <pid>
ps -T -p 41869 -o pid,spid,psr,comm
taskset -acp <pid>
```

### Show process kernel stack

Notes: gstack, eu-stack works the same.

```bash
cat /proc/<PID>/stack # main thread stack
cat /proc/<PID>/task/<TID>/stack # stack for child process
pstack <PID> # print kernel stack for the main and children within the same group
```

### Show process schedule class

```bash
ps -cTef
```

### Change process scheduler policy

```bash
chrt -r -p <process id>
```

### Show cpu power supply/consumption

```bash
ipmi-sensors | grep Total_Power
ipmitool sdr | grep Total_Power
# lm_sensors are recommended against ipmitools
yum install -y lm_sensors
sensors
```

## Related
- [[linux_cgroups]]
- [[linux_memory]]

