---
tags: [debug, cheatsheet, tracing]
aliases: ["strace", "perf", "ftrace", "trace-cmd", "blktrace"]
type: cheatsheet
---
# Tracing (strace/perf/ftrace)
## Tracing

### Overview

- https://jvns.ca/blog/2017/07/05/linux-tracing-systems/#data-sources

### strace

Trace system calls and signals:

```
strace -c xxx
strace -c -f xxx
strace xxx
```

### LD_DEBUG

Work similarly as strace but focus on dynamic linker operations. Especially useful when debugging program compile related issues:

```
LD_DEBUG=help ls
LD_DEBUG=all ls
export LD_DEBUG=all
make
```

### perf-tool

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

**Example 0: Help**

```
# tune maxed num. of open files
ulimit -n 65536
perf help
# list supported events
perf list
perf list 'sched:*'
```

**Example 1: Scheduler Analysis**

```
# Record all scheduler events within 1 second
perf sched record -- sleep 1
# To check detailed events
perf script [--header]
# Summarize scheduler latencies by task
perf sched latency [-s max]
```

**Example 2: Performance Analysis**

```
# the whole system performance stat
perf stat record -a sleep 10
perf kvm stat record -a sleep 10
# specified vcpu performance
perf kvm stat record -a -p <vcpu tid> -a sleep 10
# report
perf stat report
perf kvm stat report
```

**Example 3: perf trace**

```
# trace a process
perf trace record --call-graph dwarf -p $PID -- sleep 10
# trace a group of processes
mkdir /sys/fs/cgroup/perf_event/bpftools/
echo 22542 >> /sys/fs/cgroup/perf_event/bpftools/tasks
echo 20514 >> /sys/fs/cgroup/perf_event/bpftools/tasks
perf trace -G bpftools -a -- sleep 10
```

**Example 4: what is running on a specific cpu**

```
perf record -C 1 -F 99 -- sleep 10
perf report
```

**Example 5: system profiling overview**

```
perf top
perf top --sort pid,comm,dso,symbol
```

**Example 6: record with call graph**

```
perf record -ag -e 'sched:*' -- sleep 10
perf report -g --stdio
```

**Example 7: dynamic tracepoint**

```
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
```

**Example 8: visualize total system behavior**

```
perf timechart record
perf report
# open the output svg
```

### trace-cmd

trace-cmd is a frontend for ftrace, and its cli works similar as perf. Use it directly instead of using ftrace whenever possible.

```
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
```

### ftrace

Ftrace is an internal tracer designed to help out developers and designers of systems to find what is going on inside the kernel. It can be used for debugging or analyzing latencies and performance issues that take place outside of user-space. Refer to https://www.kernel.org/doc/Documentation/trace/ftrace.txt for information on ftrace.

#### event tracing

**tracing**

```
# method 1 - through event toggle
cd /sys/kernel/debug/tracing/
cat available_events # list all available events which can be traced
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
```

**filtering**

```
# event filter
cat events/path/to/event/format # understand the supported event format
echo "filter expression" > events/path/to/event/filter
echo 0 > events/path/to/event/filter # clear the filter
# event subsystem filter
cd events/subsystem/path
echo 0 > filter
echo "filter expression" > filter
```

**pid filtering**

```
cd /sys/kernel/debug/tracing
echo <PID> > set_event_pid # filtering multiple PIDs: echo <PID1> <PID2> <...> >> set_event_pid
...
```

#### function tracing

**tracing**

```
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
```

**trace_pipe**

```
# trace_pipe only contains newer data compared with last read, suitable for redirection
cat trace_pipe
cat trace_pipe > /tmp/trace.log
```

#### kprobe

TBD

#### uprobe

The usage of uprobe is more complicated than kprobe. Let's demonstrate how to trace the function hmp_info_cpus of application qemu-system-x86_64.

**Calculate function offset**

1. Find the function offset:

```
# refer to https://www.kernel.org/doc/html/_sources/filesystems/proc.rst.txt for information on /proc/PID/maps
objdump -tT /usr/local/bin/qemu-system-x86_64 | grep hmp_info_cpus
# the output is: 00000000005ce6d0 g    DF .text  0000000000000158  Base        hmp_info_cpus
# the offset is 00000000005ce6d0
cat /proc/`pidof qemu-system-x86_64`/maps | grep r-xp | grep qemu-system-x86_64
# the output is: 00400000-00baf000 r-xp 00000000 08:03 131826                             /usr/local/bin/qemu-system-x86_64
# the output indicates the code segment address(r-xp) range for the application(qemu-system-x86_64),
# for other user applications on the same system, the range actually will be the same value.
# based on 0x00400000(code segment begins) and 0x5ce6d0(hmp_info_cpus offset), the real offset
# of hmp_info_cpus compared with the starting address can be gotten as: 0x5ce6d0-0x400000 = 0x1ce6d0
```

2. Enable uprobe tracers:

```
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
```

### blktrace

1. **blktrace** is a block layer IO tracing mechanism which provides detailed information about request queue operations up to user space. The trace result is stored in a binary format, which obviously doesn't make for convenient reading;
2. The tool for that job is **blkparse**, a simple interface for analyzing the IO traces dumped by blktrace;
3. However, the plaintext trace result generated by blkparse is still not quite easy for reading, another tool **btt** can be used to generate misc reports, such as latency report, seek time report, etc;
4. Besides, a tool named **Seekwatcher** can be used to generate graphs for blktrace, which will help a lot comparing IO patterns and performance;
5. In the meanwhile, **btrecord** and **btreplay** can be used to recreate IO loads recorded by blktrace.

## Related
- [[debug_kernel_gdb]]
- [[debug_binutils]]

