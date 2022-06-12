.. contents:: Linux Performance Tips

Linux Performance Tips
========================

Overall
----------

There is a great diagram, which is from www.brendangregg.com, showing misc tracing tools on Linux. Overall, it can be used as a common reference.

.. image:: images/linux_perf_and_trace_utils.png

top
-------

Top is installed on almost all Linux distributions by default for performance monitoring. Here are some tips of using top:

- Select the column for sort: by default "%CPU" is used for sort

  * Press "F": the first line shows the current sort filed which is "%CPU" by default
  * Press "Up/Down" to navigate: say move to "%MEM"
  * Press "Right", followed by "Enter" to select the field
  * Press "s" to set the field as the current sort field, the first line will indicate the changes
  * Press "ESC" or "q" to see the change

- Reverse sort: Press "R" to reverse the sort order based on the current sort field
- Highlight the sort field column:

  * Press "x" to highlight the current sort field
  * Press "b" to highlight the background of the current sort field

- Filter: press "o/O":

  * Show all filters: press "^O"
  * Clear all filter: press "="
  * Samples:

     * COMMAND=vim
     * %CPU>0.5
     * !COMMAND=vim

- Adavance filter: select multiple processes

  ::

    top -p `pgrep -d ',' -f "app1|app2|app3"`

slabtop, slabinfo
--------------------

Check kernel slab memory, refer to http://www.secretmango.com/jimb/Whitepapers/slabs/slab.html for slab introductions.

nmon
-------

A great tool to tune system performance, which can show statistics for CPU/memory/disks/kernel/etc.

htop
-------

Similar as the classic top, but much more powerful - it is interactive and ncurses-based, which support mouse operations on terminal.

iotop
--------

Show IO status by process.

iftop
--------

Display bandwidth usage including host to host (ip to ip) information.

nethogs
-----------

NetHogs is a small 'net top' tool. Instead of breaking the traffic down per protocol or per subnet, like most tools do, it groups bandwidth by process.

bwm-ng
---------

Bandwidth Monitor NG is a small and simple console-based live network and disk *io bandwidth* monitor for Linux, BSD, Solaris, Mac OS X and others.

cgroups
--------

list supported subsystems
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  lssubsys [-am]
  lscgroup

control cpu usage with cpu
~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Install libcgroup-tools which provides CLI tools for using cgroups
#. Create a cgroup named cpulimit

   ::

     cgcreate -g cpu:/cpulimit

# . Set how much CPU resources processes can use within the cgroup

    - Example 1: use 10% of 1 x CPU

      ::

        # Explanation:
        # - cfs_period_us: the time period to measure CPU usage, max 1s and min 1000us
        # - cfs_quota_us: the time all processes within the cgroup can use within each cfs_period_us
        # Result: processes within the cgroup get cfs_quota_us / cfs_period_us * 100% of 1 x CPU resource
        #         in this example, it is 10% of all CPU resouces
        cgset -r cpu.cfs_period_us=1000000 cpulimit
        cgset -r cpu.cfs_quota_us=100000 cpulimit
        cgget -g cpu:cpulimit

    - Example 2: use 10% of all CPUs

      ::

        # Provided there are 8 x CPUs in total
        cgset -r cpu.cfs_period_us=1000000 cpulimit
        cgset -r cpu.cfs_quota_us=$(( 1000000 * 8 * 0.1 )) cpulimit
        cgget -g cpu:cpulimit

    - Example 3: use 100% of 2 x CPUs

      ::

        # Provided there are 8 x CPUs in total
        cgset -r cpu.cfs_period_us=1000000 cpulimit
        cgset -r cpu.cfs_quota_us=$(( 1000000 * 2 )) cpulimit
        cgget -g cpu:cpulimit

#. Start processes and put them under the control of the cgroup

   ::

     cgexec -g cpu:cpulimit command1
     cgexec -g cpu:cpulimit command2

control cpus process can use with cpuset
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  cgcreate -g cpuset:/testset
  # cgset -r cpuset.cpus='0,2,4,6,8,10' testset
  # cgset -r cpuset.cpus='0-3' testset
  cgset -r cpuset.cpus=3 testset
  cgset -r cpuset.mems=0 testset
  cgexec -g cpuset:testset command

convert cgroup v1 to v2
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  grubby --update-kernel=/boot/vmlinuz-5.4.119-19-0010 --args "systemd.unified_cgroup_hierarchy=1"
  reboot

sysdig
---------

A powerful system and process troubleshooting tool.

- Common options

  - sudo sysdig -cl
  - sudo sysdig -i <chisel name>
  - sudo sysdig -c <chisel name>
  - sudo sysdig -l
  - sudo csysdig

- Examples: https://github.com/draios/sysdig/wiki/sysdig-examples

systemtap
------------

SystemTap is a tracing and probing tool that allows users to study and monitor the activities of the computer system (particularly, the kernel) in fine detail. It provides information similar to the output of tools like netstat,  ps, top, and iostat, but is designed to provide more filtering and analysis options for collected information.

The advantage of systemtap is you can write a kind of script called **SystemTap Scripts** to perform complicated tracing. Please refer to https://sourceware.org/systemtap/ for details.

strace
---------

Trace system calls and signals

LD_DEBUG
----------

Work similarly as strace but focus on dynamic linker operations. Especially useful when debugging program compile realted issues:

::

  LD_DEBUG=help ls
  LD_DEBUG=all ls
  export LD_DEBUG=all
  make

ftrace
---------

Ftrace is an internal tracer designed to help out developers and designers of systems to find what is going on inside the kernel. It can be used for debugging or analyzing latencies and performance issues that take place outside of user-space. Refer to https://www.kernel.org/doc/Documentation/trace/ftrace.txt for information on ftrace.

event tracing
~~~~~~~~~~~~~~~~~~

**tracing**

::

  # method 1 - through event toggle
  cd /sys/kernel/debug/tracing/
  cat available_events # list all availabel events which can be traced
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

**filtering**

::

  # event filter
  cat events/path/to/event/format # understand the supported event format
  echo "filter expression" > events/path/to/event/filter
  echo 0 > events/path/to/event/filter # clear the filter
  # event subsystem filter
  cd events/subsystem/path
  echo 0 > filter
  echo "filter expression" > filter

**pid filtering**

::

  cd /sys/kernel/debug/tracing
  echo <PID> > set_event_pid # filtering multiple PIDs: echo <PID1> <PID2> <...> >> set_event_pid
  ...

function tracing
~~~~~~~~~~~~~~~~~~~~~

**tracing**

::

  cat available_tracers # list all available traces, function, function_graph are used most frequently
  # function
  echo function > current_tracer
  cat available_filter_functions # get filters which can be used for function tracing
  echo <available filter> > set_ftrace_filter # multiple filter can be used - echo <another filter> >> set_ftrace_filter
  # multiple function filters can be configured as : echo <function_name_prefix>* > set_ftrace_filter
  echo > trace
  cat trace # check trace results
  # function graph
  echo function_graph > current_tracer
  cat available_filter_functions # get filters which can be used for function graph tracing
  echo <available filter> > set_graph_function # multiple filter can be used - echo <another filter> >> set_graph_function
  echo 10 > max_graph_depth
  echo > trace
  cat trace # check trace results

**trace_pipe**

::

  # trace_pipe only contains newer data compared with last read, suitable for redirection
  cat trace_pipe
  cat trace_pipe > /tmp/trace.log

kprobe
~~~~~~~~

uprobe
~~~~~~~~

The usage of uprobe is more complicated than kprobe. Let's demonstrace how to trace the function hmp_info_cpus of application qemu-system-x86_64.

**Calculate function offset**

1. Find the function offset:

::

  # refer to https://www.kernel.org/doc/html/latest/_sources/filesystems/proc.rst.txt for information on /proc/PID/maps
  objdump -tT /usr/local/bin/qemu-system-x86_64 | grep hmp_info_cpus
  # the output is: 00000000005ce6d0 g    DF .text  0000000000000158  Base        hmp_info_cpus
  # the offset is 00000000005ce6d0
  cat /proc/`pidof qemu-system-x86_64`/maps | grep r-xp | grep qemu-system-x86_64
  # th output is: 00400000-00baf000 r-xp 00000000 08:03 131826                             /usr/local/bin/qemu-system-x86_64
  # the output indicates the code segment address(r-xp) range for the application(qemu-system-x86_64),
  # for other user applications on the same system, the range actually will be the same value.
  # based on 0x00400000(code segment begins) and 0x5ce6d0(hmp_info_cpus offset), the real offset
  # of hmp_info_cpus compared with the staring address can be gotten as: 0x5ce6d0-0x400000 = 0x1ce6d0

2. Enable uprobe tracers:

::

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

blktrace
-----------

1. **blktrace** is a block layer IO tracing mechanism which provides detailed information about request queue operations up to user space. The trace result is stored in a binary format, which obviously doesn't make for convenient reading;
2. The tool for that job is **blkparse**, a simple interface for analyzing the IO traces dumped by blktrace;
3. However, the plaintext trace result generated by blkparse is still not quite easy for reading, another tool **btt** can be used to generate misc reports, such as latency report, seek time report, etc;
4. Besides, a tool named **Seekwatcher** can be used to genrate graphs for blktrace, which will help a lot comparing IO patterns and performance;
5. In the meanwhile, **btrecord** and **btreplay** can be used to recreate IO loads recorded by blktrace.

perf-tool
------------

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

Example 1: Scheduler Analysis

::

  # Record all scheduler events within 1 second
  perf sched record -- sleep 1
  # To check detailed events
  perf script [--header]
  # Summarize scheduler latencies by task
  perf sched latency [-s max]

Example 2: Performance Analysis

::

  # the whole system performance stat
  perf stat record -a sleep 10
  perf kvm stat record -a sleep 10
  # specified vcpu performance
  perf kvm stat record -a -p <vcpu tid> -a sleep 10
  # report
  perf stat report
  perf kvm stat report

Example 3: perf trace

::

  # trace a process
  perf trace record --call-graph dwarf -p $PID -- sleep 10
  # trace a group of processes
  mkdir /sys/fs/cgroup/perf_event/bpftools/
  echo 22542 >> /sys/fs/cgroup/perf_event/bpftools/tasks
  echo 20514 >> /sys/fs/cgroup/perf_event/bpftools/tasks
  perf trace -G bpftools -a -- sleep 10
